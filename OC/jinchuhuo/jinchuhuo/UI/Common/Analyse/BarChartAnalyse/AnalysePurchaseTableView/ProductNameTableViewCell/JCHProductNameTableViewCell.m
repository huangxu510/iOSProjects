//
//  JCHProductNameTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductNameTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"

@implementation JCHProductNameTableViewCellData

- (void)dealloc
{
    [self.productPurchaseAmount release];
    [self.productName release];
    [self.productCount release];
    
    [super dealloc];
}

@end

@interface JCHProductNameTableViewCell ()
{
    UILabel *_productNameLabel;
    UILabel *_productCountLabel;
    UILabel *_productPurchaseAmount;
}
@end

@implementation JCHProductNameTableViewCell


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
    
    const CGFloat leftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    CGFloat labelHeight = iPhone4 ? 30 : 35;
    
    _productNameLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, kScreenWidth  * 0.4 , labelHeight)
                                                title:@"香蕉/单位:斤"
                                                 font:titleFont
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
    _productNameLabel.numberOfLines = 2;
    [self.contentView addSubview:_productNameLabel];
    
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.4 + leftMargin, 0, kScreenWidth * 0.3 - leftMargin, labelHeight)
                                             title:@"66"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:_productCountLabel];
    
    
    _productPurchaseAmount = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 2 / 3, 0, kScreenWidth / 3 - leftMargin, labelHeight)
                                                 title:@"¥ 1288.00"
                                                  font:titleFont
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_productPurchaseAmount];
}

- (void)setData:(JCHProductNameTableViewCellData *)data
{
    //根据商品名称长度适当调小字体
    CGRect rect = [data.productName boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil];
    if (rect.size.width > _productNameLabel.frame.size.width) {
        _productNameLabel.font = [UIFont systemFontOfSize:11];
    }
    _productNameLabel.text = data.productName;
    _productCountLabel.text = data.productCount;
    _productPurchaseAmount.text = data.productPurchaseAmount;
}

@end
