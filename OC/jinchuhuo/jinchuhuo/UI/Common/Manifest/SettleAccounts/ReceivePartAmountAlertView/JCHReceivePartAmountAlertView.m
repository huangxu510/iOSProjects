//
//  JCHReceivePartAmountAlertView.m
//  jinchuhuo
//
//  Created by huangxu on 16/9/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHReceivePartAmountAlertView.h"
#import "CommonHeader.h"

@implementation JCHReceivePartAmountAlertViewData

@end

@implementation JCHReceivePartAmountAlertView
{
    UILabel *_titleLabel;
    UILabel *_manifestARAPAmountLabel;
    UILabel *_manifestRealPayAmountLabel;
    UILabel *_manifestPreferentialAmountLabel;
    UIButton *_determineButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.determineAction = nil;
    self.cancleAction = nil;
    [super dealloc];
}

- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"请确定实收金额"
                                       font:[UIFont jchBoldSystemFontOfSize:15]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentCenter];
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [_titleLabel addSeparateLineWithMasonryTop:NO bottom:YES];
    
    _manifestRealPayAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                      title:@"实收金额"
                                                       font:JCHFont(14.0)
                                                  textColor:JCHColorMainBody
                                                     aligin:NSTextAlignmentCenter];
    [self addSubview:_manifestRealPayAmountLabel];
    
    [_manifestRealPayAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.left.right.equalTo(self);
        make.height.mas_equalTo(25);
    }];
    
    _manifestARAPAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"应收金额"
                                                    font:JCHFont(14.0)
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentCenter];
    [self addSubview:_manifestARAPAmountLabel];
    
    [_manifestARAPAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_manifestRealPayAmountLabel.mas_top);
        make.left.right.height.equalTo(_manifestRealPayAmountLabel);
    }];
    
    _manifestPreferentialAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                           title:@"少收金额"
                                                            font:JCHFont(14.0)
                                                       textColor:JCHColorMainBody
                                                          aligin:NSTextAlignmentCenter];
    [self addSubview:_manifestPreferentialAmountLabel];
    
    [_manifestPreferentialAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestRealPayAmountLabel.mas_bottom);
        make.left.right.height.equalTo(_manifestRealPayAmountLabel);
    }];
    
    UIButton *cancleButton = [JCHUIFactory createButton:CGRectZero
                                                 target:self
                                                 action:@selector(handleCancleAction)
                                                  title:@"取消"
                                             titleColor:JCHColorMainBody
                                        backgroundColor:[UIColor whiteColor]];
    cancleButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:cancleButton];
    
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.right.equalTo(self.mas_centerX);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [cancleButton addSeparateLineWithMasonryTop:YES bottom:NO];
    
    _determineButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleDetermineAction)
                                            title:@"确定收款"
                                       titleColor:JCHColorHeaderBackground
                                  backgroundColor:[UIColor whiteColor]];
    _determineButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_determineButton];
    
    [_determineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.left.equalTo(self.mas_centerX);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [_determineButton addSeparateLineWithMasonryTop:YES bottom:NO];
    [_determineButton addSeparateLineWithMasonryLeft:YES right:NO];
}

- (void)handleCancleAction
{
    if (self.cancleAction) {
        self.cancleAction();
    }
}

- (void)handleDetermineAction
{
    if (self.determineAction) {
        self.determineAction();
    }
}

- (void)setViewData:(JCHReceivePartAmountAlertViewData *)data
{
    if (data.manifetType == kJCHOrderReceipt) {
        //收款单
        _titleLabel.text = @"请确定实收金额";
        _manifestARAPAmountLabel.text = [NSString stringWithFormat:@"应收金额：%.2f", data.manifestARAPAmount];
        _manifestRealPayAmountLabel.text = [NSString stringWithFormat:@"实收金额：%.2f", data.manifestRealPayAmount];
        _manifestPreferentialAmountLabel.text = [NSString stringWithFormat:@"少收金额：%.2f", (data.manifestARAPAmount - data.manifestRealPayAmount)];
        [_determineButton setTitle:@"确定收款" forState:UIControlStateNormal];
    } else if (data.manifetType == kJCHOrderPayment) {
        //付款单
        _titleLabel.text = @"请确定实付金额";
        _manifestARAPAmountLabel.text = [NSString stringWithFormat:@"应付金额：%.2f", data.manifestARAPAmount];
        _manifestRealPayAmountLabel.text = [NSString stringWithFormat:@"实付金额：%.2f", data.manifestRealPayAmount];
        _manifestPreferentialAmountLabel.text = [NSString stringWithFormat:@"少付金额：%.2f", (data.manifestARAPAmount - data.manifestRealPayAmount)];
        [_determineButton setTitle:@"确定付款" forState:UIControlStateNormal];
    }
}

@end
