//
//  JCHTakeoutOrderReceivingRefundInfoView.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingRefundInfoView.h"
#import "JCHTakeoutOrderReceivingRefundComponentView.h"
#import "CommonHeader.h"

@implementation JCHTakeoutOrderReceivingRefundInfoView
{
    UIButton *_expandedButton;
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
    self.agreeBlock = nil;
    self.rejectBlock = nil;
    self.expandBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.backgroundColor = UIColorFromRGB(0xFFFCF4);
    UILabel *refundTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"退款"
                                                     font:[UIFont jchBoldSystemFontOfSize:14]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self addSubview:refundTitleLabel];
    [refundTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
    
    _expandedButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(handleExpand)
                                           title:@""
                                      titleColor:JCHColorMainBody
                                 backgroundColor:UIColorFromRGB(0xFFFCF4)];
    [_expandedButton setImage:[UIImage imageNamed:@"icon_takeout_order_close"] forState:UIControlStateNormal];
    [_expandedButton setImage:[UIImage imageNamed:@"icon_takeout_order_open"] forState:UIControlStateSelected];
    [self addSubview:_expandedButton];
    
    [_expandedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(refundTitleLabel);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.width.mas_equalTo(30);
    }];
    
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExpand)] autorelease];
    [self addGestureRecognizer:tap];
}

- (void)setViewData:(JCHTakeoutOrderInfoModel *)model
{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[JCHTakeoutOrderReceivingRefundComponentView class]]) {
            [subView removeFromSuperview];
        }
    }
    CGFloat titleLabelHeight = 30;
    self.viewHeight = titleLabelHeight;
    JCHTakeoutOrderReceivingRefundComponentView *lastView = nil;

    JCHTakeoutOrderReceivingRefundComponentView *refundInfoLastView = [self createRefundInfoView:model];
    if (refundInfoLastView) {
        lastView = refundInfoLastView;
    }
    
    JCHTakeoutOrderReceivingRefundComponentView *backInfoLastView = [self createBackInfoView:model];
    if (backInfoLastView) {
        lastView = backInfoLastView;
    }
    
    _expandedButton.selected = model.refundInfoExpanded;
    lastView.bottomLineHidden = YES;
    
    if (!model.refundInfoExpanded) {
        self.viewHeight = lastView.viewHeight + titleLabelHeight;
        
        
        lastView.frame = CGRectMake(0, titleLabelHeight, kScreenWidth - kStandardLeftMargin, lastView.viewHeight);
        
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:[JCHTakeoutOrderReceivingRefundComponentView class]] && lastView != subView) {
                subView.hidden = YES;
            }
        }
    }
}

// 创建退款信息视图
- (JCHTakeoutOrderReceivingRefundComponentView *)createRefundInfoView:(JCHTakeoutOrderInfoModel *)model
{
    JCHTakeoutOrderReceivingRefundComponentView *lastView = nil;
    WeakSelf;
    // 退款原因
    if (model.refundTimeInfo.refundTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户申请全部退款";
        componentData.detail = model.refundReasonInfo.refundReason;
        componentData.operateTime = model.refundTimeInfo.refundTime;
        componentData.countDownTotalTime = 3600 * 24;
        // 发起退款状态
        if (model.refundStatus == kJCHTakeoutRefundStatusStart) {
            componentData.footerViewHidden = NO;
            componentData.rejectButtonHidden = NO;
            componentData.agreeButtonHidden = NO;
        } else {
            componentData.footerViewHidden = YES;
        }
        
        [componentView setViewData:componentData];
        
        [componentView setAgreeBlock:^{
            if (weakSelf.agreeBlock) {
                weakSelf.agreeBlock();
            }
        }];
        
        [componentView setRejectBlock:^{
            if (weakSelf.rejectBlock) {
                weakSelf.rejectBlock();
            }
        }];
        
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 取消退款申请
    if (model.refundTimeInfo.cancelTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户取消全部退款申请";
        componentData.detail = @"退款流程已取消";
        componentData.operateTime = model.refundTimeInfo.cancelTime;
        componentData.footerViewHidden = YES;
        [componentView setViewData:componentData];
        
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 拒绝退款
    if (model.refundTimeInfo.rejectRefundTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"商家拒绝退款";
        componentData.detail = model.refundReasonInfo.refundDealReason;
        componentData.operateTime = model.refundTimeInfo.rejectRefundTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    
    // 用户再次申诉退款
    if (model.refundTimeInfo.complaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户再次申诉全部退款";
        componentData.detail = model.refundReasonInfo.complaintReason;
        componentData.operateTime = model.refundTimeInfo.complaintTime;
        componentData.countDownTotalTime = 3600 * 24 * 3;
        
        if (model.resource == kJCHTakeoutResourceMeituan) {
            // 如果是发起申诉要显示按钮
            if (model.refundStatus == kJCHTakeoutRefundStatusAppealStart) {
                componentData.footerViewHidden = NO;
                componentData.rejectButtonHidden = YES;
                componentData.agreeButtonHidden = NO;
            } else {
                componentData.footerViewHidden = YES;
                componentData.rejectButtonHidden = YES;
                componentData.agreeButtonHidden = YES;
            }
            
            [componentView setAgreeBlock:^{
                if (weakSelf.agreeBlock) {
                    weakSelf.agreeBlock();
                }
            }];
            
            [componentView setRejectBlock:^{
                if (weakSelf.rejectBlock) {
                    weakSelf.rejectBlock();
                }
            }];
        } else if (model.resource == kJCHTakeoutResourceEleme) {
            componentData.footerViewHidden = YES;
        } else if (model.resource == kJCHTakeoutResourceBaidu) {
            // FIXME: 接百度时修改
        }
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 取消申诉
    if (model.refundTimeInfo.cancelComplaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户取消全部退款申诉";
        componentData.detail = @"退款流程已取消";
        componentData.operateTime = model.refundTimeInfo.cancelComplaintTime;
        componentData.footerViewHidden = YES;
        
        [componentView setViewData:componentData];
        
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 同意退款
    if (model.refundTimeInfo.agreeTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"商家同意全部退款";
        componentData.detail = @"该笔钱会自动退回给用户";
        componentData.operateTime = model.refundTimeInfo.agreeTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 同意申诉
    if (model.refundTimeInfo.agreeComplaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"商家同意全部退款";
        componentData.detail = @"该笔钱会自动退回给用户";
        componentData.operateTime = model.refundTimeInfo.agreeComplaintTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 系统拒绝申诉退款
    if (model.refundTimeInfo.rejectComplaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"外卖平台拒绝全部退款";
        componentData.detail = @"退款流程已取消";
        componentData.operateTime = model.refundTimeInfo.rejectComplaintTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    return lastView;
}

// 创建退单信息视图
- (JCHTakeoutOrderReceivingRefundComponentView *)createBackInfoView:(JCHTakeoutOrderInfoModel *)model
{
    JCHTakeoutOrderReceivingRefundComponentView *lastView = nil;
    WeakSelf;
    // 退单原因
    if (model.backTimeInfo.backTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户申请退单";
        componentData.detail = model.backReasonInfo.backReason;
        componentData.operateTime = model.backTimeInfo.backTime;
//        componentData.countDownTotalTime = 3600 * 24;
        // 发起退款状态
        if (model.backStatus == kJCHTakeoutRefundStatusStart) {
            componentData.footerViewHidden = NO;
            componentData.rejectButtonHidden = NO;
            componentData.agreeButtonHidden = NO;
        } else {
            componentData.footerViewHidden = YES;
        }
        
        [componentView setViewData:componentData];
        
        [componentView setAgreeBlock:^{
            if (weakSelf.agreeBlock) {
                weakSelf.agreeBlock();
            }
        }];
        
        [componentView setRejectBlock:^{
            if (weakSelf.rejectBlock) {
                weakSelf.rejectBlock();
            }
        }];
        
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 取消退单申请
    if (model.backTimeInfo.cancelTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户取消退单申请";
        componentData.detail = @"退单流程已取消";
        componentData.operateTime = model.backTimeInfo.cancelTime;
        componentData.footerViewHidden = YES;
        [componentView setViewData:componentData];
        
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 拒绝退单
    if (model.backTimeInfo.rejectBackTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"商家拒绝退单";
        componentData.detail = model.backReasonInfo.backDealReason;
        componentData.operateTime = model.backTimeInfo.rejectBackTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    
    // 用户再次申诉退单
    if (model.backTimeInfo.complaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户再次申诉退单";
        componentData.detail = model.backReasonInfo.backComplaintReason;
        componentData.operateTime = model.backTimeInfo.complaintTime;
//        componentData.countDownTotalTime = 3600 * 24 * 3;
        
        if (model.resource == kJCHTakeoutResourceMeituan) {
            // 如果是发起申诉要显示按钮
            if (model.refundStatus == kJCHTakeoutRefundStatusAppealStart) {
                componentData.footerViewHidden = NO;
                componentData.rejectButtonHidden = YES;
                componentData.agreeButtonHidden = NO;
            } else {
                componentData.footerViewHidden = YES;
                componentData.rejectButtonHidden = YES;
                componentData.agreeButtonHidden = YES;
            }
            
            [componentView setAgreeBlock:^{
                if (weakSelf.agreeBlock) {
                    weakSelf.agreeBlock();
                }
            }];
            
            [componentView setRejectBlock:^{
                if (weakSelf.rejectBlock) {
                    weakSelf.rejectBlock();
                }
            }];
        } else if (model.resource == kJCHTakeoutResourceEleme) {
            componentData.footerViewHidden = YES;
        } else if (model.resource == kJCHTakeoutResourceBaidu) {
            // FIXME: 接百度时修改
        }
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 取消申诉
    if (model.backTimeInfo.cancelComplaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"用户取消退单申诉";
        componentData.detail = @"退单流程已取消";
        componentData.operateTime = model.backTimeInfo.cancelComplaintTime;
        componentData.footerViewHidden = YES;
        
        [componentView setViewData:componentData];
        
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 同意退单
    if (model.backTimeInfo.agreeTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"商家同意退单";
        componentData.detail = @"该笔钱会自动退回给用户";
        componentData.operateTime = model.backTimeInfo.agreeTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 同意申诉
    if (model.backTimeInfo.agreeComplaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"商家同意退单";
        componentData.detail = @"该笔钱会自动退回给用户";
        componentData.operateTime = model.backTimeInfo.agreeComplaintTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    
    // 系统拒绝申诉退单
    if (model.backTimeInfo.rejectComplaintTime != 0) {
        JCHTakeoutOrderReceivingRefundComponentView *componentView = [[[JCHTakeoutOrderReceivingRefundComponentView alloc] init] autorelease];
        [self addSubview:componentView];
        
        JCHTakeoutOrderReceivingRefundComponentViewData *componentData = [[[JCHTakeoutOrderReceivingRefundComponentViewData alloc] init] autorelease];
        componentData.title = @"外卖平台拒绝退单";
        componentData.detail = @"退单流程已取消";
        componentData.operateTime = model.backTimeInfo.rejectComplaintTime;
        componentData.footerViewHidden = YES;
        componentData.rejectButtonHidden = YES;
        componentData.agreeButtonHidden = YES;
        
        
        [componentView setViewData:componentData];
        
        CGRect frame = CGRectMake(0, self.viewHeight, kScreenWidth - kStandardLeftMargin, componentView.viewHeight);
        componentView.frame = frame;
        
        self.viewHeight += componentView.viewHeight;
        lastView = componentView;
    }
    return lastView;
}

- (void)handleExpand
{
    _expandedButton.selected = !_expandedButton.selected;
    if (self.expandBlock) {
        self.expandBlock(_expandedButton.selected);
    }
}

- (void)showBottomLine:(BOOL)show
{
    JCHTakeoutOrderReceivingRefundComponentView *lastView = nil;
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[JCHTakeoutOrderReceivingRefundComponentView class]]) {
            lastView = (JCHTakeoutOrderReceivingRefundComponentView *)subView;
        }
    }
    lastView.bottomLineHidden = !show;
}

@end
