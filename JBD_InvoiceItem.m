//
//  JBD_InvoiceItem.m
//  JB_Database
//
//  Created by Jon Brooks on 3/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JBD_ManagedObjectDeclarations.h"

@implementation JBD_InvoiceItem

@dynamic itemDescription;
@dynamic lineTotal;
@dynamic order;
@dynamic quantity;
@dynamic unitPrice;
@dynamic invoice;

-(void) updateTotal
{
	self.lineTotal = [NSNumber numberWithDouble: ( [[self primitiveQuantity] doubleValue] *
													[[self primitiveUnitPrice] doubleValue] ) ];

}

-(void) setQuantity: (NSNumber*)iQuantity
{
	[self willChangeValueForKey:@"quantity"];
	[self setPrimitiveQuantity: iQuantity];
	[self didChangeValueForKey:@"quantity"];

	[self updateTotal];
		
	//now tell the invoice to update its total
	[self.invoice updateTotal];
}

-(void) setUnitPrice: (NSNumber*)iUnitPrice
{
	[self willChangeValueForKey:@"unitPrice"];
	[self setPrimitiveUnitPrice: iUnitPrice ];
	[self didChangeValueForKey:@"unitPrice"];

	[self updateTotal];
	
	
	//now tell the invoice to update its total
	[self.invoice updateTotal];


}

@end
