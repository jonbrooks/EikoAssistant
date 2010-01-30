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

		mInvoice = [iInvoice retain];
		mManagedObjectContext = [iManagedObjectContext retain];
	}
		
	return ret;
}


- (void) dealloc 
{
	[mInvoice release];
	[mManagedObjectContext release];
	[super dealloc];
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

	[[NSSavePanel savePanel] beginSheetForDirectory: nil
							file: filename 
							modalForWindow:[self window] 
							modalDelegate: self
							didEndSelector:@selector(didEnd:returnCode:saveFormat:)
							contextInfo: nil];



}



- (void)didEnd:(NSSavePanel *)sheet
    returnCode:(int)code
    saveFormat:(void *)saveType;
{
    if (code == NSOKButton)
    {
        if (NO)//for eventually supporting multipage exporting
        {

        }
        else
        {
            NSRect r = [[[self window] contentView] frame];
            NSData *data = [[self window] dataWithPDFInsideRect:r];
            
            [data writeToFile:[sheet filename] atomically:YES];
        }
    }
	[exportButton setHidden:NO];
}



@end
