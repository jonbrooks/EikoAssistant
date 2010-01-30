//
//  debug.m
//  JB_Database
//
//  Created by Jon Brooks on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JB_Debug.h"


@implementation JB_Debug

+(void) displayDialog: (NSString *)string
{
	NSAlert *theAlert = [NSAlert alertWithMessageText: nil defaultButton: @"OK" alternateButton: nil otherButton: nil informativeTextWithFormat: string];
	[theAlert runModal];

}

@end
