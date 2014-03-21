//
//  JBD_Project.m
//  JB_Database
//
//  Created by Thomas Brooks on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "JBD_ManagedObjectDeclarations.h"

@implementation JBD_Project

@dynamic account;
@dynamic client;
@dynamic hoursLogs;
@dynamic invoice;
@dynamic projectManager;
@dynamic status;

@dynamic datePaid;
@dynamic dateReceived;
@dynamic dueDate;
@dynamic invoiceNumber;
@dynamic invoiceSent;
@dynamic notes;
@dynamic paymentDue;
@dynamic poNumber;
@dynamic projectTitle;
@dynamic totalAmount;
@dynamic totalHours;
@dynamic totalWords;

-(void)deleteCurrentHoursLogs
{
	NSManagedObjectContext *context = [self managedObjectContext];
	
	for( JBD_HoursLog *iter in self.hoursLogs )
		[context deleteObject: iter];

}

-(void)updateTotals
/*Updates the total words and total amount any time an hours log is changed.  
  (Should it update if a billing rate is changed too?  This would retroactively change already-
  billed projects, so I think not)
*/
{
	int wordsAccum = 0;
	float hoursAccum = 0.0;
	NSDecimalNumber *amountAccum = [NSDecimalNumber zero];
	
	NSSet *hours = self.hoursLogs;
	
	for( JBD_HoursLog *hoursIter in hours )
	{
		//apperently, the deletes in deleteCurrentHoursLogs are cued
		//so this way we won't add a newly deleted total to our calculations
		if( [hoursIter isDeleted] )
			continue;
		
		amountAccum = [amountAccum decimalNumberByAdding: NS_DECIMAL_NUMBER_FROM_NS_NUMBER([hoursIter valueForKey:@"total"])
											withBehavior: JBD_DEFAULT_ROUNDING_BEHAVIOR];
		
		if( [hoursIter.unit isEqualToString: @"words"] )
			wordsAccum += [hoursIter.numberOfUnits intValue];
		else	
			hoursAccum += [hoursIter.numberOfUnits doubleValue];
	}

	self.totalAmount = amountAccum;
	self.totalWords = @(wordsAccum);
	self.totalHours = @(hoursAccum);
}



/*updated hours log now caches values using order as an index. No more randomness!*/
-(void)updateHoursLogs
{

	NSManagedObjectContext *context = [self managedObjectContext];

	//now go through the hours logs, and store their # of units property in a dictionary indexed by order
	NSSet *resultsHours = self.hoursLogs;
	int numberOfHoursLogs = [resultsHours count];

	NSMutableDictionary *storedValues = nil;
	
	if( numberOfHoursLogs > 0 )
	{
		storedValues = [NSMutableDictionary dictionaryWithCapacity: [resultsHours count]];	
		for( JBD_HoursLog *resultsIter in resultsHours )
		{
				[storedValues setValue: [resultsIter valueForKey:@"numberOfUnits"]
								forKey: [resultsIter valueForKey:@"order"]];
		}

		//delete the existing HoursLogs
		[self deleteCurrentHoursLogs];
	
	}
	
	//now go through the fetched billing rates, and get create an hours log # for each one	
	NSEntityDescription *hoursLogEntity = [NSEntityDescription
		entityForName:@"HoursLog"
		inManagedObjectContext:context];	
	NSSet *setOfBillingRates = self.account.billingRates;

	for( NSManagedObject *billingRateIter in setOfBillingRates )
	{
		//create a new object
		JBD_HoursLog *newHoursLog = [[JBD_HoursLog alloc] initWithEntity: hoursLogEntity
													insertIntoManagedObjectContext: context];
		//set its values according to the billing rate
		newHoursLog.project = self;
		newHoursLog.name = billingRateIter.name;
		newHoursLog.rate = billingRateIter.rate;
		newHoursLog.order = billingRateIter.order;

		if( [billingRateIter.hourlyRate boolValue]==YES )
			newHoursLog.unit = @"hours";
		else
			newHoursLog.unit = @"words";
	
		if( storedValues )
		{
			id cachedValue = storedValues[billingRateIter.order];
			
			if( cachedValue )
				//only set it if there was a cached value, otherwise we wipe out the default 0
				newHoursLog.numberOfUnits = cachedValue;
		}			
			
		[newHoursLog updateTotal];
	}	
}



-(void) setAccount:(NSManagedObject*)iAccount
{

	[self willChangeValueForKey:@"account"];
	[self setPrimitiveAccount:iAccount ];
	[self didChangeValueForKey:@"account"];

	[self updateHoursLogs];
	[self updateTotals];

}

-(void) setClient:(NSManagedObject*)iClient
{
	id oldClient = [self primitiveClient];

	[self willChangeValueForKey:@"client"];
	[self setPrimitiveClient: iClient];
	[self didChangeValueForKey:@"client"];

	if( oldClient != iClient )
	{
		self.account = nil;
		self.projectManager = nil;
	}
}

-(void) setInvoiceNumber:(NSString*)iInvoiceNumber
{
	[self willChangeValueForKey:@"invoiceNumber"];
	[self setPrimitiveInvoiceNumber: iInvoiceNumber];
	[self didChangeValueForKey:@"invoiceNumber"];

	[self.invoice willChangeValueForKey:@"invoiceNumber"];
	[self.invoice setPrimitiveInvoiceNumber: iInvoiceNumber];
	[self.invoice didChangeValueForKey:@"invoiceNumber"];
}

-(void) setPoNumber:(NSString*)iPoNumber
{
	[self willChangeValueForKey:@"poNumber"];
	[self setPrimitivePoNumber: iPoNumber];
	[self didChangeValueForKey:@"poNumber"];
	
	[self.invoice willChangeValueForKey:@"poNumber"];
	[self.invoice setPrimitivePoNumber: iPoNumber];
	[self.invoice didChangeValueForKey:@"poNumber"];
	

}

-(void)prepareForDeletion
{/*
	pm = [self valueForKey:@"projectManager"];
	NSLog( @"*****************************before change****************************\n");
	NSMutableSet *projectsOfPM = [pm valueForKey:@"projects"];
	
	for( id proj in projectsOfPM )
		NSLog( @"%@", proj );
*/
	
	//This fixes a mysterious bug even though its root cause is not understood:
	//For some reason, the projectManager relationship is not being set to null.  The only theory
	//I can come up with is that the bindings in Interface Builder are doing things in a slightly 
	//different order than they used to (in Tiger and Leopard):  You press the button to delete the
	// project, the projectManager dropdown performs its binding which sets the list of project managers 
	// to empty, and then binds to the project a null project manager BEFORE core data has had a chance
	// to clean up the REAL project manger's inverse relationship!  IT's a stretch, but I don't have any
	// other theories, and have spent DAYS researching and scratching my head! - Why isn't Account equally 
	// affected
	[self.projectManager removeProjectsObject: self];

}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		self.dateReceived = [NSDate date];
		self.dueDate = [NSDate date];

	}
	return self;
}



//-(void)awakeFromInsert
//{
//	[super awakeFromInsert];
//	
//	self.dateReceived = [NSDate date];
//	self.dueDate = [NSDate date];

	
//}

@end
