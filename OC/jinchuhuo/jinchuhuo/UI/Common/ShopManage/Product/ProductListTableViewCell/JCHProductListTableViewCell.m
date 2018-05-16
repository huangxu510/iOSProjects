//
//  JCHProductListTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductListTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import <Masonry.h>
#import "CommonHeader.h"

@implementation ProductInfo

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
    [self.productPrice release];
    [self.inventoryCount release];
    [self.inventoryUnit release];
    [self.productType release];
    
    [super dealloc];
    return;
}

@end


@interface JCHProductListTableViewCell ()
{
    UILabel *_productNameLabel;
    UILabel *_productPriceLabel;
    UIView *_bottomLine;
    UIImageView *_skuMarkImageView;
    UIButton *_putawayButton;
    UIButton *_soldoutButton;
}
@end

@implementation JCHProductListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"aa"
                                                 font:[UIFont systemFontOfSize:16.0f]
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
        _productNameLabel.adjustsFontSizeToFitWidth = NO;
        _productNameLabel.numberOfLines = 2;
        [self.contentView addSubview:_productNameLabel];
        
        CGFloat heightOffset = 8.0f;
        
        const CGFloat productPriceLabelHeight = 15;
        const CGFloat productNameLabelHeight = 36;
        
        [_productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
            make.right.equalTo(_goTopButton.mas_left);
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(productNameLabelHeight);
        }];
        
        _skuMarkImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_multiplespecifications"]] autorelease];
        _skuMarkImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_skuMarkImageView];
        
        [_skuMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_productNameLabel);
            make.height.mas_equalTo(productPriceLabelHeight);
            make.width.mas_equalTo(17);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-heightOffset);
        }];
        
        _productPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"00"
                                                  font:[UIFont systemFontOfSize:13.0f]
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentLeft];
        _productPriceLabel.adjustsFontSizeToFitWidth = NO;
        [self.contentView addSubview:_productPriceLabel];
        
        
        [_productPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_productNameLabel);
            make.height.mas_equalTo(productPriceLabelHeight);
            make.left.equalTo(_skuMarkImageView.mas_right);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-heightOffset);
        }];
        
#if MMR_TAKEOUT_VERSION
        
        // 外卖版 有上架下架按钮
        
        CGFloat buttonWidth = 50;
        CGFloat buttonHeight = 27;
        
        _putawayButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(handlePutaway:)
                                              title:@"上架"
                                         titleColor:JCHColorHeaderBackground
                                    backgroundColor:[UIColor whiteColor]];
        _putawayButton.layer.borderColor = JCHColorHeaderBackground.CGColor;
        _putawayButton.layer.borderWidth = 0.5;
        _putawayButton.layer.cornerRadius = 5;
        _putawayButton.clipsToBounds = YES;
        _putawayButton.titleLabel.font = JCHFont(13);
        [self.contentView addSubview:_putawayButton];
        
        [_putawayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(-kStandardLeftMargin);
            make.width.mas_equalTo(buttonWidth);
            make.height.mas_equalTo(buttonHeight);
            make.centerY.equalTo(self.contentView);
        }];
        
        _soldoutButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(handleSoldout:)
                                              title:@"下架"
                                         titleColor:JCHColorMainBody
                                    backgroundColor:[UIColor whiteColor]];
        _soldoutButton.layer.borderColor = JCHColorMainBody.CGColor;
        _soldoutButton.layer.borderWidth = 0.5;
        _soldoutButton.layer.cornerRadius = 5;
        _soldoutButton.clipsToBounds = YES;
        _soldoutButton.titleLabel.font = JCHFont(13);
        [self.contentView addSubview:_soldoutButton];
        
        [_soldoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_putawayButton.mas_left).offset(-kStandardLeftMargin);
            make.width.mas_equalTo(buttonWidth);
            make.height.mas_equalTo(buttonHeight);
            make.centerY.equalTo(self.contentView);
        }];
        
        [_productNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            //        make.right.equalTo(_soldoutButton.mas_left).offset(-kStandardLeftMargin / 2);
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
            make.right.equalTo(_soldoutButton.mas_left).offset(-kStandardLeftMargin / 2);
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(productNameLabelHeight);
        }];
        [_putawayButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [_soldoutButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
#endif
    }
    

    return self;
}

- (void)dealloc
{
    self.putawayBlock = nil;
    self.soldoutBlock = nil;
    
    [super dealloc];
}


- (void)setData:(ProductInfo *)productInfo
{
    _productNameLabel.text = productInfo.productName;
    
    CGFloat gotoTopButtonWidth = kStandardItemHeight;
    CGFloat productNameLabelWidth = kScreenWidth - 2 * kStandardLeftMargin - gotoTopButtonWidth - 10;
    CGRect rect = [productInfo.productName boundingRectWithSize:CGSizeMake(1000, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]} context:nil];
    if (rect.size.width > productNameLabelWidth) {
        _productNameLabel.font = [UIFont systemFontOfSize:13];
    }
    else
    {
        _productNameLabel.font = [UIFont systemFontOfSize:16];
    }
    
    
    UIFont *priceTitleFont = [UIFont systemFontOfSize:13];
    UIFont *symbolFont = [UIFont systemFontOfSize:10];
    NSMutableAttributedString *productPrice = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"销售价%@", productInfo.productPrice] attributes:@{NSFontAttributeName : priceTitleFont}] autorelease];
    NSAttributedString *symbol = [[[NSAttributedString alloc] initWithString:@" ¥ " attributes:@{NSFontAttributeName : symbolFont}] autorelease];
    [productPrice insertAttributedString:symbol atIndex:3];
    _productPriceLabel.attributedText = productPrice;
    
    if (productInfo.sku_hidden_flag) {
        [_skuMarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        _skuMarkImageView.hidden = YES;
    } else {
        [_skuMarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(17);
        }];
        _skuMarkImageView.hidden = NO;
    }
    
    return;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
#if MMR_TAKEOUT_VERSION
    _putawayButton.hidden = editing;
    _soldoutButton.hidden = editing;
#endif
}

- (void)handlePutaway:(UIButton *)sender
{
    if (self.putawayBlock) {
        self.putawayBlock();
    }
}

- (void)handleSoldout:(UIButton *)sender
{
    if (self.soldoutBlock) {
        self.soldoutBlock();
    }
}


@end
