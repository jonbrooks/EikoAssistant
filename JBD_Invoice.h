//
//  JBD_Invoice.h
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JBD_Invoice : NSManagedObject {

}
-(void) initializeWithProjects: (NSMutableSet*) iProjects;
/* initializes all members based on its projects.  Must have had projects already assigned to it*/

-(void) updateTotal;

@end
