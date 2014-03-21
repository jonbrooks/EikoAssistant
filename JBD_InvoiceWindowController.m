//
//  JBD_InvoiceWindowController.m
//  JB_Database
//
//  Created by Jon Brooks on 3/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_InvoiceWindowController.h"

@interface JBD_InvoiceWindowController ()
@property (nonatomic,strong) IBOutlet NSButton *exportButton;
@end

@implementation JBD_InvoiceWindowController

-(id)initWithNib: (NSString*)iNib andInvoice: (NSManagedObject*)iInvoice managedObjectContext: (NSManagedObjectContext *)iManagedObjectContext {

	self = [super initWithWindowNibName: iNib];
	if (self) {
		_invoice = iInvoice;
		_managedObjectContext = iManagedObjectContext;
	}
		
	return self;
}

-(IBAction) doExport: (id)sender {
	[self.exportButton setHidden:YES];
	
	NSString *filename = [[self.invoice valueForKey:@"invoiceNumber"] stringByAppendingString:@".pdf"];
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.nameFieldStringValue = filename;

    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result==NSOKButton) {
            NSRect r = [[[self window] contentView] frame];
            NSData *data = [[self window] dataWithPDFInsideRect:r];
            NSURL *url = [NSURL URLWithString:panel.nameFieldStringValue relativeToURL:panel.directoryURL];
            [data writeToURL:url atomically:YES];
        }
        [self.exportButton setHidden:NO];
    }];

}

@end
