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

@property (nonatomic, strong) NSString * addressLine1;
@property (nonatomic, strong) NSString * addressLine2;
@property (nonatomic, strong) NSString * customerName;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSDate * deliveryDate;
@property (nonatomic, strong) NSString * endCustomerName;
@property (nonatomic, strong) NSString * invoiceNumber;
@property (nonatomic, strong) NSDate * issueDate;
@property (nonatomic, strong) NSDate * paymentDue;
@property (nonatomic, strong) NSString * paymentMethod;
@property (nonatomic, strong) NSNumber * paymentTerm;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSString * poNumber;
@property (nonatomic, strong) NSString * projectCode;
@property (nonatomic, strong) NSString * projectManager;
@property (nonatomic, strong) NSString * projectName;
@property (nonatomic, strong) NSString * projectNumber;
@property (nonatomic, strong) NSString * servicesString;
@property (nonatomic, strong) NSNumber * totalAmount;
@property (nonatomic, strong) NSManagedObject * client;
@property (nonatomic, strong) NSSet* invoiceItems;
@property (nonatomic, strong) NSSet* projects;


-(void) initializeWithProjects: (NSMutableSet*) iProjects;
/* initializes all members based on its projects.  Must have had projects already assigned to it*/

-(void) updateTotal;

@end
