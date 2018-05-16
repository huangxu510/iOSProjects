//
//  JCHProfitTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProfitTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"

@implementation JCHProfitTableViewCellData

- (void)dealloc
{
    [self.productCategory release];
    [self.productSaleAmount release];
    [self.productProfitAmount release];
    [self.productProfitRate release];
    
    [super dealloc];
}

@end
@interface JCHProfitTableViewCell ()
{
    UILabel *_categoryLabel;
    UILabel *_saleAmountLabel;
    UILabel *_profitAmountLabel;
    UILabel *_profitRateLabel;
}
@end
@implementation JCHProfitTableViewCell


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
    const CGFloat leftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:15.0f];
    
    _categoryLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, kScreenWidth * 0.25, labelHeight)
                                            title:@"水果"
                                             font:titleFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    _categoryLabel.numberOfLines = 2;
    [self.contentView addSubview:_categoryLabel];
    
    
    _saleAmountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.25 + leftMargin, 0, kScreenWidth * 0.225, labelHeight)
                                             title:@"¥1288.00"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_saleAmountLabel];
    
    
    _profitAmountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.475 + leftMargin, 0, kScreenWidth * 0.225, labelHeight)
                                                 title:@"¥ 288.00"
                                                  font:titleFont
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_profitAmountLabel];
    
    _profitRateLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth * 0.7 + leftMargin, 0, kScreenWidth * 0.3 - 2 * leftMargin, labelHeight)
                                             title:@"20.45%"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_profitRateLabel];
}

- (void)setData:(JCHProfitTableViewCellData *)data
{

    CGRect rect = [data.productCategory boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont jchSystemFontOfSize:13]} context:nil];
    if (rect.size.width > _categoryLabel.frame.size.width) {
        _categoryLabel.font = [UIFont jchSystemFontOfSize:11];
    }
    
    _categoryLabel.text = data.productCategory;
    _saleAmountLabel.text = data.productSaleAmount;
    _profitAmountLabel.text = data.productProfitAmount;
    _profitRateLabel.text = data.productProfitRate;
}

@end
