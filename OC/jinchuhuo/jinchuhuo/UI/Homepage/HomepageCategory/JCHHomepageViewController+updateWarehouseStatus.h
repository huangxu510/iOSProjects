//
//  JCHHomepageViewController+updateWarehouseStatus.h
//  jinchuhuo
//
//  Created by huangxu on 16/11/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHHomepageViewController.h"

@interface JCHHomepageViewController (updateWarehouseStatus)

@property (nonatomic, retain) NSArray *warehouseListWithoutDefault;

//查询和更新仓库状态
- (void)handleUpdateWarehouseStatus;


@end
