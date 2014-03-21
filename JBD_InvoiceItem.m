//
//  JBD_InvoiceItem.m
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_InvoiceItem.h"
#import "JBD_Invoice.h"

@implementation JBD_InvoiceItem

-(void) updateTotal
{
	[self setValue: [NSNumber numberWithDouble: 
					( [[self primitiveValueForKey:@"quantity"] doubleValue] *
					  [[self primitiveValueForKey:@"unitPrice"] doubleValue] ) ] 
			 forKey:@"lineTotal"];

}

-(void) setQuantity: (NSNumber*)iQuantity
{
	[self willChangeValueForKey:@"quantity"];
	[self setPrimitiveValue:iQuantity forKey:@"quantity"];
	[self didChangeValueForKey:@"quantity"];

	[self updateTotal];
		
	//now tell the invoice to update its total
	JBD_Invoice *theInvoice = [self primitiveValueForKey:@"invoice"];
	[theInvoice updateTotal];

}

-(void) setUnitPrice: (NSNumber*)iUnitPrice
{
	[self willChangeValueForKey:@"unitPrice"];
	[self setPrimitiveValue:iUnitPrice forKey:@"unitPrice"];
	[self didChangeValueForKey:@"unitPrice"];

	[self updateTotal];
	
	
	//now tell the invoice to update its total
	JBD_Invoice *theInvoice = [self primitiveValueForKey:@"invoice"];
	[theInvoice updateTotal];


}

@end
