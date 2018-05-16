//
//  JCHTradeDateTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHTradeDateTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"


@implementation JCHTradeDateTableViewCellData

- (void)dealloc
{
    [self.productDate release];
    [self.productPurchaseAmount release];
    
    [super dealloc];
}

@end

@interface JCHTradeDateTableViewCell ()
{
    UILabel *_dateLabel;
    UILabel *_amountLabel;
}
@end

@implementation JCHTradeDateTableViewCell

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

    
    _dateLabel = [JCHUIFactory createLabel:CGRectMake(leftMargin, 0, kScreenWidth / 2 - leftMargin, labelHeight)
                                     title:@"2015-10-20"
                                      font:titleFont
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_dateLabel];
    
    _amountLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth / 2, 0, kScreenWidth / 2 - leftMargin, labelHeight)
                                       title:@"¥ 1288.00"
                                        font:titleFont
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_amountLabel];
}

- (void)setData:(JCHTradeDateTableViewCellData *)data
{
    _dateLabel.text = data.productDate;
    _amountLabel.text = data.productPurchaseAmount;
}

@end
