//
//  JB_Debug.h
//  JB_Database
//
//  Created by Jon Brooks on 2/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define LOG( string ) NSLog( string )

#define ASSERT_LOG( expression, string ) if( !expression ) NSLog( string );

#ifdef NDEBUG
#define ASSERT_DIALOG( expression, string ) (0)
#else
#define ASSERT_DIALOG( expression, string ) NSAssert( expression, string )
#endif

