//
//  JCHTakeoutAddDishesViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHSetInitialInventoryViewController.h"
#import "ServiceFactory.h"




@interface JCHTakeoutAddDishesViewController : JCHBaseViewController

@property (nonatomic, assign) enum JCHAddDishesType productType;

//保存在选择sku界面当前选择的数据和之前选择的数据
@property (nonatomic, retain) GoodsSKURecord4Cocoa *currentSKURecord;

//- (id)initWithTitle:(NSString *)title;
- (id)initWithProductRecord:(ProductRecord4Cocoa *)productRecord;

@end
