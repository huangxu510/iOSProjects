//
//  JCHUnitListViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "CommonHeader.h"

typedef NS_ENUM(NSInteger, JCHUnitListType)
{
    kJCHUnitListTypeNormal,
    kJCHUnitListTypeSelect,
};

@interface JCHUnitListViewController : JCHBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UnitRecord4Cocoa *selectUnitRecord;
@property (nonatomic, copy) void (^sendValueBlock)(UnitRecord4Cocoa *selectUnitRecord);
- (instancetype)initWithType:(JCHUnitListType)type;

@end
