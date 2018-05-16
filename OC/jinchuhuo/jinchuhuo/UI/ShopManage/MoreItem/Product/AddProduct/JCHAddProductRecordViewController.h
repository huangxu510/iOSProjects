//
//  JCHAddProductRecordViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHSetInitialInventoryViewController.h"
#import "ServiceFactory.h"

enum JCHProductType
{
    kJCHProductTypeAddProduct = 0,
    kJCHProductTypeModifyProduct
};

@interface JCHAddProductRecordViewController : JCHBaseViewController


@property (nonatomic, assign) enum JCHProductType productType;

//保存在选择sku界面当前选择的数据和之前选择的数据
@property (nonatomic, retain) GoodsSKURecord4Cocoa *currentSKURecord;

//- (id)initWithTitle:(NSString *)title;
- (id)initWithProductRecord:(ProductRecord4Cocoa *)productRecord;

@end
