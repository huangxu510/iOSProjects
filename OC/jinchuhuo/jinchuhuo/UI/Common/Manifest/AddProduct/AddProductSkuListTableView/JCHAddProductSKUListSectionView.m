//
//  JCHAddProductSKUListSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductSKUListSectionView.h"
#import "CommonHeader.h"

#import <Masonry.h>

@interface JCHAddProductSKUListSectionView ()
{
    enum JCHOrderType _currentManifestType;
    UILabel *_productTotalAmountLabel;
    UIView *_middleLine;
}
@end

@implementation JCHAddProductSKUListSectionView

- (instancetype)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentManifestType = manifestType;
        self.backgroundColor = JCHColorGlobalBackground;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.titleLabel release];
    [self.selectedAllButton release];
    
    [super dealloc];
}

- (void)createUI
{
    CGFloat buttonWidth = 30;
    CGFloat selectButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:51.0f];
    CGFloat selectButtonHeight = 44.0f;
    self.selectedAllButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:nil
                                                  title:nil
                                             titleColor:nil
                                        backgroundColor:nil];
    [self.selectedAllButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [self.selectedAllButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [self addSubview:self.selectedAllButton];
    
    [self.selectedAllButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(selectButtonWidth);
        make.height.mas_equalTo(selectButtonHeight);
        make.top.equalTo(self);
    }];
    
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont jchSystemFontOfSize:15.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectedAllButton.mas_right);
        make.right.equalTo(self).with.offset(-2 * kStandardLeftMargin - buttonWidth);
        make.top.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    _middleLine = [[[UIView alloc] init] autorelease];
    _middleLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_middleLine];
    
    [_middleLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.selectedAllButton);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    switch (manifestStorage.currentManifestType) {
        case kJCHOrderShipment:
        {
            [self createShipmentUI];
        }
            break;
            
        case kJCHOrderPurchases:
        {
            [self createPurchaseUI];
        }
            break;
            
        case kJCHManifestInventory:
        {
            [self createInventoryUI];
        }
            break;
            
        case kJCHManifestMigrate:
        {
            [self createMigrateUI];
        }
            break;
            
        case kJCHManifestAssembling:
        {
            [self createAssemblingUI];
        }
            break;
            
        case kJCHManifestDismounting:
        {
            [self createDismoutingUI];
        }
            break;
            
#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
        case kJCHManifestMaterialWastage:
        {
            [self createMaterialWastageUI];
        }
            break;
            
        case kJCHRestaurntManifestOpenTable:
        {
            [self createShipmentUI];
        }
            break;
#endif
            
        default:
            break;
    }
}

- (void)hideSelectAllButton
{
    _selectedAllButton.hidden = YES;
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        //make.left.equalTo(self.selectedAllButton.mas_right);
        make.right.equalTo(self).with.offset(-2 * kStandardLeftMargin - 30);
        make.top.equalTo(self);
        make.height.mas_equalTo(44);
    }];
}

- (void)createShipmentUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    CGFloat labelWidth = (kScreenWidth / 2) / 2;
    CGFloat skuNameLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    CGFloat countLabbelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单品"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin - skuNameLabelWidthOffset);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"数量"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"单价"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productPriceLabel];
    
    [productPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productCountLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    
    _productTotalAmountLabel =  [JCHUIFactory createLabel:CGRectZero
                                                    title:@"金额"
                                                     font:titleFont
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentCenter];
    [self addSubview:_productTotalAmountLabel];
    
    [_productTotalAmountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)createMaterialWastageUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    CGFloat labelWidth = (kScreenWidth / 2) / 2;
    CGFloat skuNameLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    CGFloat countLabbelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单品"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin - skuNameLabelWidthOffset);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"损耗数量"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"平均成本"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productPriceLabel];
    
    [productPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productCountLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    
    _productTotalAmountLabel =  [JCHUIFactory createLabel:CGRectZero
                                                    title:@"金额"
                                                     font:titleFont
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentCenter];
    [self addSubview:_productTotalAmountLabel];
    
    [_productTotalAmountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)createPurchaseUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    CGFloat labelWidth = ((kScreenWidth / 2) + kStandardLeftMargin) / 2;
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单品"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"数量"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"单价"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productPriceLabel];
    
    [productPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productCountLabel.mas_right);
        make.width.mas_equalTo(labelWidth);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    
    _productTotalAmountLabel =  [JCHUIFactory createLabel:CGRectZero
                                                    title:@"金额"
                                                     font:titleFont
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentCenter];
    _productTotalAmountLabel.hidden = YES;
    
    [self addSubview:_productTotalAmountLabel];
    
    [_productTotalAmountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)createInventoryUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    CGFloat labelWidth = (kScreenWidth / 2) / 2;
    CGFloat skuNameLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    CGFloat countLabbelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单品"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin - skuNameLabelWidthOffset);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"盘前"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];

    
    UILabel *productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"盘后"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productPriceLabel];
    
    [productPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productCountLabel.mas_right);
        make.width.mas_equalTo(labelWidth - countLabbelWidthOffset);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    
    _productTotalAmountLabel =  [JCHUIFactory createLabel:CGRectZero
                                                    title:@"成本价"
                                                     font:titleFont
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentCenter];
    [self addSubview:_productTotalAmountLabel];
    
    [_productTotalAmountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)createMigrateUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];

    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单品"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentCenter];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"数量"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];


    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)createAssemblingUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"库存"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentCenter];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"拼装数量"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)createDismoutingUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    
    UILabel *skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"库存"
                                                 font:titleFont
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentCenter];
    skuNameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:skuNameLabel];
    
    [skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin);
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    UILabel *productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"拆装数量"
                                                      font:titleFont
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentCenter];
    [self addSubview:productCountLabel];
    
    [productCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuNameLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(skuNameLabel);
        make.bottom.equalTo(self);
    }];
    
    
    UIView *bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(skuNameLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}


@end
