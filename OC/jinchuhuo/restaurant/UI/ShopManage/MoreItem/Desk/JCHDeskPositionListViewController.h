//
//  JCHDeskPositionListViewController.h
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

typedef NS_ENUM(NSInteger, JCHDeskPositionListType)
{
    kJCHDeskPositionListTypeNormal,
    kJCHDeskPositionListTypeSelect,
};

@interface JCHDeskPositionListViewController : JCHBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void(^sendValueBlock)(TableRegionRecord4Cocoa *regionRecord);
@property (nonatomic, retain) TableRegionRecord4Cocoa *selectPositionRecord;

- (instancetype)initWithType:(JCHDeskPositionListType)type;

@end


