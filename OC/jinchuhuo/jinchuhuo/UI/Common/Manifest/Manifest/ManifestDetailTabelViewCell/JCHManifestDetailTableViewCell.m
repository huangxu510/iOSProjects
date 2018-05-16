//
//  ManifestDetailTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestDetailTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "Masonry.h"

enum {
    kCreateManifestCellCountLabelWidth = 60,
};

@implementation JCHManifestDetailTableViewCellData

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
    
    [super dealloc];
    return;
}

@end


@interface JCHManifestDetailTableViewCell ()
{
    UILabel *productNameLabel;
    UIImageView *productLogoImageView;
    UILabel *productCountLabel;
    UILabel *productDiscountLabel;
    UILabel *productPriceLabel;
    UIView *bottomLine;
    enum JCHOrderType enumCurrentManifestType;
}
@end

@implementation JCHManifestDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        enumCurrentManifestType = manifestType;
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
    UIFont *titleFont = [UIFont jchSystemFontOfSize:14.0f];
    UIColor *titleColor = JCHColorMainBody;
    {
        productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"商品名称"
                                                font:[UIFont jchSystemFontOfSize:12.0f]
                                           textColor:titleColor
                                              aligin:NSTextAlignmentLeft];
        productNameLabel.numberOfLines = 3;
        [self.contentView addSubview:productNameLabel];
    }
    
    {
        productLogoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        productLogoImageView.image = [UIImage imageNamed:@"icon_chu"];
        productLogoImageView.layer.cornerRadius = 3.0f;
        productLogoImageView.clipsToBounds = YES;
        [self.contentView addSubview:productLogoImageView];
        productLogoImageView.backgroundColor = [UIColor lightGrayColor];
    }
    
    {
        productCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"数量"
                                                 font:titleFont
                                            textColor:titleColor
                                               aligin:NSTextAlignmentCenter];
        
        [self.contentView addSubview:productCountLabel];
    }
    
    if (enumCurrentManifestType == kJCHOrderShipment)
    {
        productDiscountLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"折扣"
                                                    font:titleFont
                                               textColor:titleColor
                                                  aligin:NSTextAlignmentCenter];
        [self.contentView addSubview:productDiscountLabel];
    }
    
    {
        productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"单价"
                                                 font:titleFont
                                            textColor:JCHColorPriceText
                                               aligin:NSTextAlignmentRight];
        [self.contentView addSubview:productPriceLabel];
    }
    
    {
        bottomLine = [[[UIView alloc] init] autorelease];
        bottomLine.backgroundColor = JCHColorSeparateLine;
        [self.contentView addSubview:bottomLine];
    }
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat countLabelWidth = 0;
    if ((enumCurrentManifestType == kJCHOrderPurchases) ||
        (enumCurrentManifestType == kJCHOrderPurchasesReject) ||
        (enumCurrentManifestType == kJCHOrderShipmentReject))
    {
        countLabelWidth = 60;
    }
    else
    {
        countLabelWidth = 50;
    }
    CGFloat currentCreateManifestCellCountLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:countLabelWidth];
    CGFloat currentkStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:11.5f];
    
    
    CGFloat productLogoImageViewWidth = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:43];
    
   
    [productPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-currentkStandardLeftMargin);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.mas_equalTo(currentCreateManifestCellCountLabelWidth * 1.2);
    }];

    if (enumCurrentManifestType == kJCHOrderShipment)
    {
        [productDiscountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(productPriceLabel.mas_left);//.with.offset(-1.3 * currentkStandardLeftMargin);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.width.mas_equalTo(currentCreateManifestCellCountLabelWidth);
        }];
        
        [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(productDiscountLabel.mas_left);//.with.offset(-currentkStandardLeftMargin / 2);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.width.mas_equalTo(currentCreateManifestCellCountLabelWidth);
        }];
        
    }
    else if ((enumCurrentManifestType == kJCHOrderPurchases) ||
             (enumCurrentManifestType == kJCHOrderPurchasesReject) ||
             (enumCurrentManifestType == kJCHOrderShipmentReject))
    {
        [productCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(productPriceLabel.mas_left);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.width.mas_equalTo(currentCreateManifestCellCountLabelWidth);
        }];
        
    }
    
    
    
    [productLogoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(productLogoImageViewWidth);
        make.height.mas_equalTo(productLogoImageViewWidth);
    }];
    
    
    [productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(productCountLabel.mas_left).with.offset(-0.5 * currentkStandardLeftMargin);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(productLogoImageView.mas_right).with.offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:5.0f]);
    }];
    
    if (self.isLastCell)
    {
        [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    else
    {
        [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(productLogoImageView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    
    return;
}

- (void)setData:(JCHManifestDetailTableViewCellData *)cellData
{
    productNameLabel.text = cellData.productName;
    productCountLabel.text = cellData.productCount;
    productDiscountLabel.text = cellData.productDiscount;
    productPriceLabel.text = cellData.productPrice;
    productLogoImageView.image = [UIImage jchProductImageNamed:cellData.productImageName];
    
    return;
}


@end

