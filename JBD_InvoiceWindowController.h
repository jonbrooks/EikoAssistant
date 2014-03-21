//
//  JBD_InvoiceWindowController.h
//  JB_Database
//
//  Created by Jon Brooks on 3/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JBD_InvoiceWindowController : NSWindowController {
	
	
	NSManagedObject *mInvoice;
	NSManagedObjectContext *mManagedObjectContext;
	IBOutlet NSButton *exportButton;
}

-(id) initWithNib: (NSString*)iNib 
			andInvoice: (NSManagedObject*)iInvoice 
			managedObjectContext: (NSManagedObjectContext *)iManagedObjectContext;
			
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObject *)invoiceObject;
- (IBAction) doExport: (id)sender;

@end
