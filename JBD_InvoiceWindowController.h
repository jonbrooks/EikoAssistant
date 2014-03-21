//
//  JBD_InvoiceWindowController.h
//  JB_Database
//
//  Created by Jon Brooks on 3/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JBD_InvoiceWindowController : NSWindowController

@property (nonatomic, strong, readonly) NSManagedObject *invoice;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithNib: (NSString*)iNib andInvoice: (NSManagedObject*)iInvoice managedObjectContext: (NSManagedObjectContext *)iManagedObjectContext;
- (IBAction)doExport: (id)sender;

@end
