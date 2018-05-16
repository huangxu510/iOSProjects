//
//  JCHAddProductSKUListTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "JCHManifestType.h"
#import "JCHMutipleSelectedTableViewCell.h"

@interface JCHAddProductSKUListTableViewCellData : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *skuTypeName;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *inventoryCount;
@property (nonatomic, retain) NSString *productPrice;
@property (nonatomic, retain) NSString *totalAmount;
@property (nonatomic, retain) NSString *productUnit;
@property (nonatomic, assign) NSInteger productUnit_digits;
@property (nonatomic, assign) BOOL buttonSelected;
@property (nonatomic, assign) BOOL sku_hidden_flag;

@property (nonatomic, assign) BOOL disabledPriceButton;         //盘点单用来控制价格是否可以编辑
@property (nonatomic, assign) BOOL disabledTotalAmoutButton;    //进出货单用来控制金额是否可以编辑

@property (nonatomic, assign) BOOL isMainUnit;                  // 拼装单用来确定是不是主单位
@property (nonatomic, assign) CGFloat unitRatio;                // 拼装单中主辅单位的换算系数

@end

typedef NS_ENUM(NSInteger, JCHAddProductSKUListTableViewCellLableTag)
{
    kJCHAddProductSKUListTableViewCellLableTagNone,
    kJCHAddProductSKUListTableViewCellCountLableTag,
    kJCHAddProductSKUListTableViewCellPriceLableTag,
    kJCHAddProductSKUListTableViewCellTotalAmountLableTag,
};

@class JCHAddProductSKUListTableViewCell;
@protocol JCHAddProductSKUListTableViewCellDelegate <NSObject>

- (void)handleLabelTaped:(JCHAddProductSKUListTableViewCell *)cell  editLabel:(UILabel *)editLabel;
- (void)handleSelectCell:(JCHAddProductSKUListTableViewCell *)cell button:(UIButton *)button;

@end

@interface JCHAddProductSKUListTableViewCell : JCHMutipleSelectedTableViewCell

@property (nonatomic, assign) id <JCHAddProductSKUListTableViewCellDelegate> cellDelegate;
@property (nonatomic, retain) UIButton *selectButton;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType;
- (void)setData:(JCHAddProductSKUListTableViewCellData *)data;
- (void)setAssemblingAndDismoutingData:(NSArray *)cellData;
- (void)setLabelSelected:(JCHAddProductSKUListTableViewCellLableTag)labelTag;
- (void)handleSelect:(UIButton *)sender;
- (void)setDefaultFocus;

@end
