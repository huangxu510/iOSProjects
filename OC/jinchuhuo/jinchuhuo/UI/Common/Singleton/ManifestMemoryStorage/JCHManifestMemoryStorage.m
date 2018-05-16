//
//  JCHManifestMemoryStorage.m
//  jinchuhuo
//
//  Created by apple on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestMemoryStorage.h"
#import "JCHSyncStatusManager.h"

@interface JCHManifestMemoryStorage ()
@property (retain, nonatomic, readwrite) NSMutableArray *currentManifestRecordArray;
@end

@implementation JCHManifestMemoryStorage

- (id)init
{
    self = [super init];
    if (self) {
        self.currentManifestRecordArray = [[[NSMutableArray alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc
{
    
    self.currentManifestID = nil;
    self.currentManifestDate = nil;
    self.currentManifestRecordArray = nil;
    self.currentManifestRemark = nil;
    self.currentContactsRecord = nil;
    self.manifestARAPList = nil;
    self.warehouseID = nil;
    self.tableName = nil;
    
    [super dealloc];
    return;
}

+ (id)sharedInstance
{
    static JCHManifestMemoryStorage *staticInstance = nil;
    static dispatch_once_t staticDispatchOnce;
    dispatch_once(&staticDispatchOnce, ^{
        staticInstance = [[JCHManifestMemoryStorage alloc] init];
        staticInstance.inventoryCheckMemory = [[JCHManifestInventoryCheckMemory alloc] init];
    });
    
    return staticInstance;
}

- (void)insertManifestRecordAtHead:(ManifestTransactionDetail *)record
{
    [self.currentManifestRecordArray insertObject:record atIndex:0];
}

- (void)addManifestRecord:(ManifestTransactionDetail *)record
{
    [self.currentManifestRecordArray addObject:record];
}

- (void)addManifestRecordArray:(NSArray *)recordArray
{
    [self.currentManifestRecordArray addObjectsFromArray:recordArray];
}

- (void)removeManifestRecord:(ManifestTransactionDetail *)record
{
    [self.currentManifestRecordArray removeObject:record];
}

- (void)removeAllManifestRecords
{
    [self.currentManifestRecordArray removeAllObjects];
}

- (NSArray *)getAllManifestRecord
{
    return self.currentManifestRecordArray;
}

- (void)clearData
{
    self.currentManifestID = nil;
    self.currentManifestDate = nil;
    self.currentManifestRemark = @"";
    self.isRejected = NO;
    self.hasPayed = NO;
    self.currentManifestDiscount = 1;
    self.receivableAmount = 0.0f;
    self.currentManifestEraseAmount = 0.0f;
    self.currentContactsRecord = nil;
    self.manifestARAPList = nil;
    self.savingCardRechargeAmount = 0.0f;
    self.enumRestaurantManifestType = 0;
    self.tableID = 0;
    self.tableName = @"";
    self.restaurantPeopleCount = 0;
    self.restaurantPreInsertManifestArray = nil;
    self.warehouseID = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
    
    //默认新建货单
    self.manifestMemoryType = kJCHManifestMemoryTypeNew;
    [self.currentManifestRecordArray removeAllObjects];
    
    [self.inventoryCheckMemory clearData];
}


@end
