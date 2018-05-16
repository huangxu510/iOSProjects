//
//  JCHAddDishesViewController.h
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHBaseViewController.h"
#import "JCHSetInitialInventoryViewController.h"
#import "ServiceFactory.h"

enum JCHAddDishesType
{
    kJCHAddDishesTypeAddProduct = 0,
    kJCHAddDishesTypeModifyProduct,
};

@interface JCHAddDishesViewController : JCHBaseViewController


@property (nonatomic, assign) enum JCHAddDishesType productType;

//保存在选择sku界面当前选择的数据和之前选择的数据
@property (nonatomic, retain) GoodsSKURecord4Cocoa *currentSKURecord;

//- (id)initWithTitle:(NSString *)title;
- (id)initWithProductRecord:(ProductRecord4Cocoa *)productRecord;


@end


