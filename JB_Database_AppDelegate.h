//
//  JB_Database_AppDelegate.h
//  JB_Database
//
//  Created by Thomas Brooks on 2/6/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JBD_InvoiceWindowController.h"

@interface JB_Database_AppDelegate : NSObject 

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)copyAction:(id)sender;
- (IBAction)createInvoice:(id)sender;
- (IBAction)showSelectedInvoice:(id)sender;

@end
