//
//  JCHAddProductShoppingCartListSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductShoppingCartListSectionView.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUIFactory.h"
#import "JCHTransactionUtility.h"
#import <Masonry.h>

@implementation JCHAddProductShoppingCartListSectionViewData

- (void)dealloc
{
    [self.productName release];
    [self.productCount release];
    [self.productPrice release];
    [self.productDiscount release];
    
    [super dealloc];
}

@end
@interface JCHAddProductShoppingCartListSectionView ()
{
    UILabel *_countLabel;
    UILabel *_priceLabel;
    UILabel *_discountLabel;
}
@end
@implementation JCHAddProductShoppingCartListSectionView

- (instancetype)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGFloat deleteButtonWidth = 35.0f;
        CGFloat skuCombineLableWidthOffset = 0.0f;
        CGFloat priceLabelWidthOffset = 0.0f;
        if (manifestType == kJCHOrderShipment) {
            skuCombineLableWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
            priceLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:5.0f];
        }
        UIFont *titleFont = [UIFont jchSystemFontOfSize:12.0f];
        CGFloat currentLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:kStandardLeftMargin];
        CGFloat countLabelWidth = (kScreenWidth / 2 - currentLeftOffset - deleteButtonWidth) / 2;
        self.deletaButton = [JCHUIFactory createButton:CGRectZero
                                                target:self action:nil
                                                 title:nil
                                            titleColor:nil
                                       backgroundColor:nil];
        [self.deletaButton setImage:[UIImage imageNamed:@"addgoods_shoppingtrolley_list_delete"] forState:UIControlStateNormal];
        [self addSubview:self.deletaButton];
        
        [self.deletaButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.width.mas_equalTo(deleteButtonWidth);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        self.productNameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.productNameLabel.textColor = JCHColorMainBody;
        self.productNameLabel.font = titleFont;
        self.productNameLabel.numberOfLines = 0;
        self.productNameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.productNameLabel];
        
        [self.productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(currentLeftOffset);
            make.right.equalTo(self.mas_centerX).with.offset(-currentLeftOffset - skuCombineLableWidthOffset);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        _countLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:titleFont
                                      textColor:JCHColorAuxiliary
                                         aligin:NSTextAlignmentRight];
        _countLabel.numberOfLines = 1;
        _countLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_countLabel];
        
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.productNameLabel.mas_right).with.offset(currentLeftOffset / 2);
            make.width.mas_equalTo(countLabelWidth - priceLabelWidthOffset);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        _priceLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:titleFont
                                      textColor:JCHColorHeaderBackground
                                         aligin:NSTextAlignmentRight];
        _priceLabel.numberOfLines = 1;
        _priceLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_priceLabel];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_countLabel.mas_right);
            make.width.mas_equalTo(countLabelWidth + currentLeftOffset - priceLabelWidthOffset);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        _discountLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:titleFont
                                      textColor:JCHColorAuxiliary
                                         aligin:NSTextAlignmentRight];
        _discountLabel.numberOfLines = 1;
        _discountLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_discountLabel];
        
        [_discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceLabel.mas_right);
            make.width.mas_equalTo(skuCombineLableWidthOffset + 2 * priceLabelWidthOffset + 5);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        {
            UIView *topLine = [[[UIView alloc] init] autorelease];
            topLine.backgroundColor = JCHColorSeparateLine;
            [self addSubview:topLine];
            
            [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self.mas_top);
                make.height.mas_equalTo(kSeparateLineWidth);
            }];
            
            UIView *bottomLine = [[[UIView alloc] init] autorelease];
            bottomLine.backgroundColor = JCHColorSeparateLine;
            [self addSubview:bottomLine];
            
            [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self);
                make.height.mas_equalTo(kSeparateLineWidth);
            }];
        }
    }
    return self;
}

- (void)dealloc
{
    [self.productNameLabel release];
    [super dealloc];
}

- (void)setData:(JCHAddProductShoppingCartListSectionViewData *)data
{
    self.productNameLabel.text = data.productName;
    _countLabel.text = data.productCount;
    CGFloat price = [data.productPrice doubleValue];
    _priceLabel.text = [NSString stringWithFormat:@"¥%.2f", price];
    
    NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:[data.productDiscount doubleValue]];
    _discountLabel.text = [NSString stringWithFormat:@"%@", discountStr];
}

@end
