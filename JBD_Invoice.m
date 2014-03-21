//
//  JBD_Invoice.m
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "JBD_ManagedObjectDeclarations.h"

@implementation JBD_Invoice

@dynamic addressLine1;
@dynamic addressLine2;
@dynamic customerName;
@dynamic date;
@dynamic deliveryDate;
@dynamic endCustomerName;
@dynamic invoiceNumber;
@dynamic issueDate;
@dynamic paymentDue;
@dynamic paymentMethod;
@dynamic paymentTerm;
@dynamic phoneNumber;
@dynamic poNumber;
@dynamic projectCode;
@dynamic projectManager;
@dynamic projectName;
@dynamic projectNumber;
@dynamic servicesString;
@dynamic totalAmount;
@dynamic client;
@dynamic invoiceItems;
@dynamic projects;

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

- (NSString*) generateInvoiceNumberForClient: (NSManagedObject*) iClient
/*caller is responsible for releasing the returned string*/
{

	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"invoiceNumber" ascending:NO];
	NSArray *sortedArray = [[iClient.invoices allObjects] 
									sortedArrayUsingDescriptors: @[sd]];

	if( !sortedArray )
		return @"XX_2010001";

	NSString *latestInvoice = [sortedArray[0] valueForKey:@"invoiceNumber"];
	if( !latestInvoice )
		return @"XX_2010001";

	
	NSMutableArray *invoiceComponents = [[NSMutableArray alloc] init];
	
	[invoiceComponents setArray: [latestInvoice componentsSeparatedByString:@"_"]];
	
	NSString *numberString = [invoiceComponents lastObject];
	int value = [numberString integerValue];
	value++;
	invoiceComponents[[invoiceComponents count]-1] = [@(value) stringValue];
	
	
	NSString *returnString = [invoiceComponents componentsJoinedByString:@"_"];
	
			
	return returnString;
}


-(void) setIssueDate:(NSDate*)iDate
{
	[self willChangeValueForKey:@"issueDate"];
	[self setPrimitiveIssueDate: iDate];
	[self didChangeValueForKey:@"issueDate"];
	
	[self.projects setValue: iDate forKey: @"invoiceSent"];

}

-(void) setPaymentDue:(NSDate*)iDate
{
	[self willChangeValueForKey:@"paymentDue"];
	[self setPrimitivePaymentDue: iDate];
	[self didChangeValueForKey:@"paymentDue"];
	
	[self.projects setValue: iDate forKey: @"paymentDue"];

}


-(void) setInvoiceNumber:(NSString*)iInvoiceNumber
{
	[self willChangeValueForKey:@"invoiceNumber"];
	[self setPrimitiveInvoiceNumber: iInvoiceNumber ];
	[self didChangeValueForKey:@"invoiceNumber"];
	
	[self.projects setValue: iInvoiceNumber forKey:@"invoiceNumber"];
}

-(void) setPoNumber:(NSString*)iPoNumber
{
	[self willChangeValueForKey:@"poNumber"];
	[self setPrimitivePoNumber:iPoNumber];
	[self didChangeValueForKey:@"poNumber"];
	
	[self.projects setValue: iPoNumber forKey:@"poNumber"];
}

-(void) initializeWithProjects: (NSMutableSet*) iProjects
/* initializes all members based on its projects.  Must have had projects already assigned to it*/
{	
	//since we know all projects have the same client, billing rate, account, 
	//we will get all of this information any of the objects!
	JBD_Project *firstProject = [iProjects anyObject];
	NSManagedObject *theClient = firstProject.client;
	NSManagedObjectContext *context = [self managedObjectContext];

	self.projects = iProjects;	
	self.client = theClient;
	self.customerName = theClient.name;
	self.addressLine1 = theClient.addressLine1;
	self.addressLine2 = theClient.addressLine2;
	self.phoneNumber = theClient.phoneNumber;
	self.projectManager = firstProject.projectManager.name;
	self.poNumber = firstProject.poNumber;
	//set the date to now
	NSDate *dateToAdd = [NSDate date];
	self.date = dateToAdd;
	[iProjects setValue: dateToAdd forKey:@"invoiceSent"];

	self.paymentMethod = @"Check";
	self.endCustomerName = @"Customer";
	self.servicesString = @"Services";

/*fortyfive days in seconds*/	
#define FORTYFIVE_DAYS 3888000.0
#define FORTYFIVE (FORTYFIVE_DAYS / 86400.0)

	self.paymentDue =  [NSDate dateWithTimeIntervalSinceNow: FORTYFIVE_DAYS];
	self.invoiceNumber = [self generateInvoiceNumberForClient: theClient];
	self.paymentTerm = @(FORTYFIVE);
	self.projectName = firstProject.projectTitle;
	self.deliveryDate = firstProject.dueDate;
		
	//add hours log records as individual invoice items
#define NUMBER_OF_INVOICE_ROWS 9	
	NSEntityDescription *invoiceItemEntity = [NSEntityDescription
		entityForName:@"InvoiceItem"
		inManagedObjectContext:context];	

	
	/*We look up an hours log first by order # in this dictionary.  Add a new one if we don't find it*/
	NSMutableDictionary *addedIndexes = [NSMutableDictionary dictionaryWithCapacity:NUMBER_OF_INVOICE_ROWS];
	
	for( JBD_Project *projectIter in iProjects )
	{
		for( JBD_HoursLog *hoursLogIter in projectIter.hoursLogs )
		{
			id currentIndex = hoursLogIter.order;
			
			JBD_InvoiceItem *theInvoiceItem = addedIndexes[currentIndex];
			
			
			if( theInvoiceItem )
			//An hours log with this index has already been added, add this one to it
			{
				theInvoiceItem.quantity = [NSNumber numberWithDouble: [theInvoiceItem.quantity doubleValue] + 
																	[hoursLogIter.numberOfUnits doubleValue]];
			}
			else
			//An hours log has not been entered yet for this index.  Add one.
			{
				//don't add a line with quantity 0 (but we do want fractional hours!!!)
				if( [hoursLogIter.numberOfUnits floatValue] <= 0 )
					continue;
				
				theInvoiceItem = [[JBD_InvoiceItem alloc] initWithEntity: invoiceItemEntity
															insertIntoManagedObjectContext: context];

				theInvoiceItem.itemDescription = hoursLogIter.name;
				theInvoiceItem.quantity = hoursLogIter.numberOfUnits;
				theInvoiceItem.unitPrice = hoursLogIter.rate;
				theInvoiceItem.order = hoursLogIter.order;
				theInvoiceItem.invoice = self;
				
				addedIndexes[theInvoiceItem.order] = theInvoiceItem;	
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
		blankItem.order = @(i+NUMBER_OF_INVOICE_ROWS);																										
		blankItem.invoice = self;
		blankItem.quantity = @0;
		blankItem.unitPrice = @0;
	}

	[self updateTotal];
}


@end
