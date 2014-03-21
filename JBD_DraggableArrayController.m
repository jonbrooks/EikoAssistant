//
//  JBD_DraggableArrayController.m
//  JB_Database
//
//  Created by Jon Brooks on 2/13/10.
//  Copyright 2010 Jon Brooks. All rights reserved.
//

#import "JBD_DraggableArrayController.h"

NSString *MovedRowsType = @"JBD_MOVED_ROWS_TYPE";
NSString *CopiedRowsType = @"JBD_COPIED_ROWS_TYPE";


/*
 Utility method to retrieve the number of indexes in a given range
 */
@interface NSIndexSet (CountOfIndexesInRange)
-(unsigned int)countOfIndexesInRange:(NSRange)range;
@end

/*
 Implementation of NSIndexSet utility category
 */
@implementation NSIndexSet (CountOfIndexesInRange)

-(unsigned int)countOfIndexesInRange:(NSRange)range
{
	unsigned int start, end, count;
	
	if ((start == 0) && (range.length == 0))
	{
		return 0;	
	}
	
	start	= range.location;
	end		= start + range.length;
	count	= 0;
	
	NSUInteger currentIndex = [self indexGreaterThanOrEqualToIndex:start];
	
	while ((currentIndex != NSNotFound) && (currentIndex < end))
	{
		count++;
		currentIndex = [self indexGreaterThanIndex:currentIndex];
	}
	
	return count;
}
@end



@implementation JBD_DraggableArrayController




- (void)awakeFromNib
{
	[tableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
	[tableView setDraggingSourceOperationMask:(NSDragOperationCopy | NSDragOperationMove) forLocal:YES];
	
	[tableView registerForDraggedTypes:
	 @[CopiedRowsType, MovedRowsType]];
    [tableView setAllowsMultipleSelection:YES];
	
	[super awakeFromNib];
}
	

- (BOOL)tableView:(NSTableView *)iTableView
	writeRowsWithIndexes:(NSIndexSet *)iRowIndexes
	 toPasteboard:(NSPasteboard *)iPboard
{
	// declare our own pasteboard types
    NSArray *typesArray = @[MovedRowsType];
	[iPboard declareTypes:typesArray owner:self];

    // add rows array for local move
	NSData *rowIndexesArchive = [NSKeyedArchiver archivedDataWithRootObject:iRowIndexes];
    [iPboard setData:rowIndexesArchive forType:MovedRowsType];
	
	//Defer Copying for now
	// create new array of selected rows for remote drop
    // could do deferred provision, but keep it direct for clarity
	//NSMutableArray *rowCopies = [NSMutableArray arrayWithCapacity:[rowIndexes count]];

	/* unsigned int currentIndex = [rowIndexes firstIndex];
	while (currentIndex != NSNotFound)
	{
		[rowCopies addObject:[[self arrangedObjects] objectAtIndex:currentIndex]];
		currentIndex = [rowIndexes indexGreaterThanIndex: currentIndex];
	}

	// setPropertyList works here because we're using dictionaries, strings,
	// and dates; otherwise, archive collection to NSData...
	[pboard setPropertyList:rowCopies forType:CopiedRowsType];
	 */

	return YES;


}	 

- (NSDragOperation)tableView:(NSTableView*)iTableView 
		validateDrop: (id <NSDraggingInfo>) iInfo 
		proposedRow:(int)iRow 
		proposedDropOperation:(NSTableViewDropOperation)iOp
		
{
	NSDragOperation dragOp =  NSDragOperationMove;

    [iTableView setDropRow:iRow dropOperation:NSTableViewDropAbove];
	
    return dragOp;

}		
		

-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet
												toIndex:(unsigned int)insertIndex
{	
	// If any of the removed objects come before the insertion index,
	// we need to decrement the index appropriately
	unsigned int adjustedInsertIndex =
	insertIndex - [fromIndexSet countOfIndexesInRange:(NSRange){0, insertIndex}];
	NSRange destinationRange = NSMakeRange(adjustedInsertIndex, [fromIndexSet count]);
	NSIndexSet *destinationIndexes = [NSIndexSet indexSetWithIndexesInRange:destinationRange];
	
	//NSArray *oldObjects = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
	
	
	//for( NSManagedObject *obj in oldObjects )
	//{
	//	[self 
	
	
	//}
	//[self removeObjectsAtArrangedObjectIndexes:fromIndexSet];
	
	//[self insertObjects:newObjects atArrangedObjectIndexes:destinationIndexes];

	
	return destinationIndexes;
}


	
		    
- (BOOL)tableView:(NSTableView*)iTableView 
		acceptDrop: (id <NSDraggingInfo>) iInfo 
		row:(int)iRow 
		dropOperation:(NSTableViewDropOperation)iOp
{
    if (iRow < 0) {
		iRow = 0;
	}
	// if drag source is self, it's a move unless the Option key is pressed
    if ([iInfo draggingSource] == tableView) {
		
		//NSEvent *currentEvent = [NSApp currentEvent];
		//int optionKeyPressed = [currentEvent modifierFlags] & NSAlternateKeyMask;
		
		//if (optionKeyPressed == 0) {
			
			NSData *rowsData = [[iInfo draggingPasteboard] dataForType:MovedRowsType];
			NSIndexSet *indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
			
			NSIndexSet *destinationIndexes = [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:iRow];
			// set selected rows to those that were just moved
			[self setSelectionIndexes:destinationIndexes];
			
			return YES;
		//}
    }
	

    return NO;
}



	



@end
