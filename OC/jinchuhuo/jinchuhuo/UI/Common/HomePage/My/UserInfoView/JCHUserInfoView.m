//
//  JCHUserInfoView.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHUserInfoView.h"
#import "CommonHeader.h"
#import <THLabel.h>

@implementation JCHUserInfoViewData

- (void)dealloc
{
    self.headImageName = nil;
    self.nickname = nil;
    self.maimaiNumber = nil;
    
    [super dealloc];
}


@end


@implementation JCHUserInfoView
{
    UIImageView *_headImageView;
    THLabel *_nickNameLabel;
    UIView *_memberInfoContentView;
    UIImageView *_memberIcon;
    THLabel *_memberInfoLabel;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        self.userInteractionEnabled = YES;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.openAddedService = nil;
    [super dealloc];
}


- (void)createUI
{
    CGFloat headImageViewHeight = 65.0f;
    CGFloat memberIconWidth = 27.0f;
    CGFloat headImageViewBottomOffset = 46.0f;
    

    
    _headImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homepage_avatar_default"]] autorelease];
    _headImageView.layer.cornerRadius = headImageViewHeight / 2;
    [self addSubview:_headImageView];
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.bottom.equalTo(self).with.offset(-headImageViewBottomOffset);
        make.width.and.height.mas_equalTo(headImageViewHeight);
    }];
    
    CGFloat headImageBackViewHeight = 69.0f;
    UIView *headImageBackView = [[[UIView alloc] init] autorelease];
    headImageBackView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.4];
    headImageBackView.layer.cornerRadius = headImageBackViewHeight / 2;
    [self addSubview:headImageBackView];
    
    [self sendSubviewToBack:headImageBackView];
    
    [headImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.equalTo(_headImageView);
        make.width.and.height.mas_equalTo(headImageBackViewHeight);
    }];
    
    UIImageView *arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_personal_next"]] autorelease];
    [self addSubview:arrowImageView];
    
    const CGFloat arrowImageViewHeight = 12;
    const CGFloat arrowImageViewWidth = 7;
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(arrowImageViewHeight);
        make.width.mas_equalTo(arrowImageViewWidth);
        make.centerY.equalTo(_headImageView);
    }];
    
    _nickNameLabel = (THLabel *)[JCHUIFactory createLabel:CGRectZero
                                         title:@"小麦 (麦号:18889)"
                                          font:[UIFont systemFontOfSize:15.0f]
                                     textColor:[UIColor whiteColor]
                                        aligin:NSTextAlignmentLeft];
    _nickNameLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _nickNameLabel.shadowOffset = CGSizeMake(0, 1.5);
    _nickNameLabel.shadowBlur = 0;
    [self addSubview:_nickNameLabel];
    
    CGSize fitSize = [_nickNameLabel sizeThatFits:CGSizeZero];
    [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_headImageView.mas_centerY).with.offset(-9).priorityLow();
        make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(fitSize.height + 5);
        make.right.equalTo(arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
    }];
    
    _memberInfoContentView = [[[UIView alloc] init] autorelease];
    _memberInfoContentView.backgroundColor = UIColorFromRGB(0xf85657);
    _memberInfoContentView.layer.borderColor = JCHColorHeaderBackground.CGColor;
    _memberInfoContentView.layer.borderWidth = 1;
    _memberInfoContentView.layer.cornerRadius = 15.0f;
    _memberInfoContentView.clipsToBounds = YES;
    [self addSubview:_memberInfoContentView];
    
    [_memberInfoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nickNameLabel);
        make.width.mas_equalTo(100.0f);
        make.top.equalTo(_headImageView.mas_centerY);
        make.height.mas_equalTo(30.0f);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOpenAddedService)] autorelease];
    [_memberInfoContentView addGestureRecognizer:tap];
    
    _memberIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_common_level_normal"]] autorelease];
    [_memberInfoContentView addSubview:_memberIcon];
    
    [_memberIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_memberInfoContentView).with.offset(1);
        make.centerY.equalTo(_memberInfoContentView);
        make.width.and.height.mas_equalTo(memberIconWidth);
    }];
    
    _memberInfoLabel = (THLabel *)[JCHUIFactory createLabel:CGRectZero
                                       title:@"注册会员"
                                        font:[UIFont systemFontOfSize:13.0f]
                                   textColor:[UIColor whiteColor]
                                      aligin:NSTextAlignmentLeft];
    _memberInfoLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _memberInfoLabel.shadowOffset = CGSizeMake(0, 1.5);
    _memberInfoLabel.shadowBlur = 0;
    [_memberInfoContentView addSubview:_memberInfoLabel];
    
    [_memberInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_memberIcon.mas_right).with.offset(kStandardLeftMargin / 2);
        make.right.and.top.and.bottom.equalTo(_memberInfoContentView);
    }];
}

- (void)handleOpenAddedService
{
    if (self.openAddedService) {
        self.openAddedService();
    }
}

- (void)setViewData:(JCHUserInfoViewData *)data
{
    UIImage *originalNormalImage = [UIImage imageNamed:@"bg_homepage_personalinformation_normal"];
    UIImage *normalImage = [originalNormalImage imageByScalingToSize:CGSizeMake(kScreenWidth, kScreenWidth / originalNormalImage.size.width * originalNormalImage.size.height)];
    UIImage *originalVipImage = [UIImage imageNamed:@"bg_homepage_personalinformation_VIP"];
    UIImage *vipImage = [originalVipImage imageByScalingToSize:CGSizeMake(kScreenWidth, kScreenWidth / originalNormalImage.size.width * originalNormalImage.size.height)];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (!statusManager.isShopManager) {
        self.image = normalImage;
        _memberInfoContentView.hidden = YES;
        [_nickNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headImageView);
        }];
    } else {
        
        _memberInfoContentView.hidden = NO;
        
        JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];

        switch (addedServiceManager.level) {
                
            case kJCHAddedServiceNormalLevel:   //普通会员
            {
                self.image = normalImage;
                _memberIcon.image = [UIImage imageNamed:@"icon_common_level_normal"];
                _memberInfoLabel.text = @"普通用户";
            }
                break;
                
            case kJCHAddedServiceCopperLevel:   //铜麦会员
            {
                self.image = vipImage;
                _memberIcon.image = [UIImage imageNamed:@"icon_common_level_copper"];
                _memberInfoLabel.text = @"认证铜麦";
            }
                break;
                
            case kJCHAddedServiceSiverLevel:    //银麦会员
            {
                self.image = vipImage;
                _memberIcon.image = [UIImage imageNamed:@"icon_common_level_silver"];
                _memberInfoLabel.text = @"银麦会员";
            }
                break;
                
            case kJCHAddedServiceGoldLevel:     //金麦会员
            {
                self.image = vipImage;
                _memberIcon.image = [UIImage imageNamed:@"icon_common_level_golden"];
                _memberInfoLabel.text = @"金麦会员";
            }
                break;
                
            default:
                break;
        }
    }
    if (data.headImageName) {
        _headImageView.image = [UIImage jchAvatarImageNamed:data.headImageName];
    }
    
    _nickNameLabel.text = [NSString stringWithFormat:@"%@ (麦号:%@)", data.nickname, data.maimaiNumber];
}

@end
