//
//  JCHAnalyseInventoryMiddleView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalyseInventoryMiddleView.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "UIFont+JCHFont.h"

@implementation JCHAnalyseInventoryMiddleViewData

- (void)dealloc
{
    [self.categoryName release];
    [self.amount release];
    [self.rate release];
    
    [super dealloc];
}

@end


@interface JCHAnalyseInventoryMiddleView ()
{
    UILabel *_categoryNameLabel;
    UILabel *_amountLabel;
    UILabel *_rateLabel;
}
@end

@implementation JCHAnalyseInventoryMiddleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:14.0f];
    
    _categoryNameLabel = [JCHUIFactory createLabel:CGRectMake(0, 0, kWidth / 4, kHeight)
                                             title:@"分类:"
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentCenter];
    [self addSubview:_categoryNameLabel];
    
    _amountLabel = [JCHUIFactory createLabel:CGRectMake(kWidth / 4, 0, kWidth / 2, kHeight)
                                       title:@"金额:"
                                        font:titleFont
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentCenter];
    [self addSubview:_amountLabel];
    
    _rateLabel = [JCHUIFactory createLabel:CGRectMake(kWidth * 3 / 4, 0, kWidth / 4, kHeight)
                                       title:@"占比:"
                                        font:titleFont
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentCenter];
    [self addSubview:_rateLabel];
    
    UIView *bottomLine = [[[UIView alloc] initWithFrame:CGRectMake(0, kHeight - kSeparateLineWidth, kWidth, kSeparateLineWidth)] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
}

- (void)setData:(JCHAnalyseInventoryMiddleViewData *)data
{
    NSString *categoryText = [NSString stringWithFormat:@"分类: %@", data.categoryName];
    _categoryNameLabel.text = categoryText;
    
    UIFont *titleFont = [UIFont jchSystemFontOfSize:14.0f];
    NSString *amount = [NSString stringWithFormat:@"¥ %@", data.amount];
    NSMutableAttributedString *amountText = [[[NSMutableAttributedString alloc] initWithString:amount attributes:@{NSFontAttributeName : titleFont, NSForegroundColorAttributeName : JCHColorHeaderBackground}] autorelease];
    NSAttributedString *amountTitle = [[[NSAttributedString alloc] initWithString:@"金额: " attributes:@{NSFontAttributeName : titleFont, NSForegroundColorAttributeName : JCHColorMainBody}] autorelease];
    [amountText insertAttributedString:amountTitle atIndex:0];
    [_amountLabel setAttributedText:amountText];
    
    NSString *rateText = [NSString stringWithFormat:@"占比: %@", data.rate];
    _rateLabel.text = rateText;
}

@end

