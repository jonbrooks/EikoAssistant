//
//  JBD_Invoice.m
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_Invoice.h"
#import "JBD_Project.h"
#import "JBD_HoursLog.h"
#import "JBD_InvoiceItem.h"

@implementation JBD_Invoice

-(void) updateTotal
{
	NSDecimalNumber *amountAccum = [NSDecimalNumber zero];
	NSSet *invoiceItems = [self mutableSetValueForKeyPath: @"invoiceItems"];
	NSEnumerator *itemEnum = [invoiceItems objectEnumerator];
	JBD_InvoiceItem *itemIter;
	while( itemIter = [itemEnum nextObject] )
			amountAccum = [amountAccum decimalNumberByAdding: NS_DECIMAL_NUMBER_FROM_NS_NUMBER([itemIter valueForKey:@"lineTotal"])
												withBehavior: JBD_DEFAULT_ROUNDING_BEHAVIOR];

	[self setValue:amountAccum forKey:@"totalAmount"];

}
#if defined( MAC_OS_X_VERSION_10_5 ) && ( MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5 )
#define INT_VALUE integerValue
#else
#define INT_VALUE intValue
#endif


- (NSString*) generateInvoiceNumberForClient: (NSManagedObject*) iClient
/*caller is responsible for releasing the returned string*/
{

	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"invoiceNumber" ascending:NO];
	NSArray *sortedArray = [[[iClient mutableSetValueForKeyPath:@"invoices"] allObjects] 
									sortedArrayUsingDescriptors: [NSArray arrayWithObject:sd]];

	if( !sortedArray )
		return [[NSString stringWithString:@"XX_2009001"] retain];

	NSString *latestInvoice = [[sortedArray objectAtIndex:0] valueForKey:@"invoiceNumber"];
	if( !latestInvoice )
		return [[NSString stringWithString:@"XX_2009001"] retain];

	
	NSMutableArray *invoiceComponents = [[NSMutableArray alloc] init];
	
	[invoiceComponents setArray: [latestInvoice componentsSeparatedByString:@"_"]];
	
	NSString *numberString = [invoiceComponents lastObject];
	int value = [numberString INT_VALUE];
	value++;
	[invoiceComponents replaceObjectAtIndex:[invoiceComponents count]-1 
						withObject:[[NSNumber numberWithInt:value] stringValue]];
	
	
	NSString *returnString = [[invoiceComponents componentsJoinedByString:@"_"] retain];
	
	[invoiceComponents release];				
			
	return returnString;
}


-(void) setPaymentDue:(NSDate*)iDate
{
	[self willChangeValueForKey:@"paymentDue"];
	[self setPrimitiveValue:iDate forKey:@"paymentDue"];
	[self didChangeValueForKey:@"paymentDue"];
	
	[[self valueForKey:@"projects"] setValue: iDate forKey: @"paymentDue"];


}

-(void) setInvoiceNumber:(NSString*)iInvoiceNumber
{
	[self willChangeValueForKey:@"invoiceNumber"];
	[self setPrimitiveValue:iInvoiceNumber forKey:@"invoiceNumber"];
	[self didChangeValueForKey:@"invoiceNumber"];
	
	[[self valueForKey:@"projects"] setValue: iInvoiceNumber forKey:@"invoiceNumber"];
}

-(void) setPoNumber:(NSString*)iPoNumber
{
	[self willChangeValueForKey:@"poNumber"];
	[self setPrimitiveValue:iPoNumber forKey:@"poNumber"];
	[self didChangeValueForKey:@"poNumber"];
	
	[[self valueForKey:@"projects"] setValue: iPoNumber forKey:@"poNumber"];
}

-(void) initializeWithProjects: (NSMutableSet*) iProjects
/* initializes all members based on its projects.  Must have had projects already assigned to it*/
{	
	//since we know all projects have the same client, billing rate, account, 
	//we will get all of this information any of the objects!
	JBD_Project *firstProject = [iProjects anyObject];
	NSManagedObject *theClient = [firstProject valueForKey:@"client"];
	NSManagedObjectContext *context = [self managedObjectContext];

	[self setValue: iProjects forKey:@"projects"];	
	[self setValue: theClient forKey:@"client"];
	[self setValue:[theClient valueForKey:@"name"] forKey:@"customerName"];
	[self setValue:[theClient valueForKey:@"addressLine1"] forKey:@"addressLine1"];
	[self setValue:[theClient valueForKey:@"addressLine2"] forKey:@"addressLine2"];
	[self setValue:[theClient valueForKey:@"phoneNumber"] forKey:@"phoneNumber"];
	[self setValue:[[firstProject valueForKey:@"projectManager"] name] forKey:@"projectManager"];
	[self setValue:[firstProject valueForKey:@"poNumber"] forKey:@"poNumber"];
	//set the date to now
	NSDate *dateToAdd = [NSDate date];
	[self setValue:dateToAdd forKey:@"date"];
	[iProjects setValue:dateToAdd forKey:@"invoiceSent"];

	NSString *paymentMethodString = [NSString stringWithString:@"Check"];
	[self setValue: paymentMethodString forKey:@"paymentMethod"];
	NSString *endCustomerName = [NSString stringWithString:@"Customer"];
	[self setValue: endCustomerName forKey:@"endCustomerName"];
	NSString *servicesString = [NSString stringWithString:@"Services"];
	[self setValue: servicesString forKey:@"servicesString"];

/*fortyfive days in seconds*/	
#define FORTYFIVE_DAYS 3888000.0
#define FORTYFIVE (FORTYFIVE_DAYS / 86400.0)
	NSDate *paymentDueDate = [NSDate dateWithTimeIntervalSinceNow: FORTYFIVE_DAYS];
	[self setValue: paymentDueDate forKey:@"paymentDue"];
	//[iProjects setValue:paymentDueDate forKey:@"paymentDue"];					
		
	
	//This is only for simultrans
	//[self setValue:[firstProject valueForKey:@"dueDate"] forKey:@"deliveryDate"];
	
	NSString *invoiceNumberString = [self generateInvoiceNumberForClient: theClient];
	[self setValue: invoiceNumberString forKey:@"invoiceNumber"]; 
	[iProjects setValue: invoiceNumberString forKey:@"invoiceNumber"]; 

	[self setValue:[NSNumber numberWithDouble: FORTYFIVE] forKey:@"paymentTerm"];
	
	//take the first project's name, date,
	[self setValue:[firstProject valueForKey:@"projectTitle"] forKey:@"projectName"];
	[self setValue:[firstProject valueForKey:@"dueDate"] forKey:@"deliveryDate"];
	
	
	
	//add hours log records as individual invoice items
#define NUMBER_OF_INVOICE_ROWS 9	
	NSEntityDescription *invoiceItemEntity = [NSEntityDescription
		entityForName:@"InvoiceItem"
		inManagedObjectContext:context];	

	
	/*We look up an hours log first by order # in this dictionary.  Add a new one if we don't find it*/
	NSMutableDictionary *addedIndexes = [NSMutableDictionary dictionaryWithCapacity:NUMBER_OF_INVOICE_ROWS];
	NSEnumerator *projectEnumerator = [iProjects objectEnumerator];
	
	JBD_Project *projectIter;
	while(projectIter = [projectEnumerator nextObject])
	{
		NSSet *hoursLogs = [projectIter mutableSetValueForKeyPath: @"hoursLogs"];
		NSEnumerator *hoursLogEnumerator = [hoursLogs objectEnumerator];
		JBD_HoursLog *hoursLogIter;
		
		while( hoursLogIter = [hoursLogEnumerator nextObject] )
		{
			id currentIndex = [hoursLogIter valueForKey:@"order"];
			
			JBD_InvoiceItem *theInvoiceItem = [addedIndexes objectForKey: currentIndex];
			
			
			if( theInvoiceItem )
			//An hours log with this index has already been added, add this one to it
			{
				double quantity = [[theInvoiceItem valueForKey:@"quantity"] doubleValue];
				quantity += [[hoursLogIter valueForKey:@"numberOfUnits"] doubleValue];
				[theInvoiceItem setValue: [NSNumber numberWithDouble:quantity] forKey:@"quantity" ];
			}
			else
			//An hours log has not been entered yet for this index.  Add one.
			{
				//don't add a line with quantity 0
				if( [[hoursLogIter valueForKey:@"numberOfUnits"] intValue] == 0 )
					continue;
				
				theInvoiceItem = [[JBD_InvoiceItem alloc] initWithEntity: invoiceItemEntity
															insertIntoManagedObjectContext: context];
				[theInvoiceItem setValue: [hoursLogIter valueForKey:@"name"] forKey:@"itemDescription"];
				[theInvoiceItem setValue: [hoursLogIter valueForKey:@"numberOfUnits"] forKey:@"quantity"];
				[theInvoiceItem setValue: [hoursLogIter valueForKey:@"rate"] forKey:@"unitPrice"];
				[theInvoiceItem setValue: [hoursLogIter valueForKey:@"order"] forKey:@"order"];
				[theInvoiceItem setValue: self forKey:@"invoice"];
				
				
				[addedIndexes setObject: theInvoiceItem forKey: [theInvoiceItem valueForKey: @"order"]];	
			}
		}
	}
	
	//now add the remainder as blank lines
	int i;
	
	for( i=[addedIndexes count]; i<NUMBER_OF_INVOICE_ROWS; i++)
	{
		JBD_InvoiceItem *blankItem = [[JBD_InvoiceItem alloc] initWithEntity: invoiceItemEntity
															insertIntoManagedObjectContext: context];
		
		/*we just want to make sure the order is greater than the orders of any already added items*/
		[blankItem setValue: [NSNumber numberWithInt: (i+NUMBER_OF_INVOICE_ROWS)] forKey:@"order"];																										
		[blankItem setValue: self forKey:@"invoice"];
		[blankItem setValue: [NSNumber numberWithInt: 0] forKey:@"quantity"];
		[blankItem setValue: [NSNumber numberWithInt: 0] forKey:@"unitPrice"];
	}
	
	
	
	
	
	[self updateTotal];
	
	
	

}


@end
