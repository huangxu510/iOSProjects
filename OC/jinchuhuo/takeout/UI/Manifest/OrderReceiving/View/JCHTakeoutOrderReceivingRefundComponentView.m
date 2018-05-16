//
//  JCHTakeoutOrderReceivingRefundComponentView.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingRefundComponentView.h"
#import "CommonHeader.h"
#import <YYWeakProxy.h>

#define kTitleLabelHeight 25
#define kDetailLabelHeight 30
#define kFooterViewHeight 30

@implementation JCHTakeoutOrderReceivingRefundComponentViewData

- (void)dealloc
{
    self.title = nil;
    self.detail = nil;
    
    [super dealloc];
}

@end

@interface JCHTakeoutOrderReceivingRefundComponentView ()


@end

@implementation JCHTakeoutOrderReceivingRefundComponentView
{
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_dateLabel;
    UIView *_footerView;
    UILabel *_countDownLabel;
    UIButton *_rejectButton;
    UIButton *_agreeButton;
    UIImageView *_brokeLineView;
    
    NSTimeInterval _refundEndTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dateLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(11.0)
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentRight];
        [self addSubview:_dateLabel];
        
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-kStandardLeftMargin);
            make.top.equalTo(self);
            make.height.mas_equalTo(kTitleLabelHeight);
            make.width.mas_equalTo(100);
        }];
        
        _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(12.0)
                                      textColor:JCHColorAuxiliary
                                         aligin:NSTextAlignmentLeft];
        [self addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kStandardLeftMargin);
            make.right.equalTo(_dateLabel.mas_left).offset(-kStandardLeftMargin);
            make.top.bottom.equalTo(_dateLabel);
        }];
        
        _detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFont(11.0)
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentLeft];
        [self addSubview:_detailLabel];
        
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.right.equalTo(_dateLabel.mas_right);
            make.top.equalTo(_titleLabel.mas_bottom).offset(-kStandardLeftMargin / 2);
            make.height.mas_equalTo(kDetailLabelHeight);
        }];
        
        _footerView = [[[UIView alloc] init] autorelease];
        _footerView.clipsToBounds = YES;
        [self addSubview:_footerView];
        
        [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_detailLabel.mas_bottom);
            make.height.mas_equalTo(kFooterViewHeight);
            make.left.right.equalTo(self);
        }];
        
        
        _agreeButton = [JCHUIFactory createButton:CGRectZero
                                           target:self
                                           action:@selector(handleAgreeAction)
                                            title:@"同意"
                                       titleColor:[UIColor whiteColor]
                                  backgroundColor:JCHColorHeaderBackground];
        _agreeButton.titleLabel.font = JCHFont(13);
        _agreeButton.layer.cornerRadius = 4;
        [_footerView addSubview:_agreeButton];
        
        [_agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_footerView).offset(-kStandardLeftMargin);
            make.centerY.equalTo(_footerView);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(25);
        }];
        
        _rejectButton = [JCHUIFactory createButton:CGRectZero
                                            target:self
                                            action:@selector(handleRejectAction)
                                             title:@"拒绝"
                                        titleColor:JCHColorMainBody
                                   backgroundColor:[UIColor whiteColor]];
        _rejectButton.titleLabel.font = JCHFont(13);
        _rejectButton.layer.borderColor = JCHColorMainBody.CGColor;
        _rejectButton.layer.borderWidth = kSeparateLineWidth;
        _rejectButton.layer.cornerRadius = 4;
        [_footerView addSubview:_rejectButton];
        
        [_rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.equalTo(_agreeButton);
            make.right.equalTo(_agreeButton.mas_left).offset(-kStandardLeftMargin / 2);
        }];
        
        _countDownLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"23:24:25 后自动退款"
                                               font:JCHFont(11.0)
                                          textColor:UIColorFromRGB(0xff6400)
                                             aligin:NSTextAlignmentLeft];
        [_footerView addSubview:_countDownLabel];
        
        CGSize fitSize = [_countDownLabel sizeThatFits:CGSizeZero];
        
        [_countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_footerView).offset(kStandardLeftMargin);
            make.top.bottom.equalTo(_footerView);
            make.width.mas_equalTo(fitSize.width + 5);
        }];
        

        _brokeLineView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
        [self addSubview:_brokeLineView];
        
        [_brokeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kStandardLeftMargin);
            make.right.equalTo(self).offset(-kStandardLeftMargin);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)setBottomLineHidden:(BOOL)bottomLineHidden
{
    _bottomLineHidden = bottomLineHidden;
    
    _brokeLineView.hidden = bottomLineHidden;
}

- (void)dealloc
{
    self.agreeBlock = nil;
    self.rejectBlock = nil;
    
    [super dealloc];
}

- (void)handleAgreeAction
{
    if (self.agreeBlock) {
        self.agreeBlock();
    }
}

- (void)handleRejectAction
{
    if (self.rejectBlock) {
        self.rejectBlock();
    }
}

- (void)setViewData:(JCHTakeoutOrderReceivingRefundComponentViewData *)data
{
    _titleLabel.text = data.title;
    if (data.operateTime != 0) {
        _dateLabel.text = [NSString stringFromSeconds:data.operateTime dateStringType:kJCHDateStringType2];
    } else {
        _dateLabel.text = @"";
    }
    
    _detailLabel.text = data.detail;
    
    if (data.countDownTotalTime != 0) {
        _refundEndTime = data.operateTime + data.countDownTotalTime;
        [self judementActiveTime];
    } else {
        _countDownLabel.text = @"";
    }
    
    
    self.viewHeight = kTitleLabelHeight + kDetailLabelHeight + kFooterViewHeight;
    
    if (data.footerViewHidden) {
        self.viewHeight = kTitleLabelHeight + kDetailLabelHeight;
        _footerView.hidden = YES;
    }
    
    _rejectButton.hidden = data.rejectButtonHidden;
    _agreeButton.hidden = data.agreeButtonHidden;
}

- (void)judementActiveTime
{
    YYWeakProxy *weakProxy = [YYWeakProxy proxyWithTarget:self];
    //倒计时
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakProxy selector:@selector(caculateActiveLeaveTime:) userInfo:nil repeats:YES];
    [timer fire];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 倒计时计数
- (void)caculateActiveLeaveTime:(NSTimer *)timer
{
    //当前时间的时间戳
    NSDate *dateNow = [NSDate date];
    NSTimeInterval nowInterval = [dateNow timeIntervalSince1970];
    

    NSDateFormatter *actFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [actFormatter setDateFormat:@"HH:mm:ss"];

    if (_refundEndTime > nowInterval) {
        NSInteger remanentTime = _refundEndTime - nowInterval;
        NSInteger hours = remanentTime / 3600;
        NSInteger minutes = (remanentTime - hours * 3600) / 60;
        NSInteger seconds = (remanentTime - hours * 3600 - minutes * 60);
        NSString *hoursString = [NSString stringWithFormat:@"%02ld", hours];
        NSString *minutesString = [NSString stringWithFormat:@"%02ld", minutes];
        NSString *secondsString = [NSString stringWithFormat:@"%02ld", seconds];
        
        NSString *remanentTimeString = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minutesString, secondsString];

        _countDownLabel.text = [NSString stringWithFormat:@"%@ 后自动退款", remanentTimeString];
    } else {
        _countDownLabel.text = @"00:00:00 后自动退款";
        [timer invalidate];
    }
}


@end
