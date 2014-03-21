//
//  JBD_InvoiceItemController.m
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//This subclass exists solely to sort the array of invoice items by description when loaded from nib


#import "JBD_OrderedArrayController.h"


@implementation JBD_OrderedArrayController


-(void) awakeFromNib
{
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];

	[self setSortDescriptors:@[sd]];


}


@end
