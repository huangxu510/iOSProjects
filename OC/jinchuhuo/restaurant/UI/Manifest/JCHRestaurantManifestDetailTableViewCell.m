//
//  JCHRestaurantManifestDetailTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestDetailTableViewCell.h"
#import "JCHLabel.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "JCHTransactionUtility.h"
#import "Masonry.h"
#import "CommonHeader.h"

enum {
    kCreateManifestCellCountLabelWidth = 60,
};

@implementation JCHRestaurantManifestDetailTableViewCellData

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.productName release];
    [self.productCount release];
    [self.productDiscount release];
    [self.productPrice release];
    [self.productImageName release];
    [self.productSKUValueCombine release];
    [self.productUnit release];
    [self.productIncreaseCount release];
    self.mainAuxiliaryUnitCountInfo = nil;
    self.totalAmount = nil;
    
    [super dealloc];
    return;
}

@end


@interface JCHRestaurantManifestDetailTableViewCell ()
{
    JCHLabel *productNameLabel;
    UIImageView *productLogoImageView;
    UILabel *additionalLabel;
    UILabel *productCountLabel;
    UILabel *totalAmountLabel;
    UILabel *productDiscountLabel;
    UILabel *productPriceLabel;
    UILabel *presentMarkLabel;
    JCHLabel *productSKUValueLabel;
    UIView *bottomLine;
    UIImageView *bottomImageView;
    enum JCHOrderType enumCurrentManifestType;
    CGFloat productNameLabelHeight;
    CGFloat skuTypeLabelHeight;
    BOOL isManifestDetail;
}
@end

@implementation JCHRestaurantManifestDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType isManifestDetail:(BOOL)manifestDetail
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        enumCurrentManifestType = manifestType;
        isManifestDetail = manifestDetail;
        skuTypeLabelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
        productNameLabelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    UIFont *priceFont = [UIFont jchSystemFontOfSize:13.0f];
    UIColor *titleColor = JCHColorMainBody;
    {
        productNameLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                  title:@""
                                                   font:titleFont
                                              textColor:titleColor
                                                 aligin:NSTextAlignmentLeft];
        productNameLabel.numberOfLines = 0;
        productNameLabel.verticalAlignment = kVerticalAlignmentTop;
        [self.contentView addSubview:productNameLabel];
    }
    
    {
        productLogoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        productLogoImageView.image = [UIImage imageNamed:@"icon_chu"];
        productLogoImageView.layer.cornerRadius = 3.0f;
        productLogoImageView.clipsToBounds = YES;
        [self.contentView addSubview:productLogoImageView];
    }
    
    if (enumCurrentManifestType == kJCHManifestInventory) {
        
        additionalLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:priceFont
                                          textColor:titleColor
                                             aligin:NSTextAlignmentRight];
        additionalLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:additionalLabel];
    }
    
    {
        productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"0.0"
                                                 font:priceFont
                                            textColor:titleColor
                                               aligin:NSTextAlignmentRight];
        productCountLabel.adjustsFontSizeToFitWidth = YES;
        
        [self.contentView addSubview:productCountLabel];
    }
    
    {
        productDiscountLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"1.0"
                                                    font:titleFont
                                               textColor:UIColorFromRGB(0xff9532)
                                                  aligin:NSTextAlignmentRight];
        productDiscountLabel.hidden = YES;
        productDiscountLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:productDiscountLabel];
    }
    
    {
        productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"0.0"
                                                 font:priceFont
                                            textColor:JCHColorHeaderBackground
                                               aligin:NSTextAlignmentRight];
        productPriceLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:productPriceLabel];
    }
    
    {
        totalAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"0.0"
                                                font:priceFont
                                           textColor:JCHColorHeaderBackground
                                              aligin:NSTextAlignmentRight];
        totalAmountLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:totalAmountLabel];
    }
    
    {
        productSKUValueLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                      title:@""
                                                       font:titleFont
                                                  textColor:JCHColorAuxiliary
                                                     aligin:NSTextAlignmentLeft];
        productSKUValueLabel.numberOfLines = 0;
        productSKUValueLabel.verticalAlignment = kVerticalAlignmentTop;
        [self.contentView addSubview:productSKUValueLabel];
    }
    
    {
        presentMarkLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                  title:@"赠品"
                                                   font:titleFont
                                              textColor:UIColorFromRGB(0xff9532)
                                                 aligin:NSTextAlignmentRight];
        presentMarkLabel.hidden = YES;
        [self.contentView addSubview:presentMarkLabel];
    }
    
    {
        bottomLine = [[[UIView alloc] init] autorelease];
        bottomLine.backgroundColor = JCHColorSeparateLine;
        [self.contentView addSubview:bottomLine];
    }
    
    {
        bottomImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
        [self.contentView addSubview:bottomImageView];
    }
    
    if (isManifestDetail) {
        bottomLine.hidden = YES;
        self.showMenuButton.hidden = YES;
    } else {
        bottomImageView.hidden = YES;
    }
    
    
    UIView *selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.contentView.frame.size.height)] autorelease];
    selectedBackgroundView.backgroundColor = JCHColorSelectedBackground;
    self.selectedBackgroundView = selectedBackgroundView;
    
    if (enumCurrentManifestType == kJCHOrderShipment || enumCurrentManifestType == kJCHOrderPurchases) {
        self.showMenuButton.hidden = YES;
    } else if (enumCurrentManifestType == kJCHManifestInventory) {
        productCountLabel.textColor = JCHColorPriceText;
        productPriceLabel.textColor = JCHColorPriceText;
    } else if (enumCurrentManifestType == kJCHManifestMigrate) {
        productCountLabel.textColor = JCHColorPriceText;
    }
}


- (void)setData:(JCHRestaurantManifestDetailTableViewCellData *)cellData
{
    productNameLabel.text = cellData.productName;
    productCountLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productCount, cellData.productUnit];
    productPriceLabel.text = [NSString stringWithFormat:@"¥%@", cellData.productPrice];
    productLogoImageView.image = [UIImage jchProductImageNamed:cellData.productImageName];
    totalAmountLabel.text = cellData.totalAmount;
    
    if (cellData.productSKUValueCombine && ![cellData.productSKUValueCombine isEqualToString:@""]) {
        productSKUValueLabel.text = cellData.productSKUValueCombine;
    } else {
        productSKUValueLabel.text = @"无规格";
    }
    
    
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    CGFloat currentkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:8.0f];
    CGFloat productLogoImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    
    CGFloat nameLabelRightOffset = 0;
    
    if (enumCurrentManifestType == kJCHManifestInventory) {
        nameLabelRightOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    }
    CGFloat nameLabelWidth = kScreenWidth / 2 - 2 * currentkStandardLeftMargin - productLogoImageViewWidth - nameLabelRightOffset;
    CGFloat skuTypeLabelWidth = kScreenWidth / 2 - 2 * currentkStandardLeftMargin - productLogoImageViewWidth;
    //cell上所有控件垂直间距总和
    CGFloat cellHeightMargin = [JCHSizeUtility calculateWidthWithSourceWidth:17.0f];
    CGRect rect = [cellData.productName boundingRectWithSize:CGSizeMake(nameLabelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleFont} context:nil];
    productNameLabelHeight = rect.size.height + 5;
    
    rect = [cellData.productSKUValueCombine boundingRectWithSize:CGSizeMake(skuTypeLabelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleFont} context:nil];
    skuTypeLabelHeight = rect.size.height + 5;
    
    CGFloat realHeight = productNameLabelHeight + skuTypeLabelHeight + cellHeightMargin;
    CGFloat originalCellHeight = [JCHSizeUtility calculateWidthWithSourceWidth:74.0f];
    if (realHeight > originalCellHeight) {
        self.cellHeight = realHeight;
    } else {
        self.cellHeight = originalCellHeight;
    }
    
    if (enumCurrentManifestType == kJCHOrderShipment) {
        
        if ([cellData.productDiscount doubleValue] != 1 && [cellData.productPrice doubleValue] != 0) {
            productDiscountLabel.hidden = NO;
            NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:[cellData.productDiscount doubleValue]];
            productDiscountLabel.text = discountStr;
        } else {
            productDiscountLabel.hidden = YES;
        }
    }
    
    //进货单或出货单 当价格为0时显示赠品
    if (enumCurrentManifestType == kJCHOrderShipment || enumCurrentManifestType == kJCHOrderPurchases) {
        if ([cellData.productPrice doubleValue] == 0) {
            presentMarkLabel.hidden = NO;
        } else {
            presentMarkLabel.hidden = YES;
        }
        
        if (cellData.isLastEditedItem) {
            productCountLabel.textColor = JCHColorHeaderBackground;
        } else {
            productCountLabel.textColor = JCHColorMainBody;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (enumCurrentManifestType == kJCHOrderShipment) {
        [self layoutShipmentSubviews];
    } else if (enumCurrentManifestType == kJCHOrderPurchases) {
        [self layoutPurchaseSubviews];
    }
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)layoutShipmentSubviews
{
    CGFloat priceLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:78.0f];
    CGFloat currentkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:8.0f];
    CGFloat productLogoImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    CGFloat productLogoImageViewTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:12.0f];
    
    [productLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(productLogoImageViewTopOffset);
        make.width.mas_equalTo(productLogoImageViewWidth);
        make.height.mas_equalTo(productLogoImageViewWidth);
    }];
    
    [productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_right).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    [productSKUValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(productNameLabel.mas_bottom).with.offset([JCHSizeUtility calculateWidthWithSourceWidth:5.0f]);
        make.height.mas_equalTo(skuTypeLabelHeight);
    }];
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-(priceLabelWidth * 2 + kStandardRightMargin));
        make.width.mas_equalTo(priceLabelWidth);
        make.top.equalTo(productPriceLabel);
        make.height.equalTo(productPriceLabel);
    }];
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productCountLabel.mas_right);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
        make.width.mas_equalTo(priceLabelWidth);
    }];
    
    [productDiscountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(productPriceLabel.mas_right);
        make.top.equalTo(productSKUValueLabel);
        make.height.mas_equalTo(productSKUValueLabel);
        make.width.mas_equalTo(priceLabelWidth);
    }];
    
    [totalAmountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
        make.width.mas_equalTo(priceLabelWidth);
    }];
    
    [presentMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(productDiscountLabel);
    }];
    
    
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin / 2);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin / 2);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)layoutPurchaseSubviews
{
    CGFloat priceLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:78.0f];
    CGFloat currentkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:8.0f];
    CGFloat productLogoImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    CGFloat productLogoImageViewTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:12.0f];
    CGFloat currentStandardRightMargin = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    
    [productLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(productLogoImageViewTopOffset);
        make.width.mas_equalTo(productLogoImageViewWidth);
        make.height.mas_equalTo(productLogoImageViewWidth);
    }];
    
    [productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_right).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    [productSKUValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(productNameLabel.mas_bottom).with.offset([JCHSizeUtility calculateWidthWithSourceWidth:5.0f]);
        make.height.mas_equalTo(skuTypeLabelHeight);
    }];
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(additionalLabel ? additionalLabel.mas_right : productNameLabel.mas_right);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
        make.width.mas_equalTo(priceLabelWidth);
    }];
    
    [productDiscountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self.contentView).with.offset(-currentStandardRightMargin);
        make.top.equalTo(productSKUValueLabel);
        make.height.mas_equalTo(productSKUValueLabel);
    }];
    
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self.contentView).with.offset(-currentStandardRightMargin);
        make.top.equalTo(productPriceLabel);
        make.height.equalTo(productPriceLabel);
    }];
    
    
    [presentMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(productDiscountLabel);
    }];
    
    
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin / 2);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin / 2);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

@end

