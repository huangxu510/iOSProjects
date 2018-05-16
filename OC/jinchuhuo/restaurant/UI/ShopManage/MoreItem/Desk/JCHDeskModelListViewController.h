//
//  JCHDeskModelListViewController.h
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

typedef NS_ENUM(NSInteger, JCHDeskModeListType)
{
    kJCHDeskModeListTypeNormal,
    kJCHDeskModeListTypeSelect,
};

@interface JCHDeskModelListViewController : JCHBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void(^sendValueBlock)(TableTypeRecord4Cocoa *typeTypeRecord);
@property (nonatomic, retain) TableTypeRecord4Cocoa *selectModelRecord;

- (instancetype)initWithType:(JCHDeskModeListType)type;

@end


