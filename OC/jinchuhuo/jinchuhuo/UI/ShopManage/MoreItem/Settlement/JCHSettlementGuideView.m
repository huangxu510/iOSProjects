//
//  JCHSettlementGuideView.m
//  jinchuhuo
//
//  Created by apple on 2016/12/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettlementGuideView.h"
#import "CommonHeader.h"
#import <QuartzCore/QuartzCore.h>

@implementation JCHSettlementGuideView

- (id)initWithFrame:(CGRect)frame
        buttonTitle:(NSString *)buttonTitle
        buttonColor:(UIColor *)buttonColor
         labelTitle:(NSString *)labelTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI:buttonTitle buttonColor:buttonColor labelTitle:labelTitle];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI:(NSString *)buttonTitle
     buttonColor:(UIColor *)buttonColor
      labelTitle:(NSString *)labelTitle
{
    UILabel *leftLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:buttonTitle
                                              font:JCHFont(21.0)
                                         textColor:[UIColor whiteColor]
                                            aligin:NSTextAlignmentCenter];
    [self addSubview:leftLabel];
    leftLabel.backgroundColor = buttonColor;
    leftLabel.layer.cornerRadius = 3.0;
    leftLabel.clipsToBounds = YES;
    
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(self.mas_height);
        make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:50]);
        make.left.equalTo(self.mas_left);
    }];
    
    UILabel *rightLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:labelTitle
                                               font:JCHFont(21.0)
                                          textColor:UIColorFromRGB(0X4A4A4A)
                                             aligin:NSTextAlignmentCenter];
    [self addSubview:rightLabel];
    
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(self.mas_height);
        make.left.equalTo(leftLabel.mas_right).with.offset(15);
        make.right.equalTo(self.mas_right);
    }];
    
}

@end
