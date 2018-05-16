//
//  JCHAddUnitViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

enum JCHUnitType
{
    kJCHUnitTypeAddUnit = 0,
    kJCHUnitTypeModifyUnit
};

@interface JCHAddUnitViewController : JCHBaseViewController

@property (nonatomic, retain) UnitRecord4Cocoa *unitRecord;
@property (nonatomic ,assign) enum JCHUnitType unitType;
@property (nonatomic, copy) void(^sendValueBlock)(NSString *unit);
- (id)initWithTitle:(NSString *)title;

@end
