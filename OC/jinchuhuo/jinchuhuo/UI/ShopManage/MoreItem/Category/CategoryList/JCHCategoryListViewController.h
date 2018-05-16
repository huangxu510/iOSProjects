//
//  JCHCategoryListViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "CategoryRecord4Cocoa.h"

typedef NS_ENUM(NSInteger, JCHCategoryListType)
{
    kJCHCategoryListTypeNormal,
    kJCHCategoryListTypeSelect,
};

@interface JCHCategoryListViewController : JCHBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void(^sendValueBlock)(CategoryRecord4Cocoa *categoryRecord);
@property (nonatomic, retain) CategoryRecord4Cocoa *selectCategoryRecord;

- (instancetype)initWithType:(JCHCategoryListType)type;

@end
