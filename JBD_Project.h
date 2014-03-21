//
//  JBD_Project.h
//  JB_Database
//
//  Created by Thomas Brooks on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JBD_HoursLog;
@class JBD_Invoice;

@interface JBD_Project : NSManagedObject
{
}

//attributes
@property (nonatomic, strong) NSDate * datePaid;
@property (nonatomic, strong) NSDate * dateReceived;
@property (nonatomic, strong) NSDate * dueDate;
@property (nonatomic, strong) NSString * invoiceNumber;
@property (nonatomic, strong) NSDate * invoiceSent;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSDate * paymentDue;
@property (nonatomic, strong) NSString * poNumber;
@property (nonatomic, strong) NSString * projectTitle;
@property (nonatomic, strong) NSNumber * totalAmount;
@property (nonatomic, strong) NSNumber * totalHours;
@property (nonatomic, strong) NSNumber * totalWords;

//relationships
@property (nonatomic, strong) NSManagedObject * account;
@property (nonatomic, strong) NSManagedObject * client;
@property (nonatomic, strong) NSSet* hoursLogs;
@property (nonatomic, strong) JBD_Invoice * invoice;
@property (nonatomic, strong) NSManagedObject * projectManager;
@property (nonatomic, strong) NSManagedObject * status;




-(void)updateTotals;


@end

