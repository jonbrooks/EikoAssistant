//
//  JBD_DraggableArrayController.h
//  JB_Database
//
//  Created by Jon Brooks on 2/13/10.
//  Copyright 2010 Jon Brooks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JBD_DraggableArrayController : NSArrayController {

	IBOutlet NSTableView *tableView;

}

- (BOOL)tableView:(NSTableView *)iTableView
writeRowsWithIndexes:(NSIndexSet *)iRowIndexes
	 toPasteboard:(NSPasteboard *)iPboard;

- (NSDragOperation)tableView:(NSTableView*)iTableView 
		validateDrop: (id <NSDraggingInfo>) iInfo 
		proposedRow:(int)iRow 
		proposedDropOperation:(NSTableViewDropOperation)iOp;
    
- (BOOL)tableView:(NSTableView*)iTableView 
		acceptDrop: (id <NSDraggingInfo>) iInfo 
		row:(int)iRow 
		dropOperation:(NSTableViewDropOperation)iOp;


@end
