//
//  JCHInventoryTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBaseTableViewCell.h"

@interface InventoryInfo : NSObject
@property (retain, nonatomic, readwrite) NSString *productLogoName;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *purchasesCount;
@property (retain, nonatomic, readwrite) NSString *shipmentCount;
@property (retain, nonatomic, readwrite) NSString *inventoryCount;
@property (retain, nonatomic, readwrite) NSString *inventoryUnit;
@property (assign, nonatomic, readwrite) BOOL isShopManager;
@property (assign, nonatomic, readwrite) BOOL isSKUProduct;
@end

@interface JCHInventoryTableViewCell : JCHBaseTableViewCell

@property (copy, nonatomic) void(^tapBlock)(JCHInventoryTableViewCell *cell);

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setData:(InventoryInfo *)inventoryInfo;

@end
