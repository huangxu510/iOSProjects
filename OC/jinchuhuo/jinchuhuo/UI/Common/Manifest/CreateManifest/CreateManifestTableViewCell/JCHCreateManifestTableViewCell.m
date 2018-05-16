//
//  JCHCreateManifestTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHCreateManifestTableViewCell.h"
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

@implementation JCHCreateManifestTableViewCellData

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
    self.productProperty = nil;
    
    [super dealloc];
    return;
}

@end


@interface JCHCreateManifestTableViewCell ()
{
    JCHLabel *productNameLabel;
    UIImageView *productLogoImageView;
    UILabel *additionalLabel;
    UILabel *productCountLabel;
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

@implementation JCHCreateManifestTableViewCell

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
    
    if (enumCurrentManifestType == kJCHManifestMaterialWastage) {
        
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
                                                title:@"数量"
                                                 font:priceFont
                                            textColor:titleColor
                                               aligin:NSTextAlignmentRight];
        productCountLabel.adjustsFontSizeToFitWidth = YES;

        [self.contentView addSubview:productCountLabel];
    }
    
    {
        productDiscountLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"折扣"
                                                    font:titleFont
                                               textColor:UIColorFromRGB(0xff9532)
                                                  aligin:NSTextAlignmentRight];
        productDiscountLabel.hidden = YES;
        productDiscountLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:productDiscountLabel];
    }
    
    {
        productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单价"
                                                 font:priceFont
                                            textColor:JCHColorHeaderBackground
                                               aligin:NSTextAlignmentRight];
        productPriceLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:productPriceLabel];
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
    
    if (enumCurrentManifestType == kJCHOrderShipment || enumCurrentManifestType == kJCHOrderPurchases || enumCurrentManifestType == kJCHRestaurntManifestOpenTable) {
        self.showMenuButton.hidden = YES;
    } else if (enumCurrentManifestType == kJCHManifestInventory) {
        productCountLabel.textColor = JCHColorPriceText;
        productPriceLabel.textColor = JCHColorPriceText;
    } else if (enumCurrentManifestType == kJCHManifestMaterialWastage) {
        productCountLabel.textColor = JCHColorPriceText;
        productPriceLabel.textColor = JCHColorPriceText;
    } else if (enumCurrentManifestType == kJCHManifestMigrate) {
        productCountLabel.textColor = JCHColorPriceText;
    }
}


- (void)setData:(JCHCreateManifestTableViewCellData *)cellData
{
    productNameLabel.text = cellData.productName;
    productCountLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productCount, cellData.productUnit];
    productPriceLabel.text = [NSString stringWithFormat:@"¥%@", cellData.productPrice];
    productLogoImageView.image = [UIImage jchProductImageNamed:cellData.productImageName];
    
    if (!cellData.productProperty) {
        cellData.productProperty = @"";
    }
    if (![cellData.productSKUValueCombine isEmptyString] || ![cellData.productProperty isEmptyString]) {
        NSString *middleSymbol = @"";
        if (![cellData.productSKUValueCombine isEmptyString] && ![cellData.productProperty isEmptyString]) {
            middleSymbol = @";";
        }
        NSString *skuAndPropertyText = [NSString stringWithFormat:@"%@%@%@", cellData.productSKUValueCombine, middleSymbol, cellData.productProperty];
        productSKUValueLabel.text = skuAndPropertyText;
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
    
    if (enumCurrentManifestType == kJCHManifestMaterialWastage) {
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
#if 0
    CGFloat skuTypeLabelHeightOffset = 0;
    if (skuTypeLabelHeight > [JCHSizeUtility calculateWidthWithSourceWidth:30.0f]) {
        skuTypeLabelHeightOffset = skuTypeLabelHeight - [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    }
    self.cellHeight = [JCHSizeUtility calculateWidthWithSourceWidth:74.0f] + skuTypeLabelHeightOffset;
#endif
    
    if (enumCurrentManifestType == kJCHOrderShipment || enumCurrentManifestType == kJCHRestaurntManifestOpenTable) {
        
        if ([cellData.productDiscount doubleValue] != 1 && [cellData.productPrice doubleValue] != 0) {
            productDiscountLabel.hidden = NO;
            NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:[cellData.productDiscount doubleValue]];
            productDiscountLabel.text = discountStr;
        } else {
            productDiscountLabel.hidden = YES;
        }
    }
    
    
    
    
    //进货单或出货单 当价格为0时显示赠品
    if (enumCurrentManifestType == kJCHOrderShipment || enumCurrentManifestType == kJCHOrderPurchases || enumCurrentManifestType == kJCHRestaurntManifestOpenTable) {
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
    } else if (enumCurrentManifestType == kJCHManifestInventory) {
        
        //盘后数量
        additionalLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productCount, cellData.productUnit];
        
        //盈亏数量
        productPriceLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productIncreaseCount, cellData.productUnit];
        //成本价
        productCountLabel.text = [NSString stringWithFormat:@"¥%@", cellData.productPrice];
    } else if (enumCurrentManifestType == kJCHManifestAssembling) {

        productCountLabel.textColor = JCHColorHeaderBackground;
        if (isManifestDetail) {
            productCountLabel.text = cellData.mainAuxiliaryUnitCountInfo;
        }
    } else if (enumCurrentManifestType == kJCHManifestDismounting) {
        productCountLabel.textColor = JCHColorHeaderBackground;
    } else if (enumCurrentManifestType == kJCHManifestMaterialWastage) {
        
        //盘后数量
        additionalLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productCount, cellData.productUnit];
        
        //盈亏数量
        productPriceLabel.text = [NSString stringWithFormat:@"%@%@", cellData.productIncreaseCount, cellData.productUnit];
        //成本价
        productCountLabel.text = [NSString stringWithFormat:@"¥%@", cellData.productPrice];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (enumCurrentManifestType == kJCHOrderShipment) {
        [self layoutShipmentSubviews];
    } else if (enumCurrentManifestType == kJCHOrderPurchases) {
        [self layoutPurchaseSubviews];
    } else if (enumCurrentManifestType == kJCHManifestInventory) {
        [self layoutInventorySubviews];
    } else if (enumCurrentManifestType == kJCHManifestMigrate) {
        [self layoutMigrageSubviews];
    } else if (enumCurrentManifestType == kJCHManifestAssembling) {
        [self layoutAssemblingSubviews];
    } else if (enumCurrentManifestType == kJCHManifestDismounting) {
        [self layoutDismoutingSubviews];
    } else if (enumCurrentManifestType == kJCHManifestMaterialWastage) {
        [self layoutInventorySubviews];
    } else if (enumCurrentManifestType == kJCHRestaurntManifestOpenTable) {
        [self layoutShipmentSubviews];
    }
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)layoutShipmentSubviews
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
        make.right.equalTo(productPriceLabel.mas_right);
        make.top.equalTo(productSKUValueLabel);
        make.height.mas_equalTo(productSKUValueLabel);
        make.width.mas_equalTo(priceLabelWidth);
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

- (void)layoutInventorySubviews
{
    CGFloat currentkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:8.0f];
    CGFloat productLogoImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    CGFloat productLogoImageViewTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:12.0f];
    CGFloat currentStandardRightMargin = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    CGFloat nameLabelRightOffset = [JCHSizeUtility calculateWidthWithSourceWidth:30.0f];
    CGFloat priceLabelWidth = (kScreenWidth / 2 + nameLabelRightOffset - 1.5 * currentStandardRightMargin) / 3;
    
    
    [productLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(productLogoImageViewTopOffset);
        make.width.mas_equalTo(productLogoImageViewWidth);
        make.height.mas_equalTo(productLogoImageViewWidth);
    }];
    
    
    [productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_right).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-nameLabelRightOffset);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    [productSKUValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(productNameLabel.mas_bottom).with.offset([JCHSizeUtility calculateWidthWithSourceWidth:5.0f]);
        make.height.mas_equalTo(skuTypeLabelHeight);
    }];
    
   
    [additionalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_right).offset(currentStandardRightMargin / 2);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
        make.width.mas_equalTo(priceLabelWidth);
    }];
    
    
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(additionalLabel ? additionalLabel.mas_right : productNameLabel.mas_right);
        make.top.equalTo(productLogoImageView);
        make.height.mas_equalTo(productNameLabelHeight);
        make.width.mas_equalTo(priceLabelWidth);
    }];
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productPriceLabel.mas_right);
        make.right.equalTo(self.contentView).with.offset(-currentStandardRightMargin);
        make.top.equalTo(productPriceLabel);
        make.height.equalTo(productPriceLabel);
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
    
    
    [self.showMenuButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-productLogoImageViewTopOffset);
    }];
}

- (void)layoutMigrageSubviews
{
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
    
    [self.showMenuButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(21);
        make.centerY.equalTo(productLogoImageView);
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
    
    productPriceLabel.hidden = YES;
    productDiscountLabel.hidden = YES;
    
    [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel.mas_right);
        if (isManifestDetail) {
            make.right.equalTo(self.contentView).with.offset(-currentStandardRightMargin);
        } else {
            make.right.equalTo(self.showMenuButton.mas_left).with.offset(-currentStandardRightMargin);
        }
        make.top.bottom.equalTo(self.contentView);
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

- (void)layoutAssemblingSubviews
{
    [self layoutMigrageSubviews];
}

- (void)layoutDismoutingSubviews
{
    [self layoutMigrageSubviews];
}

@end

