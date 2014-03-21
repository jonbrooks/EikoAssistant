//
//  JBD_HoursLog.m
//  JB_Database
//
//  Created by Thomas Brooks on 2/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_HoursLog.h"
#import "JBD_Project.h"

@implementation JBD_HoursLog

-(void) updateTotal
{
	[self setValue: [NSNumber numberWithDouble: 
					( [[self primitiveValueForKey:@"rate"] doubleValue] *
					  [[self primitiveValueForKey:@"numberOfUnits"] doubleValue] ) ] 
			 forKey:@"total"];

}

-(void) setNumberOfUnits: (NSNumber*)iNumberOfUnits
{
	[self willChangeValueForKey:@"numberOfUnits"];
	[self setPrimitiveValue:iNumberOfUnits forKey:@"numberOfUnits"];
	[self didChangeValueForKey:@"numberOfUnits"];

	[self updateTotal];
	
	
	//now tell the project to update its totals
	JBD_Project *theProject = [self primitiveValueForKey:@"project"];
	[theProject updateTotals];


}


@end
