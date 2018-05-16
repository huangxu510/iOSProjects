//
//  JCHManageStatisticsView.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManageStatisticsView.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import "Masonry.h"
#import "JCHSizeUtility.h"
#import "UIFont+JCHFont.h"


@implementation JCHManageStatisticsViewData

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.todayPurchaseAmount release];
    [self.todayShipmentAmount release];
    [self.monthProfitAmount release];
    self.todayShipmentManifest = nil;
    self.thisMonthShipmentAmount = nil;
    
    [super dealloc];
    return;
}

@end




@interface JCHManageStatisticsView ()
{
    UILabel *todayPurchaseAmountTitleLabel;
    UILabel *todayShipmentAmountTitleLabel;
    UILabel *monthProfitAmountTitleLabel;
    
    UILabel *todayPurchaseAmountValueLabel;
    UILabel *todayShipmentAmountValueLabel;
    UILabel *monthProfitAmountValueLabel;
    
    UILabel *manageScoreTitleLabel;
    
    UIImageView *leftSeperatorView_vertical;
    UIImageView *rightSeperatorView_vertical;
    
    UIImageView *leftSeperatorView_horizontal;
    UIImageView *rightSeperatorView_horizontal;
}
@end


@implementation JCHManageStatisticsView

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat titleHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:17.0f];
    const CGFloat titleWidth = [JCHSizeUtility calculateWidthWithSourceWidth:112];
    const CGFloat amountHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:21.5f];
    const CGFloat amountWidth = titleWidth;
    const CGFloat seperatorLineWidth = kSeparateLineWidth;
    const CGFloat seperatorLineTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:4.0f];
    const CGFloat titleLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:20];
    const CGFloat titleTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:25];
    const CGFloat amountTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:9];

    [todayPurchaseAmountTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).with.offset(titleTopOffset);
    }];
    
    [monthProfitAmountTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(todayPurchaseAmountTitleLabel.mas_top);
    }];
    
    [todayShipmentAmountTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(monthProfitAmountTitleLabel.mas_top);
    }];
    
    [todayPurchaseAmountValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(amountWidth);
        make.height.mas_equalTo(amountHeight);
        make.centerX.equalTo(todayPurchaseAmountTitleLabel.mas_centerX);
        make.top.equalTo(todayPurchaseAmountTitleLabel.mas_bottom).with.offset(amountTopOffset);
    }];
    
    [monthProfitAmountValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(amountWidth);
        make.height.mas_equalTo(amountHeight);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(todayPurchaseAmountValueLabel.mas_top);
    }];
    
    [todayShipmentAmountValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(amountWidth);
        make.height.mas_equalTo(amountHeight);
        make.centerX.equalTo(todayShipmentAmountTitleLabel.mas_centerX);
        make.top.equalTo(monthProfitAmountValueLabel.mas_top);
    }];
    
    [leftSeperatorView_vertical mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(todayPurchaseAmountTitleLabel.mas_right);
        make.top.equalTo(todayPurchaseAmountTitleLabel.mas_top).with.offset(seperatorLineTopOffset);
        make.bottom.equalTo(todayPurchaseAmountValueLabel.mas_bottom).with.offset(-seperatorLineTopOffset);
        make.width.mas_equalTo(seperatorLineWidth);
    }];
    
    [rightSeperatorView_vertical mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(monthProfitAmountTitleLabel.mas_right);
        make.top.equalTo(monthProfitAmountTitleLabel.mas_top).with.offset(seperatorLineTopOffset);
        make.bottom.equalTo(monthProfitAmountValueLabel.mas_bottom).with.offset(-seperatorLineTopOffset);
        make.width.mas_equalTo(seperatorLineWidth);
    }];
    
    const CGFloat manageLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:100];
    const CGFloat manageLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:19];
    
    [manageScoreTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(manageLabelWidth);
        make.height.mas_equalTo(manageLabelHeight);
        make.top.equalTo(monthProfitAmountValueLabel.mas_bottom).with.offset([JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:30]);
    }];
    
    const CGFloat horizontalLineWidth = [JCHSizeUtility calculateWidthWithSourceWidth:113];
    
    [leftSeperatorView_horizontal mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(titleLeftOffset);
        make.width.mas_equalTo(horizontalLineWidth);
        make.centerY.mas_equalTo(manageScoreTitleLabel.mas_centerY);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [rightSeperatorView_horizontal mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-titleLeftOffset);
        make.width.mas_equalTo(horizontalLineWidth);
        make.centerY.mas_equalTo(manageScoreTitleLabel.mas_centerY);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    
    return;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:12.0f];
    UIFont *amountFont = [UIFont jchBoldSystemFontOfSize:19.0f];
    UIColor *titleColor = JCHColorAuxiliary;
    UIColor *amountColor = JCHColorMainBody;
    // 今日进化标题
    {
        todayPurchaseAmountTitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        todayPurchaseAmountTitleLabel.text = @"今日进货(元)";
        [self addSubview:todayPurchaseAmountTitleLabel];
        todayPurchaseAmountTitleLabel.textColor = titleColor;
        todayPurchaseAmountTitleLabel.textAlignment = NSTextAlignmentCenter;
        todayPurchaseAmountTitleLabel.font = titleFont;
    }
    
    // 本月毛利标题
    {
        monthProfitAmountTitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        monthProfitAmountTitleLabel.text = @"本月毛利(元)";
        [self addSubview:monthProfitAmountTitleLabel];
        monthProfitAmountTitleLabel.textColor = titleColor;
        monthProfitAmountTitleLabel.textAlignment = NSTextAlignmentCenter;
        monthProfitAmountTitleLabel.font = titleFont;
    }
    
    // 今日出货标题
    {
        todayShipmentAmountTitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        todayShipmentAmountTitleLabel.text = @"今日出货(元)";
        [self addSubview:todayShipmentAmountTitleLabel];
        todayShipmentAmountTitleLabel.textColor = titleColor;
        todayShipmentAmountTitleLabel.textAlignment = NSTextAlignmentCenter;
        todayShipmentAmountTitleLabel.font = titleFont;
    }
    
    //经营指数标题
    {
        manageScoreTitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        manageScoreTitleLabel.text = @"经营指数";
        [self addSubview:manageScoreTitleLabel];
        manageScoreTitleLabel.textColor = titleColor;
        manageScoreTitleLabel.textAlignment = NSTextAlignmentCenter;
        manageScoreTitleLabel.font = [UIFont jchSystemFontOfSize:14];
      
    }
    
    // 今日进化数值
    {
        todayPurchaseAmountValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        todayPurchaseAmountValueLabel.text = @"";
        [self addSubview:todayPurchaseAmountValueLabel];
        todayPurchaseAmountValueLabel.textColor = amountColor;
        todayPurchaseAmountValueLabel.textAlignment = NSTextAlignmentCenter;
        todayPurchaseAmountValueLabel.font = amountFont;
    }
    
    // 本月毛利数值
    {
        monthProfitAmountValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        monthProfitAmountValueLabel.text = @"";
        [self addSubview:monthProfitAmountValueLabel];
        monthProfitAmountValueLabel.textColor = amountColor;
        monthProfitAmountValueLabel.textAlignment = NSTextAlignmentCenter;
        monthProfitAmountValueLabel.font = amountFont;
    }
    
    // 今日出货数值
    {
        todayShipmentAmountValueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        todayShipmentAmountValueLabel.text = @"";
        [self addSubview:todayShipmentAmountValueLabel];
        todayShipmentAmountValueLabel.textColor = amountColor;
        todayShipmentAmountValueLabel.textAlignment = NSTextAlignmentCenter;
        todayShipmentAmountValueLabel.font = amountFont;
    }
    
    // 左分垂直隔线
    {
        leftSeperatorView_vertical = [[[UIImageView alloc] init] autorelease];
        leftSeperatorView_vertical.backgroundColor = JCHColorSeparateLine;
        [self addSubview:leftSeperatorView_vertical];
    }
    
    // 右垂直分隔线
    {
        rightSeperatorView_vertical = [[[UIImageView alloc] init] autorelease];
        rightSeperatorView_vertical.backgroundColor = JCHColorSeparateLine;
        [self addSubview:rightSeperatorView_vertical];
    }
    
    //左水平分割线
    {
        leftSeperatorView_horizontal = [[[UIImageView alloc] init] autorelease];
        leftSeperatorView_horizontal.backgroundColor = JCHColorSeparateLine;
        [self addSubview:leftSeperatorView_horizontal];
    }
    
    //右水平分割线
    {
        rightSeperatorView_horizontal = [[[UIImageView alloc] init] autorelease];
        rightSeperatorView_horizontal.backgroundColor = JCHColorSeparateLine;
        [self addSubview:rightSeperatorView_horizontal];
    }
    
#if MMR_TAKEOUT_VERSION
    todayPurchaseAmountTitleLabel.text = @"今日开单(单)";
    monthProfitAmountTitleLabel.text = @"本月销量(元)";
    todayShipmentAmountTitleLabel.text = @"今日销量(元)";
#endif
}

- (void)setViewData:(JCHManageStatisticsViewData *)viewData
{
#if MMR_TAKEOUT_VERSION
    todayPurchaseAmountValueLabel.text = viewData.todayShipmentManifest;
    monthProfitAmountValueLabel.text = viewData.thisMonthShipmentAmount;
    todayShipmentAmountValueLabel.text = viewData.todayShipmentAmount;
#else
    todayPurchaseAmountValueLabel.text = viewData.todayPurchaseAmount;
    monthProfitAmountValueLabel.text = viewData.monthProfitAmount;
    todayShipmentAmountValueLabel.text = viewData.todayShipmentAmount;
#endif
}

@end
