//
//  JCHManifestInventoryMemory.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHManifestInventoryCheckMemory : NSObject

- (void)insertManifestRecordAtHead:(id)record;
- (void)addManifestRecord:(id)record;
- (void)addManifestRecordArray:(NSArray *)recordArray;
- (void)removeManifestRecord:(id)record;
- (NSArray *)getAllManifestRecord;
- (void)clearData;

@end
