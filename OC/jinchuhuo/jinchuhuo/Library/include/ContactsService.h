//
//  ContactsService.h
//  iOSInterface
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsRecord4Cocoa.h"

@protocol ContactsService <NSObject>

- (int)insertAccount:(ContactsRecord4Cocoa *)record;
- (int)updateAccount:(ContactsRecord4Cocoa *)record;
- (int)deleteAccount:(NSString *)contactsUUID;
- (NSArray *)queryAllContacts;
- (ContactsRecord4Cocoa *)queryContacts:(NSString *)contactsUUID;
- (NSArray *)getAvailableRelationship;
- (BOOL)isContactsCanBeDeleted:(NSString *)contactsUUID;
- (void)addOrUpdateContactsByPhone:(NSString **)contactsUUID contactRecord:(ContactsRecord4Cocoa *)contactRecord;

@end
