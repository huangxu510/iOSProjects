//
//  JCHAddDeskPositionViewController.h
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

enum JCHAddDeskPositionType
{
    kJCHAddDeskPositionTypeAddCategory = 0,
    kJCHAddDeskPositionTypeModifyCategory
};

@interface JCHAddDeskPositionViewController : JCHBaseViewController

@property (nonatomic, retain) TableRegionRecord4Cocoa *tableRegionRecord;
@property (nonatomic, assign) enum JCHAddDeskPositionType addRegionType;
@property (nonatomic, copy) void(^sendValueBlock)(NSString *regionName);

- (id)initWithTitle:(NSString *)title;

@end


