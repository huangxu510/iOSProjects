//
//  CategoryService.h
//  iOSInterface
//
//  Created by apple on 15/8/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryRecord4Cocoa.h"

@protocol CategoryService <NSObject>

- (int)insertCategory:(CategoryRecord4Cocoa *)record;
- (int)updateCategory:(CategoryRecord4Cocoa *)record;
- (int)deleteCategory:(NSString *)categoryUUID;
- (NSArray *)queryAllCategory;
- (BOOL)isCategoryCanBeDeleted:(NSString *)categoryUUID;

@end
