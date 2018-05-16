//
//  ManifestHeaderView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/2.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ManifestHeaderView.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "UIView+JCHView.h"
#import <Masonry.h>

#if 0
@implementation JCHManifestHeaderViewData

- (void)dealloc
{

    [self.sectionTitle release];
    [self.shipmentCount release];
    [self.purchasesCount release];

    
    [super dealloc];
}
@end
#endif

@interface ManifestHeaderView ()
{
    UIButton *_recentOrderBtn;
    UIButton *_allOrderBtn;
    UIView *_leftRedBottomView;
    UIView *_rightRedBottomView;
    
//    UILabel *_sectionTitleLabel;
//    UILabel *_purchaseTitleLabel;
//    UILabel *_purchasesCountLabel;
//    UILabel *_shipmentTitleLabel;
//    UILabel *_shipmentCountLabel;
//    UIView *_middleLine;
    UIView  *_bottomLine;
//    CGFloat _purchasesCountLabelWidth;
//    CGFloat _shipmentCountLabelWidth;
}
@end

@implementation ManifestHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    //近期订单按钮
    _recentOrderBtn = [JCHUIFactory createButton:CGRectZero target:self action:@selector(handleRecentOrder:) title:@"近期订单" titleColor:JCHColorMainBody backgroundColor:[UIColor whiteColor]];
    [_recentOrderBtn setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _recentOrderBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _recentOrderBtn.selected = YES;
    [self addSubview:_recentOrderBtn];
    
    //全部订单按钮
    _allOrderBtn = [JCHUIFactory createButton:CGRectZero target:self action:@selector(handleAllOrder:) title:@"全部订单" titleColor:JCHColorMainBody backgroundColor:[UIColor whiteColor]];
    [_allOrderBtn setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
    _allOrderBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _allOrderBtn.selected = NO;
    [self addSubview:_allOrderBtn];
    
    //底部红色
    _leftRedBottomView = [[[UIView alloc] init] autorelease];
    _leftRedBottomView.backgroundColor = JCHColorHeaderBackground;
    _leftRedBottomView.layer.cornerRadius = 1.5f;
    _leftRedBottomView.clipsToBounds = YES;
    _rightRedBottomView = [[[UIView alloc] init] autorelease];
    _rightRedBottomView.layer.cornerRadius = 1.5f;
    
    [_recentOrderBtn addSubview:_leftRedBottomView];
    [_allOrderBtn addSubview:_rightRedBottomView];
    
#if 0
    UIFont *titleFont = [UIFont systemFontOfSize:[JCHSizeUtility calculateFontSizeWithSourceSize:14.0f]];
    UIFont *valueFont = [UIFont boldSystemFontOfSize:[JCHSizeUtility calculateFontSizeWithSourceSize:16.0f]];
    self.backgroundColor = [UIColor whiteColor];
    
    _purchasesCountLabelWidth = 4 * kStandardLeftMargin;
    _shipmentCountLabelWidth = _purchasesCountLabelWidth;
    
    _sectionTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:titleFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    [self addSubview:_sectionTitleLabel];
    
    
    
    _shipmentCountLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"00.00"
                                              font:valueFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentRight];
    [self addSubview:_shipmentCountLabel];
    
    
    _shipmentTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"出货:"
                                              font:titleFont
                                         textColor:JCHColorAuxiliary
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:_shipmentTitleLabel];
    
    _purchasesCountLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"00:00"
                                               font:valueFont
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentRight];
    [self addSubview:_purchasesCountLabel];
    
    _purchaseTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"进货:"
                                              font:titleFont
                                         textColor:JCHColorAuxiliary
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:_purchaseTitleLabel];
    
    _middleLine = [[[UIView alloc] init] autorelease];
    _middleLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_middleLine];
    
#endif
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_bottomLine];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat btnHeight = kHeight;
   
    [_recentOrderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(btnHeight);
    }];
    
    [_allOrderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_recentOrderBtn.mas_right);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(_recentOrderBtn.mas_top);
        make.bottom.equalTo(_recentOrderBtn.mas_bottom);
    }];
    
    CGFloat redButtonBottomViewHeight = 3.0f;
    const CGFloat redButtonBottonViewWidth = 30.0f;
    
    [_leftRedBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_recentOrderBtn.mas_centerX);
        make.width.mas_equalTo(redButtonBottonViewWidth);
        make.bottom.equalTo(_recentOrderBtn.mas_bottom);
        make.height.mas_equalTo(redButtonBottomViewHeight);
    }];
    
    [_rightRedBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_allOrderBtn.mas_centerX);
        make.width.mas_equalTo(redButtonBottonViewWidth);
        make.bottom.equalTo(_allOrderBtn.mas_bottom);
        make.height.mas_equalTo(redButtonBottomViewHeight);
    }];
#if 0
    [_middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(_leftRedBottomView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [_sectionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left).with.offset(kStandardLeftMargin);
        make.width.equalTo(self.mas_width).with.multipliedBy(1.0/3);
    }];
    
    
    [_shipmentCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(_shipmentCountLabelWidth);
        make.right.equalTo(self.mas_right).with.offset(-kStandardLeftMargin);
    }];
    
    [_shipmentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(_shipmentCountLabel.mas_left);
        make.width.equalTo(self.mas_width).with.multipliedBy(1.0/9);
    }];
    
    [_purchasesCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(_shipmentTitleLabel.mas_left).with.offset(-1.5 * kStandardLeftMargin);
        make.width.mas_equalTo(_purchasesCountLabelWidth);
    }];
    
    [_purchaseTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_middleLine.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(_purchasesCountLabel.mas_left);
        make.width.equalTo(self.mas_width).with.multipliedBy(1.0/9);
    }];
#endif
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
    
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)handleRecentOrder:(id)sender
{
    if (YES == [self.delegate respondsToSelector:@selector(handleRecentOrder)]) {
        _recentOrderBtn.selected = YES;
        _allOrderBtn.selected = NO;
        _leftRedBottomView.backgroundColor = JCHColorHeaderBackground;
        _rightRedBottomView.backgroundColor = [UIColor whiteColor];
        [self.delegate performSelector:@selector(handleRecentOrder)];
    }
}
- (void)handleAllOrder:(id)sender
{
    if (YES == [self.delegate respondsToSelector:@selector(handleAllOrder)]) {
        _recentOrderBtn.selected = NO;
        _allOrderBtn.selected = YES;
        _rightRedBottomView.backgroundColor = JCHColorHeaderBackground;
        _leftRedBottomView.backgroundColor = [UIColor whiteColor];
        [self.delegate performSelector:@selector(handleAllOrder)];
    }
}
#if 0
- (void)setViewData:(JCHManifestHeaderViewData *)viewData
{
    _sectionTitleLabel.text = viewData.sectionTitle;
    _purchasesCountLabel.text = viewData.purchasesCount;
    _shipmentCountLabel.text = viewData.shipmentCount;
    
    CGSize size = CGSizeMake(1000, self.frame.size.height);
    UIFont *valueFont = [UIFont boldSystemFontOfSize:[JCHSizeUtility calculateFontSizeWithSourceSize:16.0f]];
    CGRect purchasesCountLabelRect = [viewData.purchasesCount boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : valueFont} context:nil];
    CGRect shipmentCountLabelRect = [viewData.shipmentCount boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : valueFont} context:nil];
    
    _purchasesCountLabelWidth = purchasesCountLabelRect.size.width + 2;
    _shipmentCountLabelWidth = shipmentCountLabelRect.size.width + 2;
    
    [self setNeedsLayout];
    
    return;
}
#endif
@end
