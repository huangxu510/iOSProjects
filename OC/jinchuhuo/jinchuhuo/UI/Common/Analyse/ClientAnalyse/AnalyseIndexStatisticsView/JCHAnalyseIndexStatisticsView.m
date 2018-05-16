//
//  JCHAnalyseIndexStatisticsView.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAnalyseIndexStatisticsView.h"
#import "CommonHeader.h"

@implementation JCHAnalyseIndexStatisticsViewData

- (void)dealloc
{
    self.title = nil;
    self.middleText = nil;
    self.bottomText = nil;
    
    [super dealloc];
}

@end

@implementation JCHAnalyseIndexStatisticsView
{
    UILabel *_titleLabel;
    UILabel *_amountLabel;
    UILabel *_manifestCountLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat titleLabelTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
    CGFloat titleLabelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:25.0f];
    CGFloat middleLabelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:22.0f];
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(15.0f)
                                  textColor:JCHColorAuxiliary
                                     aligin:NSTextAlignmentCenter];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self).with.offset(titleLabelTopOffset);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _amountLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:JCHFont(13.0)
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentCenter];
    _amountLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_amountLabel];
    
    [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom);
        make.height.mas_equalTo(middleLabelHeight);
    }];
    
    _manifestCountLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:JCHFont(13.0f)
                                   textColor:JCHColorMainBody
                                      aligin:NSTextAlignmentCenter];
    _manifestCountLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_manifestCountLabel];
    
    [_manifestCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(_amountLabel);
        make.top.equalTo(_amountLabel.mas_bottom);
    }];
}

- (void)setViewData:(JCHAnalyseIndexStatisticsViewData *)data
{
    if (data.title && ![data.title isEmptyString]) {
        _titleLabel.text = data.title;
    }
    
    if (data.middleText) {
        _amountLabel.text = data.middleText;
    }
    
    if (data.bottomText) {
        _manifestCountLabel.text = data.bottomText;
    } else {
        [_amountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).with.offset(12);
        }];
    }
}

@end
