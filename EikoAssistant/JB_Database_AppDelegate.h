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
{
    IBOutlet NSWindow *window;
    IBOutlet NSArrayController *allProjectsController;
	IBOutlet NSArrayController *allClientsController;
	IBOutlet NSArrayController *allInvoices;
	IBOutlet NSArrayController *accountsOfCurrentClient;
	IBOutlet NSTableView *projectView;
	IBOutlet NSButton *invoiceButton;
	
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;

	//JBD_InvoiceWindowController *mInvoiceWindow;
	
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;


- (IBAction)saveAction:sender;
- (IBAction)copyAction:sender;
- (IBAction)createInvoice:sender;
- (IBAction)showSelectedInvoice:sender;




@end
