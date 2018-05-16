//
//  JCHAddProductTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"
#import "SKURecord4Cocoa.h"

enum
{
    kJCHAddProductTableViewCellNormalHeight = 66,
    kJCHAddproductTableViewCellLeftMenuCellHeight = 80,
};

@interface JCHAddProductTableViewCellData : NSObject

@property (retain, nonatomic, readwrite) NSString *productLogoImage;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productUnit;
@property (retain, nonatomic, readwrite) NSString *productCategory;
@property (retain, nonatomic, readwrite) NSString *productInventoryCount;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *productCount;
@property (retain, nonatomic, readwrite) GoodsSKURecord4Cocoa *goodsSKURecord;
@property (assign, nonatomic, readwrite) BOOL sku_hidden_flag;

@property (assign, nonatomic, readwrite) BOOL isArrowButtonStatusPullDown;

@property (assign, nonatomic, readwrite) BOOL is_multi_unit_enable;
@property (retain, nonatomic, readwrite) NSArray *auxiliaryUnitList;

//是否已经盘点
@property (assign, nonatomic, readwrite) BOOL afterManifestInventoryChecked;

//是否已估清
@property (assign, nonatomic, readwrite) BOOL hasSoldOut;

//外卖版的菜品属性
@property (retain, nonatomic, readwrite) NSString *productProperty;

@end

@class JCHAddProductTableViewCell;
@protocol JCHAddProductTableViewCellDelegate <NSObject>

@optional
- (void)handlePullDownSKUDetailView:(JCHAddProductTableViewCell *)cell button:(UIButton *)button;
- (void)handleShowKeyboard:(JCHAddProductTableViewCell *)cell unitUUID:(NSString *)unitUUID;
- (void)handleSelectInventorySKU:(JCHAddProductTableViewCell *)cell;

@end

@interface JCHAddProductTableViewCellBottomContainerView : UIView

@end

@interface JCHAddProductTableViewCell : UITableViewCell

@property (assign, nonatomic, readwrite) id<JCHAddProductTableViewCellDelegate> delegate;
@property (assign, nonatomic, readwrite) CGFloat pullDownCellHeight;
@property (assign, nonatomic, readwrite) CGFloat normalCellHeight;
@property (retain, nonatomic, readwrite) UIButton *pullDownButton;
@property (assign, nonatomic, readwrite) NSInteger addProductListStyle;
@property (copy, nonatomic) void(^tapBlock)(JCHAddProductTableViewCell *cell);

- (void)setCellData:(JCHAddProductTableViewCellData *)cellData;
- (NSArray *)getSKUData;
- (void)selectButtons:(NSArray *)skuValueUUIDs;
- (void)deselectAllButtons;

@end
