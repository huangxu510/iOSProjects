//
//  JCHAnalysePurchaseFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalysePurchaseFooterView.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"

@interface JCHAnalysePurchaseFooterView ()
{
    UILabel *_amountLabel;
    UILabel *_profitRateLabel;
    JCHAnalyseType _enumAnalyseType;
}
@end

@implementation JCHAnalysePurchaseFooterView

- (instancetype)initWithFrame:(CGRect)frame analyseType:(JCHAnalyseType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _enumAnalyseType = type;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)createUI
{
    UIView *topLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSeparateLineWidth)] autorelease];
    topLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:topLine];
    
    if (_enumAnalyseType == kJCHAnalyseProfit) {
        
        UIFont *titleFont = [UIFont systemFontOfSize:14];
        UILabel *amountTitleLabel = [JCHUIFactory createLabel:CGRectMake(0, 0, self.frame.size.width * 0.35 , self.frame.size.height)
                                                  title:@"区间内合计:"
                                                   font:titleFont
                                              textColor:JCHColorAuxiliary
                                                 aligin:NSTextAlignmentRight];
        [self addSubview:amountTitleLabel];
        
        _amountLabel = [JCHUIFactory createLabel:CGRectMake(self.frame.size.width * 0.35, 0, self.frame.size.width * 0.3, self.frame.size.height)
                                           title:@" ¥ 0.00"
                                            font:titleFont
                                       textColor:JCHColorHeaderBackground
                                          aligin:NSTextAlignmentLeft];
        [self addSubview:_amountLabel];
        
        UILabel *profitRateTitleLabel = [JCHUIFactory createLabel:CGRectMake(self.frame.size.width * 0.65, 0, self.frame.size.width * 0.15, self.frame.size.height)
                                                        title:@"毛利率: "
                                                         font:titleFont
                                                    textColor:JCHColorAuxiliary
                                                       aligin:NSTextAlignmentRight];
        [self addSubview:profitRateTitleLabel];
        _profitRateLabel = [JCHUIFactory createLabel:CGRectMake(self.frame.size.width * 0.8, 0, self.frame.size.width * 0.2, self.frame.size.height)
                                               title:@"%0.00"
                                                font:titleFont
                                           textColor:JCHColorHeaderBackground
                                              aligin:NSTextAlignmentLeft];
        [self addSubview:_profitRateLabel];
        
        
    }
    else
    {
        UIFont *titleFont = [UIFont systemFontOfSize:17];
       
        
        _amountLabel = [JCHUIFactory createLabel:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                                          title:@" ¥ 0.00"
                                           font:titleFont
                                      textColor:JCHColorHeaderBackground
                                         aligin:NSTextAlignmentCenter];
        [self addSubview:_amountLabel];
    }
    [self setData:@"0.00" profitRate:@"0.00"];
}

- (void)setData:(NSString *)amount profitRate:(NSString *)rate
{
    NSMutableAttributedString *value = nil;
    if (_enumAnalyseType == kJCHAnalyseShipment) {
        value  = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"区间内合计:¥%@", amount] attributes:@{NSForegroundColorAttributeName : JCHColorHeaderBackground, NSFontAttributeName : [UIFont systemFontOfSize:17.0f]}] autorelease];
        [value setAttributes:@{NSForegroundColorAttributeName : JCHColorAuxiliary, NSFontAttributeName : [UIFont systemFontOfSize:17.0f]} range:NSMakeRange(0, 6)];
        _amountLabel.attributedText = value;
    }
    else if (_enumAnalyseType == kJCHAnalysePurchase)
    {
        value  = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"区间内合计:¥%@", amount] attributes:@{NSForegroundColorAttributeName : JCHColorHeaderBackground, NSFontAttributeName : [UIFont systemFontOfSize:17.0f]}] autorelease];
        [value setAttributes:@{NSForegroundColorAttributeName : JCHColorAuxiliary, NSFontAttributeName : [UIFont systemFontOfSize:17.0f]} range:NSMakeRange(0, 6)];
        _amountLabel.attributedText = value;
    }
    else
    {
        _amountLabel.text = [NSString stringWithFormat:@"¥%@", amount];
    }
    

    
    if (rate) {
        _profitRateLabel.text = [NSString stringWithFormat:@"%@ %%", rate];
    }
}

@end
