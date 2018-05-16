//
//  JCHAddProductByScanCodeViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ProductRecord4Cocoa.h"

@interface JCHAddProductByScanCodeViewController : JCHBaseViewController

@property (nonatomic, copy) void(^callBackBlock)(ProductRecord4Cocoa *productRecord);

//! @brief @{productNameUUID : InventoryDetailRecord4Cocoa}
@property (retain, nonatomic, readwrite) NSMutableDictionary *inventoryMap;

- (instancetype)initWithAllProducts:(NSArray *)allProducts;
- (void)popToSwitchTargetController;

@end
