//
//  JBD_HoursLog.m
//  JB_Database
//
//  Created by Thomas Brooks on 2/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_ManagedObjectDeclarations.h"
#import "JBD_HoursLog.h"
#import "JBD_Project.h"

@implementation JBD_HoursLog

@dynamic name;
@dynamic numberOfUnits;
@dynamic order;
@dynamic rate;
@dynamic total;
@dynamic unit;

@dynamic project;

-(void) updateTotal
{
	self.total = [NSNumber numberWithDouble: 
					( [[self primitiveRate] doubleValue] *
					  [[self primitiveNumberOfUnits] doubleValue] ) ]; 

}

- (void)setNumberOfUnits:(NSNumber *)value 
{
    [self willChangeValueForKey:@"numberOfUnits"];
    [self setPrimitiveNumberOfUnits:value];
    [self didChangeValueForKey:@"numberOfUnits"];

	[self updateTotal];
	
	
	//now tell the project to update its totals
	[self.project updateTotals];

}


@end
