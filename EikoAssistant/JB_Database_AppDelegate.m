//
//  JB_Database_AppDelegate.m
//  JB_Database
//
//  Created by Thomas Brooks on 2/6/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "JB_Database_AppDelegate.h"
#import "JBD_Project.h"
#import "JBD_HoursLog.h"
#import "JB_Debug.h"
#import "JBD_Invoice.h"
#import "JBD_InvoiceItem.h"

@implementation JB_Database_AppDelegate


/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "JB_Database" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"EikosAssistant"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle and all of the 
    framework bundles.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    NSMutableSet *allBundles = [[NSMutableSet alloc] init];
    [allBundles addObject: [NSBundle mainBundle]];
    [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"EikosAssistant.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/*Attempts a save, displaying all errors if there are any
 returns YES on success, NO on errors
*/ 


 -(BOOL) trySaveDisplayingErrors
 {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) 
	{
		if( [error code] == NSValidationMultipleErrorsError ) 
		{
			
			NSArray *errors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
			
			
			NSEnumerator *tEnum = [errors objectEnumerator];
			
			NSError *tError;
			
			while( tError = [tEnum nextObject] )
				[[NSApplication sharedApplication] presentError:tError];	
		}	
		else
			[[NSApplication sharedApplication] presentError:error];
		
		return NO;		
		
    } else return YES;
	
 }
/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
  
 
- (IBAction) saveAction:(id)sender {

	[self trySaveDisplayingErrors];
}

- (IBAction)copyAction:sender
/*
	Copies what is currently visible in the Project View in a tab delimited form to the clipboard.
	If the tableView had a dataSource, it'd be a one-line routine (see below), but since we're using bindings,
	it's more complex.
	
	In case we ever end up using a datasource, the line is:
	[[projectView dataSource] tableView: projectView writeRowsWithIndexes: [projectView selectedRowIndexes] toPasteboard: pasteBoard ];
	
	Current Strategy is to iterate through each selected row, iterating through the columns, querying the column for its Key Binding,
	and formatter if it has one.  Then it queries the row(project) for the value for the Key, and creates a string, optionally
	using the supplied formatter.  
	
	There could be a marginal speed gain if we cached the info for each column the first time through, then we wouldn't have
	to query the column for subsequent rows, but this seems overly complex for an operation that is plenty fast as is.  If 
	we were copying 1000's of rows(as opposed to ~30), we might want to adopt this alternate strategy.
*/
{
	const unichar tabChar = NSTabCharacter;
	const unichar lineBreakChar = NSLineSeparatorCharacter;
	NSString *tabString = [NSString stringWithCharacters: &tabChar length: 1];	
	NSString *lineBreakString = [NSString stringWithCharacters: &lineBreakChar length: 1];	

	NSArray *arrayOfSelectedProjects = [allProjectsController selectedObjects]; 

	//5 = average length of an entry	
	NSMutableString *returnString = [[NSMutableString alloc] initWithCapacity: 
										[projectView numberOfColumns]*[arrayOfSelectedProjects count]*5];

	NSEnumerator *rowEnum = [arrayOfSelectedProjects objectEnumerator];
	id currentRow; 	
	while( currentRow = [rowEnum nextObject])
	{
		NSEnumerator *columnEnum = [[projectView tableColumns] objectEnumerator];
		NSTableColumn *currentColumn;
		while( currentColumn = [columnEnum nextObject] )
		{
			NSString *keyForColumn = [[currentColumn infoForBinding:@"value"] 
										valueForKey:NSObservedKeyPathKey];
			//if it's not bound to 'value', then it's bound to 'selectedObject' (a NSPopupButtonCell)							
			if( nil==keyForColumn )
				keyForColumn = [[[currentColumn infoForBinding:@"selectedObject"] 
										valueForKey:NSObservedKeyPathKey] stringByAppendingString:@".name"];
			
			//get rid of the 'arrangedObjects.' part of the path																												
			NSMutableString *editedKey = [NSMutableString stringWithString:keyForColumn];
			NSRange arrObjRange = NSMakeRange(0, 16);
			[editedKey deleteCharactersInRange:arrObjRange];
			
			NSString *stringToAdd;
		
			//grab and use the formatter if there's one( eg for date), otherwise assume its a string and its ready to go 
			NSFormatter *columnFormatter = [[currentColumn dataCell] formatter];
			if( columnFormatter )
				stringToAdd = [columnFormatter stringForObjectValue:[currentRow valueForKeyPath: editedKey]];
			else
				stringToAdd = [currentRow valueForKeyPath: editedKey];
			
			if(stringToAdd)
				[returnString appendString: stringToAdd];
			
			[returnString appendString: tabString];		
		}
		[returnString appendString: lineBreakString];	
	}
	
	//paste to the clipboard
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSTabularTextPboardType, nil] owner:nil];
	//unfortunately, if we had a datasource, this whole routine coule be done with the following line...

	[pasteBoard setString:returnString forType:NSStringPboardType];

	[returnString release];
}





-(IBAction)showSelectedInvoice:sender
{
	JBD_Invoice *selectedInvoice = [[allInvoices selectedObjects] objectAtIndex:0];
	JBD_InvoiceWindowController *invoiceWindow = [[JBD_InvoiceWindowController alloc] initWithNib:@"invoice" 
													andInvoice: selectedInvoice
													managedObjectContext: managedObjectContext];
	[invoiceWindow showWindow:self];
	
}


- (IBAction)createInvoice:sender
{
	//might need to use the 'selectedObjects' method
	NSArray *projectsToAdd = [allProjectsController selectedObjects];

	//get the entity description from teh context
	NSEntityDescription *invoiceEntity = [NSEntityDescription
		entityForName:@"Invoice"
		inManagedObjectContext:managedObjectContext];
	
	JBD_Invoice *newInvoice = [[JBD_Invoice alloc] initWithEntity: invoiceEntity
													insertIntoManagedObjectContext: managedObjectContext];
													
	[newInvoice initializeWithProjects: [NSMutableSet setWithArray:projectsToAdd]];
	[allInvoices addObject: newInvoice];
	
	/*added object should be automatically selected*/	
	[self showSelectedInvoice:self];
						
	/* the invoice controller retains newInvoice so we can release it*/												
	[newInvoice release];

}


-(BOOL) canCreateInvoice
/*determines if an invoice is creatable based on current selection*/
{
	NSArray *selectedProjects = [allProjectsController selectedObjects];
	NSManagedObject *client, *account;
	NSEnumerator *projectEnumerator = [selectedProjects objectEnumerator];
	JBD_Project *projectIter = [projectEnumerator nextObject];

	client = [projectIter valueForKey:@"client"];
	account = [projectIter valueForKey:@"account"];

	while(projectIter = [projectEnumerator nextObject])
	{
		//make sure the projects all have the same client and account
		if( [projectIter valueForKey:@"client"] != client )
			return NO;
		if( [projectIter valueForKey:@"account"] != account )	
			return NO;

	//make sure the projects all have the same delivery date?? - no
	//make sure the projects have not been invoiced yet?? -no

	}
	return YES;

}




- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
/*called when the main project window changes selection*/
{
	[invoiceButton setEnabled: [self canCreateInvoice]];
}



/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender 
{

    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges]) 
			{
				
                if( ![self trySaveDisplayingErrors] )
				{
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) 
						reply = NSTerminateCancel;	
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


@end
