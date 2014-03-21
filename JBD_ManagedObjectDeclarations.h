//
//  JBD_ManagedObjectDeclarations.h
//  JB_Database
//
//  Created by Jon Brooks on 2/10/10.
//  Copyright 2010 Jon Brooks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JBD_Project.h"
#import "JBD_HoursLog.h"
#import "JBD_InvoiceItem.h"
#import "JBD_Invoice.h"


//--------CoreData Generated accessors for managed object subclasses----//
@interface JBD_Project (CoreDataGeneratedAccessors)

- (void)addHoursLogsObject:(JBD_HoursLog *)value;
- (void)removeHoursLogsObject:(JBD_HoursLog *)value;
- (void)addHoursLogs:(NSSet *)value;
- (void)removeHoursLogs:(NSSet *)value;
- (NSManagedObject *)primitiveAccount;
- (void)setPrimitiveAccount:(NSManagedObject *)value;
- (NSManagedObject *)primitiveClient;
- (void)setPrimitiveClient:(NSManagedObject *)value;
- (JBD_Invoice *)primitiveInvoice;
- (void)setPrimitiveInvoice:(JBD_Invoice *)value;
- (NSManagedObject *)primitiveProjectManager;
- (void)setPrimitiveProjectManager:(NSManagedObject *)value;
- (NSManagedObject *)primitiveStatus;
- (void)setPrimitiveStatus:(NSManagedObject *)value;
- (NSMutableSet*)primitiveHoursLogs;
- (void)setPrimitiveHoursLogs:(NSMutableSet*)value;
- (NSString *)primitiveInvoiceNumber;
- (void)setPrimitiveInvoiceNumber:(NSString *)value;
- (NSString *)primitivePoNumber;
- (void)setPrimitivePoNumber:(NSString *)value;

@end


@interface JBD_HoursLog (CoreDataGeneratedAccessors) 

- (JBD_Project *)primitiveProject;
- (void)setPrimitiveProject:(JBD_Project *)value;
- (NSString *)primitiveName;
- (void)setPrimitiveName:(NSString *)value;
- (NSNumber *)primitiveNumberOfUnits;
- (void)setPrimitiveNumberOfUnits:(NSNumber *)value;
- (NSNumber *)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber *)value;
- (NSNumber *)primitiveRate;
- (void)setPrimitiveRate:(NSNumber *)value;
- (NSNumber *)primitiveTotal;
- (void)setPrimitiveTotal:(NSNumber *)value;
- (NSString *)primitiveUnit;
- (void)setPrimitiveUnit:(NSString *)value;

@end


@interface JBD_InvoiceItem (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveItemDescription;
- (void)setPrimitiveItemDescription:(NSString *)value;
- (NSNumber *)primitiveLineTotal;
- (void)setPrimitiveLineTotal:(NSNumber *)value;
- (NSNumber *)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber *)value;
- (NSNumber *)primitiveQuantity;
- (void)setPrimitiveQuantity:(NSNumber *)value;
- (NSNumber *)primitiveUnitPrice;
- (void)setPrimitiveUnitPrice:(NSNumber *)value;
- (JBD_Invoice *)primitiveInvoice;
- (void)setPrimitiveInvoice:(JBD_Invoice *)value;

@end
 
 
@interface JBD_Invoice (CoreDataGeneratedAccessors)

- (void)addInvoiceItemsObject:(JBD_InvoiceItem *)value;
- (void)removeInvoiceItemsObject:(JBD_InvoiceItem *)value;
- (void)addInvoiceItems:(NSSet *)value;
- (void)removeInvoiceItems:(NSSet *)value;
- (void)addProjectsObject:(JBD_Project *)value;
- (void)removeProjectsObject:(JBD_Project *)value;
- (void)addProjects:(NSSet *)value;
- (void)removeProjects:(NSSet *)value;
- (NSString *)primitiveAddressLine1;
- (void)setPrimitiveAddressLine1:(NSString *)value;
- (NSString *)primitiveAddressLine2;
- (void)setPrimitiveAddressLine2:(NSString *)value;
- (NSString *)primitiveCustomerName;
- (void)setPrimitiveCustomerName:(NSString *)value;
- (NSDate *)primitiveDate;
- (void)setPrimitiveDate:(NSDate *)value;
- (NSDate *)primitiveDeliveryDate;
- (void)setPrimitiveDeliveryDate:(NSDate *)value;
- (NSString *)primitiveEndCustomerName;
- (void)setPrimitiveEndCustomerName:(NSString *)value;
- (NSString *)primitiveInvoiceNumber;
- (void)setPrimitiveInvoiceNumber:(NSString *)value;
- (NSDate *)primitiveIssueDate;
- (void)setPrimitiveIssueDate:(NSDate *)value;
- (NSDate *)primitivePaymentDue;
- (void)setPrimitivePaymentDue:(NSDate *)value;
- (NSString *)primitivePaymentMethod;
- (void)setPrimitivePaymentMethod:(NSString *)value;
- (NSNumber *)primitivePaymentTerm;
- (void)setPrimitivePaymentTerm:(NSNumber *)value;
- (NSString *)primitivePhoneNumber;
- (void)setPrimitivePhoneNumber:(NSString *)value;
- (NSString *)primitivePoNumber;
- (void)setPrimitivePoNumber:(NSString *)value;
- (NSString *)primitiveProjectCode;
- (void)setPrimitiveProjectCode:(NSString *)value;
- (NSString *)primitiveProjectManager;
- (void)setPrimitiveProjectManager:(NSString *)value;
- (NSString *)primitiveProjectName;
- (void)setPrimitiveProjectName:(NSString *)value;
- (NSString *)primitiveProjectNumber;
- (void)setPrimitiveProjectNumber:(NSString *)value;
- (NSString *)primitiveServicesString;
- (void)setPrimitiveServicesString:(NSString *)value;
- (NSNumber *)primitiveTotalAmount;
- (void)setPrimitiveTotalAmount:(NSNumber *)value;
- (NSManagedObject *)primitiveClient;
- (void)setPrimitiveClient:(NSManagedObject *)value;
- (NSMutableSet*)primitiveInvoiceItems;
- (void)setPrimitiveInvoiceItems:(NSMutableSet*)value;
- (NSMutableSet*)primitiveProjects;
- (void)setPrimitiveProjects:(NSMutableSet*)value;

@end


//---------Declarations of properties of Managed Objects---------//


// coalesce these into one @interface Client (CoreDataGeneratedAccessors) section
@interface NSManagedObject (Client)

@property (nonatomic, retain) NSSet* accounts;
@property (nonatomic, retain) NSManagedObject * currency;
@property (nonatomic, retain) NSSet* invoices;
@property (nonatomic, retain) NSSet* projectManagers;
@property (nonatomic, retain) NSSet* projects;
@property (nonatomic, retain) NSString * addressLine1;
@property (nonatomic, retain) NSString * addressLine2;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;

- (void)addAccountsObject:(NSManagedObject *)value;
- (void)removeAccountsObject:(NSManagedObject *)value;
- (void)addAccounts:(NSSet *)value;
- (void)removeAccounts:(NSSet *)value;

- (void)addInvoicesObject:(JBD_Invoice *)value;
- (void)removeInvoicesObject:(JBD_Invoice *)value;
- (void)addInvoices:(NSSet *)value;
- (void)removeInvoices:(NSSet *)value;

- (void)addProjectManagersObject:(NSManagedObject *)value;
- (void)removeProjectManagersObject:(NSManagedObject *)value;
- (void)addProjectManagers:(NSSet *)value;
- (void)removeProjectManagers:(NSSet *)value;

- (void)addProjectsObject:(JBD_Project *)value;
- (void)removeProjectsObject:(JBD_Project *)value;
- (void)addProjects:(NSSet *)value;
- (void)removeProjects:(NSSet *)value;

@end


@interface NSManagedObject (Account)

@property (nonatomic, retain) NSSet* billingRates;

@end



@interface NSManagedObject (BillingRate)

@property (nonatomic, retain) NSNumber * hourlyRate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * rateDescription;
@property (nonatomic, retain) NSManagedObject * account;

@end


@interface NSManagedObject (ProjectManager)

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject * client;
@property (nonatomic, retain) NSSet* projects;

- (void)addProjectsObject:(JBD_Project *)value;
- (void)removeProjectsObject:(JBD_Project *)value;
- (void)addProjects:(NSSet *)value;
- (void)removeProjects:(NSSet *)value;

@end


