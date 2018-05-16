//
//  JCHAnaluseInventoryTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalyseInventoryTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"

@implementation JCHAnalyseInventoryTableViewCellData

- (void)dealloc
{
    [self.productName release];
    [self.productCount release];
    [self.productAmount release];
    [self.productRate release];
    
    [super dealloc];
}

@end

@interface JCHAnalyseInventoryTableViewCell ()
{
    UILabel *_productNameLabel;
    UILabel *_productCountLabel;
    UILabel *_productAmountLable;
    UILabel *_productRateLabel;
}
@end

@implementation JCHAnalyseInventoryTableViewCell

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
    UIFont *titleFont = [UIFont systemFontOfSize:13.0f];
    
    CGFloat leftMargin = 20;
    CGFloat labelWidth = (kScreenWidth - 2 * leftMargin) / 4;
    const CGFloat labelHeight = iPhone4 ? 30 : 35;
    
    _productNameLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, labelWidth + leftMargin, labelHeight)
                                                    title:@"商品名称"
                                                     font:titleFont
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    _productNameLabel.numberOfLines = 2;
    [self addSubview:_productNameLabel];
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectMake(labelWidth + leftMargin * 2, 0, labelWidth - leftMargin / 2, labelHeight)
                                                title:@"数量"
                                                 font:titleFont
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentCenter];
    [self addSubview:_productCountLabel];
    
    _productAmountLable = [JCHUIFactory createLabel:CGRectMake(labelWidth * 2 + leftMargin * 1.5, 0, labelWidth, labelHeight)
                                               title:@"库存金额"
                                                font:titleFont
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentRight];
    [self addSubview:_productAmountLable];
    
    _productRateLabel = [JCHUIFactory createLabel:CGRectMake(labelWidth * 3 + leftMargin * 1.5, 0, labelWidth - leftMargin / 2, labelHeight)
                                                   title:@"占比(%)"
                                                    font:titleFont
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentRight];
    [self addSubview:_productRateLabel];
}

- (void)setData:(JCHAnalyseInventoryTableViewCellData *)data
{
    CGRect rect = [data.productName boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f]} context:nil];
    if (rect.size.width > _productNameLabel.frame.size.width) {
        _productNameLabel.font = [UIFont systemFontOfSize:11];
    } else {
        _productNameLabel.font = [UIFont systemFontOfSize:13];
    }
    _productNameLabel.text = data.productName;
    _productCountLabel.text = data.productCount;
    _productAmountLable.text = data.productAmount;
    _productRateLabel.text = data.productRate;
}

@end
