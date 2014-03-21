//
//  JBD_HoursLog.h
//  JB_Database
//
//  Created by Thomas Brooks on 2/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JBD_HoursLog : NSManagedObject {

}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * numberOfUnits;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSNumber * rate;
@property (nonatomic, strong) NSNumber * total;
@property (nonatomic, strong) NSString * unit;
@property (nonatomic, strong) JBD_Project * project;


-(void) updateTotal;



@end

