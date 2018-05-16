//
//  JCHProductCategoryTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductCategoryTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"



@implementation JCHProductCategoryTableViewCellData

- (void)dealloc
{
    [self.productCategory release];
    [self.productCount release];
    [self.productPurchaseAmount release];
    
    [super dealloc];
}

@end

@interface JCHProductCategoryTableViewCell ()
{
    UILabel *_productCategoryLabel;
    UILabel *_productCountLabel;
    UILabel *_productPurchaseAmountLabel;
}
@end

@implementation JCHProductCategoryTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:13.0f];
    CGFloat labelHeight = iPhone4 ? 30 : 35;
    const CGFloat leftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    
    _productCategoryLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, kScreenWidth / 3 - leftMargin, labelHeight)
                                     title:@"水果"
                                      font:titleFont
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_productCategoryLabel];
    
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth / 3, 0, kScreenWidth / 3, labelHeight)
                                             title:@"66"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:_productCountLabel];
    
    
    _productPurchaseAmountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 2 / 3, 0, kScreenWidth / 3 - leftMargin, labelHeight)
                                       title:@"¥ 1288.00"
                                        font:titleFont
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_productPurchaseAmountLabel];
}

- (void)setData:(JCHProductCategoryTableViewCellData *)data
{
    _productCategoryLabel.text = data.productCategory;
    _productCountLabel.text = data.productCount;
    _productPurchaseAmountLabel.text = data.productPurchaseAmount;
}

@end
