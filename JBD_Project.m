//
//  JBD_Project.m
//  JB_Database
//
//  Created by Thomas Brooks on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_Project.h"
#import "JBD_HoursLog.h"
//#import "JB_Debug.h"

@implementation JBD_Project


-(void)deleteCurrentHoursLogs
{
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSSet *setOfLogs = [self mutableSetValueForKeyPath: @"hoursLogs"];
	NSEnumerator *logEnumerator = [setOfLogs objectEnumerator];
	JBD_HoursLog *logIter;
	
	while( logIter = [logEnumerator nextObject] )
		[context deleteObject: logIter];

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
	
	NSSet *hours = [self mutableSetValueForKeyPath: @"hoursLogs"];
	NSEnumerator *hoursEnum = [hours objectEnumerator];
	JBD_HoursLog *hoursIter;
	while( hoursIter = [hoursEnum nextObject] )
	{
		//apperently, the deletes in deleteCurrentHoursLogs are cued
		//so this way we won't add a newly deleted total to our calculations
		if( [hoursIter isDeleted] )
			continue;
		
		amountAccum = [amountAccum decimalNumberByAdding: NS_DECIMAL_NUMBER_FROM_NS_NUMBER([hoursIter valueForKey:@"total"])
											withBehavior: JBD_DEFAULT_ROUNDING_BEHAVIOR];
		
		if( [[hoursIter valueForKey:@"unit"] isEqualToString: @"words"] )
			wordsAccum += [[hoursIter valueForKey:@"numberOfUnits"] intValue];
		else	
			hoursAccum += [[hoursIter valueForKey:@"numberOfUnits"] doubleValue];
	}

	[self setValue:amountAccum forKey:@"totalAmount"];
	[self setValue:[NSNumber numberWithInt:wordsAccum] forKey:@"totalWords"];
	[self setValue:[NSNumber numberWithFloat:hoursAccum] forKey:@"totalHours"];

}

#if 0
-(void)updateHoursLogs
/*This currently tries to cache the existing hours before updating the billingRates to the new ones,
  then puts the numbers back in.  Since the ordering in NSSet is essentially random, who gets what 
  value is random.  This also leads to losses of values if one account has a different number of billing
  rates compared to another.  It's hard to define what a good behavior is, and this isn't something that'll
  be done that often either.  We leave it as is.  Ideal behavior would try to match the old with the new by
  similarities in the name, but this will be deferred til later.
*/
{

	//get the entity description from teh context
	NSManagedObjectContext *context = [self managedObjectContext];

	//now go through the hours logs, and get their # of units property
	NSMutableArray *storedValues = [[NSMutableArray alloc] init];
	NSSet *resultsHours = [self mutableSetValueForKeyPath: @"hoursLogs"];
	NSEnumerator *resultsEnum = [resultsHours objectEnumerator];
	JBD_HoursLog *resultsIter;
	while( resultsIter = [resultsEnum nextObject] )
		[storedValues addObject: [resultsIter valueForKey:@"numberOfUnits"]];
	
	//delete the existing HoursLogs
	[self deleteCurrentHoursLogs];
	
	//now go through the fetched billing rates, and get create an hours log # for each one
	NSEntityDescription *hoursLogEntity = [NSEntityDescription
		entityForName:@"HoursLog"
		inManagedObjectContext:context];
	NSSet *setOfBillingRates = [self mutableSetValueForKeyPath: @"account.billingRates"];
	NSEnumerator *billingRateEnumerator = [setOfBillingRates objectEnumerator];
	NSManagedObject *billingRateIter;

	int i=0;
	
	while( billingRateIter = [billingRateEnumerator nextObject] )
	{
		//create a new object
		JBD_HoursLog *newHoursLog = [[JBD_HoursLog alloc] initWithEntity: hoursLogEntity
													insertIntoManagedObjectContext: context];
		//set its values according to the billing rate
		[newHoursLog setValue:self forKey:@"project"];
		[newHoursLog setValue:[billingRateIter valueForKey:@"name"] forKey:@"name"];
		[newHoursLog setValue:[billingRateIter valueForKey:@"rate"] forKey:@"rate"];
		if( [[billingRateIter valueForKey:@"hourlyRate"] boolValue]==YES )
			[newHoursLog setValue:@"hours" forKey:@"unit"];
		else
			[newHoursLog setValue:@"words" forKey:@"unit"];
			
		if( [storedValues count] > i )
			[newHoursLog setValue: [storedValues objectAtIndex:i] forKey:@"numberOfUnits"];
		
		[newHoursLog updateTotal];
		i++;
				
	}		

	[storedValues release];
	


}
#else
/*updated hours log now caches values using order as an index. No more randomness!*/
-(void)updateHoursLogs
{
	//get the entity description from teh context
	NSManagedObjectContext *context = [self managedObjectContext];

	//now go through the hours logs, and store their # of units property in a dictionary indexed by order
	NSSet *resultsHours = [self mutableSetValueForKeyPath: @"hoursLogs"];
	int numberOfHoursLogs = [resultsHours count];

	NSMutableDictionary *storedValues = nil;
	
	if( numberOfHoursLogs > 0 )
	{
		storedValues = [NSMutableDictionary dictionaryWithCapacity: [resultsHours count]];	
		NSEnumerator *resultsEnum = [resultsHours objectEnumerator];
		JBD_HoursLog *resultsIter;
		while( resultsIter = [resultsEnum nextObject] )
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
	NSSet *setOfBillingRates = [self mutableSetValueForKeyPath: @"account.billingRates"];
	NSEnumerator *billingRateEnumerator = [setOfBillingRates objectEnumerator];
	NSManagedObject *billingRateIter;

	
	while( billingRateIter = [billingRateEnumerator nextObject] )
	{
		//create a new object
		JBD_HoursLog *newHoursLog = [[JBD_HoursLog alloc] initWithEntity: hoursLogEntity
													insertIntoManagedObjectContext: context];
		//set its values according to the billing rate
		[newHoursLog setValue:self forKey:@"project"];
		[newHoursLog setValue:[billingRateIter valueForKey:@"name"] forKey:@"name"];
		[newHoursLog setValue:[billingRateIter valueForKey:@"rate"] forKey:@"rate"];
		[newHoursLog setValue:[billingRateIter valueForKey:@"order"] forKey:@"order"];	
		if( [[billingRateIter valueForKey:@"hourlyRate"] boolValue]==YES )
			[newHoursLog setValue:@"hours" forKey:@"unit"];
		else
			[newHoursLog setValue:@"words" forKey:@"unit"];
	
		if( storedValues )
		{
			id cachedValue = [storedValues objectForKey: [billingRateIter valueForKey:@"order"]];
			
			if( cachedValue )
				//only set it if there was a cached value, otherwise we wipe out the default 0
				[newHoursLog setValue: cachedValue forKey: @"numberOfUnits"];
		}			
			
		[newHoursLog updateTotal];
	}	
}


#endif

-(void) setAccount:(NSManagedObject*)iAccount
{

	[self willChangeValueForKey:@"account"];
	[self setPrimitiveValue:iAccount forKey:@"account"];
	[self didChangeValueForKey:@"account"];

	[self updateHoursLogs];
	[self updateTotals];
}

-(void) setClient:(NSManagedObject*)iClient
{
	[self willChangeValueForKey:@"client"];
	[self setPrimitiveValue:iClient forKey:@"client"];
	[self didChangeValueForKey:@"client"];


	[self setValue: nil forKey: @"account"];
	[self setValue: nil forKey: @"projectManager"];
}

-(void) setInvoiceNumber:(NSString*)iInvoiceNumber
{
	[self willChangeValueForKey:@"invoiceNumber"];
	[self setPrimitiveValue:iInvoiceNumber forKey:@"invoiceNumber"];
	[self didChangeValueForKey:@"invoiceNumber"];

	[[self valueForKey:@"invoice"] willChangeValueForKey:@"invoiceNumber"];
	[[self valueForKey:@"invoice"] setPrimitiveValue: iInvoiceNumber forKey:@"invoiceNumber"];
	[[self valueForKey:@"invoice"] didChangeValueForKey:@"invoiceNumber"];
}

-(void) setPoNumber:(NSString*)iPoNumber
{
	[self willChangeValueForKey:@"poNumber"];
	[self setPrimitiveValue:iPoNumber forKey:@"poNumber"];
	[self didChangeValueForKey:@"poNumber"];
	
	[[self valueForKey:@"invoice"] willChangeValueForKey:@"poNumber"];
	[[self valueForKey:@"invoice"] setPrimitiveValue: iPoNumber forKey:@"poNumber"];
	[[self valueForKey:@"invoice"] didChangeValueForKey:@"poNumber"];
	

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
	//- and has a compile error that's more work than its worth to shut up!
	//Apple - this is totally annoying!
	id pm = [self valueForKey:@"projectManager"];
	[pm removeProjectsObject: self];
}


-(void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setValue:[NSDate date] forKey:@"dateReceived"];
	[self setValue:[NSDate date] forKey:@"dueDate"];
	
}

@end
