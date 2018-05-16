//
//  JCHTakeoutOrderReceivingTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingTableViewCell.h"
#import "JCHTakeoutOrderReceivingRefundInfoView.h"

#define kOrderInfoViewHeight 35
#define kIconImageViewWidth 25
#define kCallButtonWidth 40
#define kCustomInfoViewHeight 70
#define kNameLabelHeight 30
#define kPayStatusLabelHeight 30
#define kBottomLeftButtonWidth 100
#define kBottomButtonHeight 35


@implementation JCHTakeoutOrderReceivingTableViewCell
{
    UIView *_bottomContainerView;
    UIImageView *_iconImageView;
    UILabel *_orderIDLabel;
    UILabel *_customerNameLabel;
    UILabel *_customerAddressLabel;
    JCHTakeoutOrderReceivingDetailInfoView *_detailInfoView;
    UILabel *_payStatusLabel;
    UILabel *_totalAmountLabel;
    JCHTakeoutOrderReceivingRefundInfoView *_refundInfoView;
    UIView *_bottomButtonContainerView;
    UIButton *_bottomLeftButton;
    UIButton *_bottomRightButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = JCHColorGlobalBackground;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.detailDishExpandBlock = nil;
    self.refundInfoExpandBlock = nil;
    self.callUpBlock = nil;
    self.leftButtonBlock = nil;
    self.rightButtonBlock = nil;
    self.agreeRefundBlock = nil;
    self.rejectRefundBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    // 订单号
    UIView *orderInfoView = [[[UIView alloc] init] autorelease];
    orderInfoView.backgroundColor = JCHColorGlobalBackground;
    orderInfoView.layer.borderWidth = kSeparateLineWidth;
    orderInfoView.layer.borderColor = JCHColorSeparateLine.CGColor;
    [self.contentView addSubview:orderInfoView];
    
    [orderInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kStandardLeftMargin / 2);
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin / 2);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(kOrderInfoViewHeight);
    }];

    _iconImageView = [[[UIImageView alloc] init] autorelease];
    _iconImageView.layer.cornerRadius = 3;
    _iconImageView.clipsToBounds = YES;
    [orderInfoView addSubview:_iconImageView];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(orderInfoView).offset(kStandardLeftMargin / 2);
        make.width.height.mas_equalTo(kIconImageViewWidth);
        make.centerY.equalTo(orderInfoView);
    }];
    
    _orderIDLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:JCHFont(11.0)
                                    textColor:JCHColorAuxiliary
                                       aligin:NSTextAlignmentLeft];
    [orderInfoView addSubview:_orderIDLabel];
    
    [_orderIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).offset(kStandardLeftMargin / 2);
        make.top.bottom.equalTo(orderInfoView);
        make.right.equalTo(orderInfoView.mas_right).offset(-kStandardLeftMargin);
    }];

    _bottomContainerView = [[[UIView alloc] init] autorelease];
    _bottomContainerView.backgroundColor = [UIColor whiteColor];
    _bottomContainerView.layer.borderWidth = kSeparateLineWidth;
    _bottomContainerView.layer.borderColor = JCHColorSeparateLine.CGColor;
    _bottomContainerView.clipsToBounds = YES;
    [self.contentView addSubview:_bottomContainerView];
    
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(orderInfoView);
        make.top.equalTo(orderInfoView.mas_bottom).offset(-kSeparateLineWidth);
        make.bottom.equalTo(self.contentView).offset(-kStandardLeftMargin);
    }];

    // 客户信息
    UIView *customerInfoView = [[[UIView alloc] init] autorelease];
    [_bottomContainerView addSubview:customerInfoView];
    
    [customerInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(_bottomContainerView);
        make.height.mas_equalTo(kCustomInfoViewHeight);
    }];

    UIButton *callButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleCallUp)
                                                title:@""
                                           titleColor:JCHColorMainBody
                                      backgroundColor:[UIColor whiteColor]];
    [callButton setImage:[UIImage imageNamed:@"icon_takeout_order_call"] forState:UIControlStateNormal];
    [customerInfoView addSubview:callButton];
    
    [callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(customerInfoView).offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(kCallButtonWidth);
        make.top.equalTo(customerInfoView).offset(10);
    }];
    
    
    _customerNameLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@""
                                              font:JCHFont(17.0)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [customerInfoView addSubview:_customerNameLabel];
    
    [_customerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(customerInfoView).offset(kStandardLeftMargin);
        make.right.equalTo(callButton.mas_left).offset(-kStandardLeftMargin);
        make.bottom.equalTo(customerInfoView.mas_centerY);
        make.height.mas_equalTo(kNameLabelHeight);
    }];
    
    _customerAddressLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@""
                                                 font:JCHFont(11.0)
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    _customerAddressLabel.numberOfLines = 0;
    [customerInfoView addSubview:_customerAddressLabel];
    
    [_customerAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_customerNameLabel.mas_bottom);
        make.left.right.height.equalTo(_customerNameLabel);
    }];

    // 菜品信息
    _detailInfoView = [[[JCHTakeoutOrderReceivingDetailInfoView alloc] initWithFrame:CGRectZero] autorelease];
    WeakSelf;
    [_detailInfoView setExpandBlock:^(BOOL expanded) {
        [weakSelf detailViewExpand:expanded];
    }];
    [_bottomContainerView addSubview:_detailInfoView];
    
    [_detailInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(customerInfoView);
        make.top.equalTo(customerInfoView.mas_bottom);
    }];
    
    
    // 用户付款信息
    UILabel *customerPayStatusTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                               title:@"本单用户应付"
                                                                font:JCHFont(13.0)
                                                           textColor:JCHColorMainBody
                                                              aligin:NSTextAlignmentLeft];
    [_bottomContainerView addSubview:customerPayStatusTitleLabel];
    
    CGSize fitSize = [customerPayStatusTitleLabel sizeThatFits:CGSizeZero];
    [customerPayStatusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContainerView).offset(kStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width + 10);
        make.top.equalTo(_detailInfoView.mas_bottom);
        make.height.mas_equalTo(kPayStatusLabelHeight);
    }];
    
    
    CGFloat amountLabelWidth = 80;
    _totalAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"¥90"
                                             font:JCHFont(13.0)
                                        textColor:UIColorFromRGB(0xff6400)
                                           aligin:NSTextAlignmentRight];
    [_bottomContainerView addSubview:_totalAmountLabel];
    
    [_totalAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomContainerView).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(customerPayStatusTitleLabel);
        make.width.mas_equalTo(amountLabelWidth);
    }];
    
    
    _payStatusLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(13.0)
                                      textColor:UIColorFromRGB(0xff6400)
                                         aligin:NSTextAlignmentRight];
    [_bottomContainerView addSubview:_payStatusLabel];
    
    [_payStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_totalAmountLabel.mas_left).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(_totalAmountLabel);
        make.left.equalTo(customerPayStatusTitleLabel.mas_right).offset(kStandardLeftMargin);
    }];

    
    _refundInfoView = [[[JCHTakeoutOrderReceivingRefundInfoView alloc] init] autorelease];
    _refundInfoView.clipsToBounds = YES;
    [_bottomContainerView addSubview:_refundInfoView];
    
    [_refundInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_payStatusLabel.mas_bottom);
        make.left.right.equalTo(_bottomContainerView);
    }];
    
    
    _bottomButtonContainerView = [[[UIView alloc] init] autorelease];
    _bottomButtonContainerView.clipsToBounds = YES;
    [_bottomContainerView addSubview:_bottomButtonContainerView];
    
    [_bottomButtonContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_refundInfoView.mas_bottom);
        make.height.mas_equalTo(kBottomButtonHeight + 2 * kStandardLeftMargin);
        make.left.right.equalTo(_bottomContainerView);
        make.bottom.equalTo(_bottomContainerView);
    }];
    
    
    // 底部按钮
    _bottomLeftButton = [JCHUIFactory createButton:CGRectZero
                                            target:self
                                            action:@selector(handleLeftButtonAction)
                                             title:@"取消订单"
                                        titleColor:JCHColorMainBody
                                   backgroundColor:[UIColor whiteColor]];
    _bottomLeftButton.layer.borderColor = JCHColorMainBody.CGColor;
    _bottomLeftButton.layer.borderWidth = kSeparateLineWidth;
    _bottomLeftButton.layer.cornerRadius = 5;
    _bottomLeftButton.clipsToBounds = YES;
    _bottomLeftButton.titleLabel.font = JCHFont(14);
    [_bottomButtonContainerView addSubview:_bottomLeftButton];
    
    [_bottomLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomButtonContainerView).offset(kStandardLeftMargin);
        make.left.equalTo(_bottomButtonContainerView).offset(kStandardLeftMargin);
        make.width.mas_equalTo(kBottomLeftButtonWidth);
        make.height.mas_equalTo(kBottomButtonHeight);
    }];
    
    _bottomRightButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(handleRightButtonAction)
                                              title:@"接单"
                                         titleColor:[UIColor whiteColor]
                                    backgroundColor:JCHColorHeaderBackground];
    _bottomRightButton.layer.cornerRadius = 5;
    _bottomRightButton.clipsToBounds = YES;
    _bottomRightButton.titleLabel.font = JCHFont(14);
    [_bottomRightButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
    [_bottomContainerView addSubview:_bottomRightButton];
    
    [_bottomRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomLeftButton.mas_right).offset(kStandardLeftMargin);
        make.right.equalTo(_bottomButtonContainerView).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(_bottomLeftButton);
    }];
    
    UIImageView *brokeLineView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [customerPayStatusTitleLabel addSubview:brokeLineView];
    
    [brokeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContainerView).offset(kStandardLeftMargin);
        make.right.equalTo(_bottomContainerView).offset(-kStandardLeftMargin);
        make.top.equalTo(customerPayStatusTitleLabel);
        make.height.mas_equalTo(1);
    }];
    
    brokeLineView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [customerPayStatusTitleLabel addSubview:brokeLineView];
    
    [brokeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContainerView).offset(kStandardLeftMargin);
        make.right.equalTo(_bottomContainerView).offset(-kStandardLeftMargin);
        make.bottom.equalTo(customerPayStatusTitleLabel);
        make.height.mas_equalTo(1);
    }];
}

- (void)handleCallUp
{
    if (self.callUpBlock) {
        self.callUpBlock();
    }
}

- (void)handleLeftButtonAction
{
    if (self.leftButtonBlock) {
        self.leftButtonBlock();
    }
}

- (void)handleRightButtonAction
{
    if (self.rightButtonBlock) {
        self.rightButtonBlock();
    }
}

- (void)setCellData:(JCHTakeoutOrderInfoModel *)data
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:data.orderTime];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    _orderIDLabel.text = [NSString stringWithFormat:@"%@下单 | 订单编号:%@", dateString, data.orderIdView];
    _customerNameLabel.text = data.recipientName;
    _customerAddressLabel.text = [NSString stringWithFormat:@"%@", data.recipientAddress];
    
    [_detailInfoView setViewData:data];
    
    [_detailInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_detailInfoView.viewHeight).priorityHigh();
    }];
    
    if (data.payType == kJCHTakeoutPayTypeDelivery) {
        _payStatusLabel.text = @"货到付款";
    } else if (data.payType == kJCHTakeoutPayTypeHasPayedOnline) {
        _payStatusLabel.text = @"已付款";
    }
    
    _totalAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", data.orderTotalAmount];
    
    if (data.resource == kJCHTakeoutResourceMeituan) {
        _iconImageView.image = [UIImage imageNamed:@"icon_takeout_meituan"];
    } else if (data.resource == kJCHTakeoutResourceEleme) {
        _iconImageView.image = [UIImage imageNamed:@"icon_takeout_eleme"];
    }
    
    
    if (data.orderStatus == kJCHTakeoutOrderStatusNew) {
        // 新订单
        _bottomRightButton.enabled = YES;
        [_bottomRightButton setTitle:@"接单" forState:UIControlStateNormal];
    } else if (data.orderStatus == kJCHTakeoutOrderStatusToBeDelivery) {
        // 待配送
        _bottomRightButton.enabled = YES;
        [_bottomRightButton setTitle:@"配送" forState:UIControlStateNormal];
    } else if (data.orderStatus == kJCHTakeoutOrderStatusDidStartDelivery) {
        // 配送中
        
        if (data.resource == 1) {
            _bottomRightButton.enabled = YES;
            if (data.deliveryWay == 1001 || data.deliveryWay == 1002 || data.deliveryWay == 1004) {
                // 美团配送
                [_bottomRightButton setTitle:@"取消配送" forState:UIControlStateNormal];
            } else if (data.deliveryWay == 1003) {
                // 众包配送
                [_bottomRightButton setTitle:@"取消配送" forState:UIControlStateNormal];
            } else {
                // 自配送
                [_bottomRightButton setTitle:@"配送完成" forState:UIControlStateNormal];
            }
        } else if (data.resource == 2) {
            [_bottomRightButton setTitle:@"等待用户确认中" forState:UIControlStateDisabled];
            _bottomRightButton.enabled = NO;
        } else {
            // FIXME: 接百度外卖要处理
        }
    } else if (data.orderStatus == kJCHTakeoutOrderStatusToBeCustomerConfirm) {
        [_bottomRightButton setTitle:@"等待用户确认中" forState:UIControlStateDisabled];
        _bottomRightButton.enabled = NO;
    }
    
    // 未处理退款
    
    [self setRefundData:data];
}

- (void)setRefundData:(JCHTakeoutOrderInfoModel *)data
{
    if (data.refundStatus != kJCHTakeoutRefundStatusDisrelated || data.backStatus != kJCHTakeoutRefundStatusDisrelated) {
        
        [_refundInfoView setViewData:data];
        
        [_refundInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_refundInfoView.viewHeight).priorityHigh();
        }];
        
        WeakSelf;
        _refundInfoView.agreeBlock = ^{
            if (weakSelf.agreeRefundBlock) {
                weakSelf.agreeRefundBlock();
            }
        };
        _refundInfoView.rejectBlock = ^{
            if (weakSelf.rejectRefundBlock) {
                weakSelf.rejectRefundBlock();
            }
        };
        
        _refundInfoView.expandBlock = ^(BOOL expanded){
            if (weakSelf.refundInfoExpandBlock) {
                weakSelf.refundInfoExpandBlock(expanded);
            }
        };
    }
    
    
    
    if (data.refundStatus == kJCHTakeoutRefundStatusConfirm || data.orderStatus == kJCHTakeoutOrderStatusCompleted || data.orderStatus == kJCHTakeoutOrderStatusCanceled) {
        [_bottomButtonContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [_refundInfoView showBottomLine:NO];
    } else {
        [_bottomButtonContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kBottomButtonHeight + 2 * kStandardLeftMargin);
        }];
        [_refundInfoView showBottomLine:YES];
    }
    
    if (data.refundStatus == kJCHTakeoutRefundStatusStart || data.refundStatus == kJCHTakeoutRefundStatusAppealStart) {
        _bottomLeftButton.hidden = YES;
        [_bottomRightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bottomLeftButton);
            make.right.equalTo(_bottomButtonContainerView).offset(-kStandardLeftMargin);
            make.top.bottom.equalTo(_bottomLeftButton);
        }];
    } else {
        _bottomLeftButton.hidden = NO;
        [_bottomRightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bottomLeftButton.mas_right).offset(kStandardLeftMargin);
            make.right.equalTo(_bottomButtonContainerView).offset(-kStandardLeftMargin);
            make.top.bottom.equalTo(_bottomLeftButton);
        }];
    }
}

- (void)detailViewExpand:(BOOL)expanded
{
    if (self.detailDishExpandBlock) {
        self.detailDishExpandBlock(expanded);
    }
}

- (void)refundViewExpand:(BOOL)expanded
{
    if (self.refundInfoExpandBlock) {
        self.refundInfoExpandBlock(expanded);
    }
}

@end
