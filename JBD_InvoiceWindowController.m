//
//  JBD_InvoiceWindowController.m
//  JB_Database
//
//  Created by Jon Brooks on 3/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_InvoiceWindowController.h"


@implementation JBD_InvoiceWindowController

-(id) initWithNib: (NSString*)iNib 
			andInvoice: (NSManagedObject*)iInvoice 
			managedObjectContext: (NSManagedObjectContext *)iManagedObjectContext
{

	id ret = [super initWithWindowNibName: iNib];
	if( ret)
	{

		mInvoice = iInvoice;
		mManagedObjectContext = iManagedObjectContext;
	}
		
	return ret;
}



- (NSManagedObject *)invoiceObject
{
	return mInvoice;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return mManagedObjectContext;
}

-(IBAction) doExport: (id)sender
{
	[exportButton setHidden:YES];
	
	NSString *filename = [[mInvoice valueForKey:@"invoiceNumber"] stringByAppendingString:@".pdf"];
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.nameFieldStringValue = filename;

    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result==NSOKButton) {
            NSRect r = [[[self window] contentView] frame];
            NSData *data = [[self window] dataWithPDFInsideRect:r];
            NSURL *url = [NSURL URLWithString:panel.nameFieldStringValue relativeToURL:panel.directoryURL];
            [data writeToURL:url atomically:YES];
        }
        [exportButton setHidden:NO];
    }];

}




@end
