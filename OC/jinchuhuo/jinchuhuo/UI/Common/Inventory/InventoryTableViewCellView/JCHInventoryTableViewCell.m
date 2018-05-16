//
//  JCHInventoryTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHInventoryTableViewCell.h"
#import "JCHUISizeSettings.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "UIImage+JCHImage.h"
#import "JCHSyncStatusManager.h"
#import "RoleRecord4Cocoa.h"
#import "JCHPerimissionUtility.h"
#import "Masonry.h"

@implementation InventoryInfo

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
    [self.productLogoName release];
    [self.productName release];
    [self.productPrice release];
    [self.purchasesCount release];
    [self.shipmentCount release];
    [self.inventoryCount release];
    [self.inventoryUnit release];
    
    [super dealloc];
    return;
}

@end





enum {
    kInventoryCellCountLabelWidth = 55,
};






@interface JCHInventoryTableViewCell ()
{
    UIImageView *productLogoImageView;
    UILabel *productNameLabel;
    UILabel *productPriceLabel;
    UILabel *purchasesCountLabel;
    UILabel *shipmentCountLabel;
    UILabel *inventoryCountLabel;
    UIImageView *skuMarkImageView;
}
@end

@implementation JCHInventoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    self.tapBlock = nil;
    
    [super dealloc];
    return;
}

- (void)createUI
{
    UIFont *countLabelFont = [UIFont systemFontOfSize:12.0f];
    UIColor *countLabelColor = JCHColorMainBody;
    CGFloat currentkStandardLeftMargin = 8.0f;
    
    const CGFloat imageWidth = 50.0f;
    const CGFloat imageHeight = imageWidth;
    
    
    productLogoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    productLogoImageView.image = [UIImage imageNamed:@"icon_huo"];
    [self.contentView addSubview:productLogoImageView];
    productLogoImageView.backgroundColor = [UIColor lightGrayColor];
    productLogoImageView.layer.cornerRadius = 3.0f;
    productLogoImageView.clipsToBounds = YES;
    
    [productLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
        make.left.equalTo(self.contentView.mas_left).with.offset(currentkStandardLeftMargin);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productLogoImageViewTapAction:)] autorelease];
    productLogoImageView.userInteractionEnabled = YES;
    [productLogoImageView addGestureRecognizer:tap];
    
    
    productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"aa"
                                            font:[UIFont systemFontOfSize:14.0f]
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    productNameLabel.adjustsFontSizeToFitWidth = NO;
    productNameLabel.numberOfLines = 1;
    [self.contentView addSubview:productNameLabel];
    
    const CGFloat productPriceLabelHeight = 20;
    const CGFloat productNameLabelHeight = 25;
    [productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productLogoImageView.mas_right).with.offset(currentkStandardLeftMargin);
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
        make.top.equalTo(productLogoImageView).with.offset(currentkStandardLeftMargin / 4);
        make.height.mas_equalTo(productNameLabelHeight);
    }];
    
    
    skuMarkImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_multiplespecifications"]] autorelease];
    skuMarkImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:skuMarkImageView];
    
    [skuMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(productNameLabel);
        make.height.mas_equalTo(productPriceLabelHeight);
        make.width.mas_equalTo(17);
        make.bottom.equalTo(productLogoImageView.mas_bottom);
    }];
    
    inventoryCountLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"22"
                                               font:countLabelFont
                                          textColor:countLabelColor
                                             aligin:NSTextAlignmentLeft];
    inventoryCountLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:inventoryCountLabel];
    
    [inventoryCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth / 3);
        make.height.mas_equalTo(productPriceLabelHeight);
        make.left.equalTo(skuMarkImageView.mas_right);
        make.bottom.equalTo(productLogoImageView.mas_bottom);
    }];
    
    productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"00"
                                             font:[UIFont systemFontOfSize:12.0f]
                                        textColor:JCHColorAuxiliary
                                           aligin:NSTextAlignmentLeft];
    productPriceLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:productPriceLabel];
    
    [productPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(inventoryCountLabel.mas_height);
        make.left.equalTo(inventoryCountLabel.mas_right);
        make.right.equalTo(productNameLabel);
        make.bottom.equalTo(inventoryCountLabel.mas_bottom);
    }];
    

    return;
}



- (void)setData:(InventoryInfo *)inventoryInfo
{
    productLogoImageView.image = [UIImage jchProductImageNamed:inventoryInfo.productLogoName];
    productNameLabel.text = inventoryInfo.productName;
    NSUInteger length = [inventoryInfo.productName length];
    
    if (length < 17)
    {
        productNameLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    else
    {
        productNameLabel.font = [UIFont systemFontOfSize:14.0f];
    }

    
    UIFont *priceTitleFont = [UIFont systemFontOfSize:12.0f];
    UIFont *priceFont = [UIFont systemFontOfSize:14.0f];
    NSMutableAttributedString *productPrice = [[[NSMutableAttributedString alloc] initWithString:@"成本价  " attributes:@{NSFontAttributeName : priceTitleFont, NSForegroundColorAttributeName : JCHColorAuxiliary}] autorelease];
    NSAttributedString *price = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@",  inventoryInfo.productPrice] attributes:@{NSFontAttributeName : priceFont, NSForegroundColorAttributeName : JCHColorHeaderBackground}] autorelease];
    [productPrice appendAttributedString:price];

    productPriceLabel.attributedText = productPrice;
    
    NSString *inventoryConut = inventoryInfo.inventoryCount;
    if (inventoryConut.doubleValue < 10) {
        NSMutableAttributedString *inventoryCountString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"库存 %@%@", inventoryConut, inventoryInfo.inventoryUnit] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : JCHColorHeaderBackground}] autorelease];;
        [inventoryCountString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : JCHColorAuxiliary} range:NSMakeRange(0, 2)];

        inventoryCountLabel.attributedText = inventoryCountString;
    }
    else
    {
        inventoryCountLabel.text = [NSString stringWithFormat:@"库存 %@%@", inventoryConut, inventoryInfo.inventoryUnit];
        inventoryCountLabel.textColor = JCHColorAuxiliary;
    }

    if ([JCHPerimissionUtility displayCostPrice]) {
        productPriceLabel.hidden = NO;
    } else {
        productPriceLabel.hidden = YES;
    }
    
    if (inventoryInfo.isSKUProduct) {
        [skuMarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(17);
        }];
        skuMarkImageView.hidden = NO;
        [inventoryCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo((kScreenWidth / 3) - 17);
        }];
    } else {
        [skuMarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        skuMarkImageView.hidden = YES;
        [inventoryCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kScreenWidth / 3);
        }];
    }
    
    return;
}

- (void)productLogoImageViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

@end
