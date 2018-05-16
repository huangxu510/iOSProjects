//
//  JCHAddProductShoppingCartListTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductShoppingCartListTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHTransactionUtility.h"
#import "Masonry.h"

@implementation JCHAddProductShoppingCartListTableViewCellData

- (void)dealloc
{
    [self.skuCombine release];
    [self.count release];
    [self.price release];
    [self.discount release];
    
    [super dealloc];
}

@end

@interface JCHAddProductShoppingCartListTableViewCell ()
{
    UILabel *_skuCombineLabel;
    UILabel *_countLabel;
    UILabel *_priceLabel;
    UILabel *_discountLabel;
    UIButton *_deleteButton;
    UIImageView *_bottomLineImageView;
    enum JCHOrderType _currentManifestType;
}
@end

@implementation JCHAddProductShoppingCartListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        _currentManifestType = manifestType;
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:12.0f];
    _skuCombineLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:titleFont
                                    textColor:JCHColorAuxiliary
                                       aligin:NSTextAlignmentLeft];
    _skuCombineLabel.numberOfLines = 2;
    _skuCombineLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_skuCombineLabel];
    
    _countLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:titleFont
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    _countLabel.numberOfLines = 1;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_countLabel];
    
    _priceLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:titleFont
                                       textColor:JCHColorHeaderBackground
                                          aligin:NSTextAlignmentRight];
    _priceLabel.numberOfLines = 1;
    _priceLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_priceLabel];
    
    _discountLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:titleFont
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentRight];
    _discountLabel.numberOfLines = 1;
    _discountLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_discountLabel];
    
    _deleteButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(deleteItem)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    [_deleteButton setImage:[UIImage imageNamed:@"addgoods_shoppingtrolley_list_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
    
    _bottomLineImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [self.contentView addSubview:_bottomLineImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat currentLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:kStandardLeftMargin];
    CGFloat deleteButtonWidth = 35.0f;
    CGFloat skuCombineLableWidthOffset = 0.0f;
    CGFloat priceLabelWidthOffset = 0.0f;
    if (_currentManifestType == kJCHOrderShipment) {
        skuCombineLableWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
        priceLabelWidthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:5.0f];
    }
    
    [_skuCombineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(currentLeftOffset);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-currentLeftOffset - skuCombineLableWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    CGFloat countLabelWidth = (kScreenWidth / 2 - currentLeftOffset - deleteButtonWidth) / 2;
    
    [_countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuCombineLabel.mas_right).with.offset(currentLeftOffset / 2);
        make.width.mas_equalTo(countLabelWidth - priceLabelWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_countLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth + currentLeftOffset - priceLabelWidthOffset);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_discountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_priceLabel.mas_right);
        make.width.mas_equalTo(skuCombineLableWidthOffset + 2 * priceLabelWidthOffset + 5);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_discountLabel.mas_right);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_bottomLineImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuCombineLabel);
        make.right.equalTo(self.contentView).with.offset(-currentLeftOffset);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.bottom.equalTo(self.contentView);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)hideBottomLine:(BOOL)hidden
{
    if (hidden) {
        _bottomLineImageView.hidden = YES;
    }
    else
    {
        _bottomLineImageView.hidden = NO;
    }
}

- (void)setData:(JCHAddProductShoppingCartListTableViewCellData *)data
{
    _skuCombineLabel.text = data.skuCombine;
    _countLabel.text = data.count;
    CGFloat price = [data.price doubleValue];
    _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f", price];
    
    NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:[data.discount doubleValue]];
    _discountLabel.text = [NSString stringWithFormat:@"%@", discountStr];
}

- (void)deleteItem
{
    if ([self.delegate respondsToSelector:@selector(handleDeleteTransaction:)]) {
        [self.delegate handleDeleteTransaction:self];
    }
}

@end
