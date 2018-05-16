//
//  JCHAddProductSearchViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ProductRecord4Cocoa.h"
#import "JCHAddProductChildViewController.h"

@interface JCHAddProductSearchViewController : JCHAddProductChildViewController

@property (nonatomic, copy) void(^callBackBlock)(ProductRecord4Cocoa *productRecord, NSString *unitUUID);

- (instancetype)initWithAllProduct:(NSArray *)allProduct
                      inventoryMap:(NSDictionary *)inventoryMap;

@end
