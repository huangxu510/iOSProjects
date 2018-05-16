//
//  JCHAnalyseInventoryFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalyseInventoryFooterView.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"

@interface JCHAnalyseInventoryFooterView ()
{
    UILabel *_valueLabel;
}
@end
@implementation JCHAnalyseInventoryFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
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
    UIFont *titleFont = [UIFont systemFontOfSize:17];
    
    UIView *topLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSeparateLineWidth)] autorelease];
    topLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:topLine];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)
                                              title:@"当前库存:"
                                               font:titleFont
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentRight];
    [self addSubview:titleLabel];
    
    _valueLabel = [JCHUIFactory createLabel:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)
                                      title:@" ¥ 0.00"
                                       font:titleFont
                                  textColor:JCHColorHeaderBackground
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_valueLabel];
}

- (void)setData:(NSString *)data
{
    NSString *value = [NSString stringWithFormat:@"¥ %@", data];
    _valueLabel.text = value;
}

@end
