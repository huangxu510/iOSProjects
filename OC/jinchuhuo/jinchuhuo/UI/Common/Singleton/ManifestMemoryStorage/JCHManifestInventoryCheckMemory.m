//
//  JCHManifestInventoryMemory.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHManifestInventoryCheckMemory.h"

@interface JCHManifestInventoryCheckMemory ()

@property (retain, nonatomic, readwrite) NSMutableArray *currentManifestInventoryRecordArray;

@end

@implementation JCHManifestInventoryCheckMemory

- (void)dealloc
{
    self.currentManifestInventoryRecordArray = nil;
    [super dealloc];
}

- (void)insertManifestRecordAtHead:(id)record
{
    [self.currentManifestInventoryRecordArray insertObject:record atIndex:0];
}

- (void)addManifestRecord:(id)record
{
    [self.currentManifestInventoryRecordArray addObject:record];
}

- (void)addManifestRecordArray:(NSArray *)recordArray
{
    [self.currentManifestInventoryRecordArray addObjectsFromArray:recordArray];
}

- (void)removeManifestRecord:(id)record
{
    [self.currentManifestInventoryRecordArray removeObject:record];
}

- (NSArray *)getAllManifestRecord
{
    return self.currentManifestInventoryRecordArray;
}

- (void)clearData
{
    [self.currentManifestInventoryRecordArray removeAllObjects];
}

@end
