//
//  JCHGuideFirstViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/2/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHGuideFirstViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHGuideSecondViewController.h"
#import "JCHStatisticsManager.h"
#import "CommonHeader.h"
#import "AppDelegate.h"
#import <Masonry.h>

@implementation JCHGuideFirstViewController
{
    UIButton *_shopManagerButton;
    UIImageView *_shopManagerSelectImageView;
    UIButton *_shopAssistantButton;
    UIImageView *_shopAssistantSelectImageView;
    UIButton *_nextPageButton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.addedServiceFlag = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.enableAutoSync = NO;
    [JCHSyncStatusManager writeToFile];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setEnableHandlingAutoRegisterResponse:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setEnableHandlingAutoRegisterResponse:NO];
}

- (void)createUI
{
    self.view.backgroundColor = UIColorFromRGB(0xfffefa);
    
    if (self.showBackButton) {
        UIButton *backButton = [JCHUIFactory createButton:CGRectMake(20, 20, 60, 44)
                                                   target:self
                                                   action:@selector(popAction)
                                                    title:@"返回"
                                               titleColor:JCHColorAuxiliary
                                          backgroundColor:nil];
        UIImage *image = [[UIImage imageNamed:@"bt_back"] imageWithTintColor:JCHColorAuxiliary];
        [backButton setImage:image forState:UIControlStateNormal];
        backButton.titleLabel.font = JCHFont(15);
        [self.view addSubview:backButton];
    }
    
    
    CGFloat titleLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:77.0f];
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"选择您的角色"
                                               font:[UIFont jchSystemFontOfSize:17.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    CGSize fitSize = [titleLabel sizeThatFits:CGSizeZero];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(titleLabelTopOffset);
        make.height.mas_equalTo(fitSize.height + 5);
        make.width.mas_equalTo(fitSize.width + 5);
        make.centerX.equalTo(self.view);
    }];
    
    
    _shopManagerButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(selectRole:)
                                              title:nil
                                         titleColor:nil
                                    backgroundColor:nil];
    [_shopManagerButton setBackgroundImage:[UIImage imageNamed:@"manager_avatar"] forState:UIControlStateNormal];
    _shopManagerButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:_shopManagerButton];
    
    CGFloat shopManagerButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:46.0f];
    CGFloat shopManagerButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:127.0f];
    CGFloat shopManagerButtonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:161.0f];;
    
    [_shopManagerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).with.offset(shopManagerButtonTopOffset);
        make.height.mas_equalTo(shopManagerButtonHeight);
        make.width.mas_equalTo(shopManagerButtonWidth);
        make.centerX.equalTo(self.view);
    }];
    
    _shopManagerSelectImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"people_select"]] autorelease];
    _shopManagerSelectImageView.hidden = YES;
    [_shopManagerButton addSubview:_shopManagerSelectImageView];
    
    CGFloat selectImageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:43.0f];
    CGFloat selectImageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:37.0f];
    [_shopManagerSelectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(selectImageViewWidth);
        make.height.mas_equalTo(selectImageViewHeight);
        make.bottom.equalTo(_shopManagerButton).with.offset(5);
        make.right.equalTo(_shopManagerButton).with.offset(10);
    }];

    _shopAssistantButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(selectRole:)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [_shopAssistantButton setBackgroundImage:[UIImage imageNamed:@"clerk_avatar"] forState:UIControlStateNormal];
    _shopAssistantButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:_shopAssistantButton];
    
    CGFloat shopAssistantButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:32.0f];
    [_shopAssistantButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_shopManagerButton.mas_bottom).with.offset(shopAssistantButtonTopOffset);
        make.height.equalTo(_shopManagerButton);
        make.left.equalTo(_shopManagerButton);
        make.width.equalTo(_shopManagerButton);
    }];
    
    _shopAssistantSelectImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"people_select"]] autorelease];
    _shopAssistantSelectImageView.hidden = YES;
    [_shopAssistantButton addSubview:_shopAssistantSelectImageView];
    
    [_shopAssistantSelectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(selectImageViewWidth);
        make.height.mas_equalTo(selectImageViewHeight);
        make.bottom.equalTo(_shopAssistantButton).with.offset(5);
        make.right.equalTo(_shopAssistantButton).with.offset(10);
    }];
    
    _nextPageButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(nextPage)
                                           title:@"下一步"
                                      titleColor:[UIColor whiteColor]
                                 backgroundColor:JCHColorHeaderBackground];
    [_nextPageButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
    [_nextPageButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
    _nextPageButton.layer.cornerRadius = 4;
    _nextPageButton.enabled = NO;
    [self.view addSubview:_nextPageButton];
    
    CGFloat nextPageButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:312.0f];
    CGFloat nextPageButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:50.0f];
    CGFloat nextPageButtonBottomOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:55.0f];
    
    [_nextPageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-nextPageButtonBottomOffset);
        make.height.mas_equalTo(nextPageButtonHeight);
        make.width.mas_equalTo(nextPageButtonWidth);
        make.centerX.equalTo(self.view);
    }];
}

- (void)selectRole:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _nextPageButton.enabled = YES;
    if (sender == _shopManagerButton) {
        _shopManagerSelectImageView.hidden = NO;
        _shopAssistantSelectImageView.hidden = YES;
    } else {
        _shopManagerSelectImageView.hidden = YES;
        _shopAssistantSelectImageView.hidden = NO;
    }
}


- (void)nextPage
{
    if (!_shopAssistantSelectImageView.hidden) {
        
        //1) 如果选择店员，则跳到下个页面
        JCHGuideSecondViewController *guideSecondVC = [[[JCHGuideSecondViewController alloc] initWithIsShopManager:_shopAssistantSelectImageView.hidden] autorelease];
        [self.navigationController pushViewController:guideSecondVC animated:YES];
    } else {
        
        JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
        if (addedServiceManager.level != kJCHAddedServiceSiverLevel && addedServiceManager.level != kJCHAddedServiceGoldLevel && self.addedServiceFlag) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"很抱歉，普通用户仅支持1个店铺，无法新建！购买店铺立即升级银麦会员享专线服务" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self popAction];
            }];
            UIAlertAction *addedServiceAction = [UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                JCHAddedServiceViewController *addedServiceVC = [[[JCHAddedServiceViewController alloc] init] autorelease];
                addedServiceVC.hidesBottomBarWhenPushed = YES;
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [self.navigationController pushViewController:addedServiceVC animated:YES];
            }];
            [alertController addAction:cancleAction];
            [alertController addAction:addedServiceAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            
            //2) 如果选择店长，在这里要判断所有的账本列表里面是否有 系统注册初始化001 类型的账本，没有则创建
            JCHAccountBookManager *accountBookManager = [JCHAccountBookManager sharedManager];
            [accountBookManager newAccountBook:^(BOOL success) {
                if (success) {
                    JCHGuideSecondViewController *guideSecondVC = [[[JCHGuideSecondViewController alloc] initWithIsShopManager:_shopAssistantSelectImageView.hidden] autorelease];
                    
                    [self.navigationController pushViewController:guideSecondVC animated:YES];
                    
                    // 新建店铺成功，发送统计信息
                    [[JCHStatisticsManager sharedInstance] createShopStatistics];
                }
            }];
        }
    }
}

- (void)popAction
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
