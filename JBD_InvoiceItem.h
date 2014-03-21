//
//  JBD_InvoiceItem.h
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JBD_Invoice;

@interface JBD_InvoiceItem : NSManagedObject {

}

@property (nonatomic, strong) NSString * itemDescription;
@property (nonatomic, strong) NSNumber * lineTotal;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSNumber * quantity;
@property (nonatomic, strong) NSNumber * unitPrice;

@property (nonatomic, strong) JBD_Invoice * invoice;

@end
