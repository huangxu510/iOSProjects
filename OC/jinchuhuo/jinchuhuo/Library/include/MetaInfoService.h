//
//  MetaInfoService.h
//  iOSInterface
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaInfoRecord4Cocoa.h"

@protocol MetaInfoService <NSObject>

- (int)insertMetaInfo:(MetaInfoRecord4Cocoa *)record;
- (int)updateMetaInfo:(MetaInfoRecord4Cocoa *)record;
- (int)deleteMetaInfo:(NSString *)metaID;
- (NSArray *)queryAllMetaInfo;

@end
