//
//  JCHGuideSecondViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/2/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHGuideSecondViewController.h"
#import "JCHGuideThirdViewController.h"
#import "JCHLoginViewController.h"
#import "JCHRegisterViewController.h"
#import "CommonHeader.h"
#import "JCHShopCategorySelectButton.h"
#import "AppDelegate.h"
#import <Masonry.h>

@interface JCHGuideSecondViewController ()
{
    UIButton *_nextPageButton;
    UITextField *_phoneNumberTextField;
    UIView *_bottomContainerView;
    BOOL _isShopManager;
}
@property (nonatomic, retain) UIButton *selectedButton;
@end
@implementation JCHGuideSecondViewController

- (instancetype)initWithIsShopManager:(BOOL)isShopManager
{
    self = [super init];
    if (self) {
        _isShopManager = isShopManager;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self createUI];
}

- (void)dealloc
{
    [self.selectedButton release];
    [super dealloc];
}

- (void)createUI
{
    self.view.backgroundColor = UIColorFromRGB(0xfffefa);
    if (_isShopManager) {

#if MMR_RESTAURANT_VERSION
        CGFloat titleLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:37.0f];
#else
        CGFloat titleLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:77.0f];
#endif
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"选择您的店铺类型"
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
        
        UIView *containerView = [[[UIView alloc] init] autorelease];
        [self.view addSubview:containerView];
        
        CGFloat topOffset = [JCHSizeUtility calculateWidthWithSourceWidth:42.0f];
        CGFloat containerViewWidth = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:294.0f];//[JCHSizeUtility calculateWidthWithSourceWidth:288.0f];
        CGFloat containerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:370.0f];//[JCHSizeUtility calculateWidthWithSourceWidth:390.0f];
        
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).with.offset(topOffset);
            make.height.mas_equalTo(containerViewHeight);
            make.width.mas_equalTo(containerViewWidth);
            make.centerX.equalTo(self.view);
        }];
        
        
#if MMR_RESTAURANT_VERSION
        CGFloat optionImageWidth = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:98.0f];
        CGFloat optionImageHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:80];
        
        NSArray *titleArray = @[@"早餐", @"西餐", @"咖啡", @"PISA",
                                @"外卖", @"火锅", @"甜品", @"面包",
                                @"日韩食物", @"奶茶饮品", @"烧烤", @"粥粉面",
                                @"酒吧", @"汉堡", @"其它"];
        NSArray *imageArray = @[
                                @"1zaocan.png", @"2xican.png", @"3kafei.png",
                                @"4pisa.png", @"5waimai.png", @"6huoguo.png", @"7tianpin.png",
                                @"8mianbao.png", @"9rihanshiwu.png", @"10naichayinpin.png", @"11shaokao.png",
                                @"12zhoufenmian.png", @"13jiuba.png", @"14hanbao.png", @"15qita.png",
                                ];
        for (NSInteger i = 0; i < 15; i++) {
            
            CGFloat x = (i % 3) * optionImageWidth;
            CGFloat y = (i / 3) * optionImageHeight;
            CGRect frame = CGRectMake(x, y, optionImageWidth, optionImageWidth);
            JCHShopCategorySelectButton *optionButton = [[[JCHShopCategorySelectButton alloc] initWithFrame:frame] autorelease];
            [optionButton addTarget:self action:@selector(selectOption:) forControlEvents:UIControlEventTouchUpInside];
            [optionButton setTitle:titleArray[i] forState:UIControlStateNormal];
            [optionButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
            optionButton.titleLabel.font = [UIFont jchSystemFontOfSize:13.0f];
            optionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            NSString *imageName = imageArray[i];
            optionButton.adjustsImageWhenHighlighted = NO;
            [optionButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            optionButton.tag = i;
            [containerView addSubview:optionButton];
        }
#else
        CGFloat optionImageWidth = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:98.0f];
        CGFloat optionImageHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:100.0f];
        
        NSArray *titleArray = @[@"服饰店", @"水果店", @"化妆品店", @"五金店", @"宠物店", @"母婴店", @"精品店", @"珠宝店", @"文具店", @"零食店", @"茶叶店", @"其他"];
        for (NSInteger i = 0; i < 12; i++) {
            
            CGFloat x = (i % 3) * optionImageWidth;
            CGFloat y = (i / 3) * optionImageHeight;
            CGRect frame = CGRectMake(x, y, optionImageWidth, optionImageWidth);
            JCHShopCategorySelectButton *optionButton = [[[JCHShopCategorySelectButton alloc] initWithFrame:frame] autorelease];
            [optionButton addTarget:self action:@selector(selectOption:) forControlEvents:UIControlEventTouchUpInside];
            [optionButton setTitle:titleArray[i] forState:UIControlStateNormal];
            [optionButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
            optionButton.titleLabel.font = [UIFont jchSystemFontOfSize:13.0f];
            optionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            NSString *imageName = [NSString stringWithFormat:@"shopType%ld", i];
            optionButton.adjustsImageWhenHighlighted = NO;
            [optionButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            optionButton.tag = i;
            [containerView addSubview:optionButton];
        }
#endif
        
        _nextPageButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(nextPage)
                                               title:@"下一步"
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:JCHColorHeaderBackground];
        [_nextPageButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
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
        
    } else {
    
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
        
        CGFloat titleLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:77.0f];
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"立即加入店铺"
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
        
        UIImageView *centerImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_clerk"]] autorelease];
        [self.view addSubview:centerImageView];
        
        CGFloat centerImageViewWidth = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:242.0f];
        CGFloat centerImageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:242.0f];
        CGFloat centerImageViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:30.0f];
        
        [centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).with.offset(centerImageViewTopOffset);
            make.height.mas_equalTo(centerImageViewHeight);
            make.width.mas_equalTo(centerImageViewWidth);
            make.centerX.equalTo(self.view);
        }];
        
        {
            UIButton *scanBarCodeButton = [JCHUIFactory createButton:CGRectZero
                                                              target:self
                                                              action:@selector(scanBarCode)
                                                               title:@"下一步"
                                                          titleColor:[UIColor whiteColor]
                                                     backgroundColor:JCHColorHeaderBackground];
            [scanBarCodeButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
            [scanBarCodeButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
            scanBarCodeButton.layer.cornerRadius = 4;
            [self.view addSubview:scanBarCodeButton];
            
            
            CGFloat scanBarCodeButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:50.0f];
            CGFloat scanBarCodeButtonTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:76.0f];
            CGFloat scanBarCodeButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:342.0f];
            
            [scanBarCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(centerImageView.mas_bottom).with.offset(scanBarCodeButtonTopOffset);
                make.height.mas_equalTo(scanBarCodeButtonHeight);
                make.width.mas_equalTo(scanBarCodeButtonWidth);
                make.centerX.equalTo(self.view);
            }];
            
            UILabel *topLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"你可以直接扫码加入"
                                                     font:[UIFont jchSystemFontOfSize:15.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
            [self.view addSubview:topLabel];
            
            CGSize fitSize = [topLabel sizeThatFits:CGSizeZero];
            
            [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
                make.right.equalTo(scanBarCodeButton);
                make.height.mas_equalTo(fitSize.height + 10);
                make.bottom.equalTo(scanBarCodeButton.mas_top);
            }];
        }
#if 0
        _bottomContainerView = [[[UIView alloc] init] autorelease];
        _bottomContainerView.backgroundColor = [UIColor whiteColor];
        _bottomContainerView.layer.borderColor = JCHColorHeaderBackground.CGColor;
        _bottomContainerView.layer.borderWidth = 1;
        _bottomContainerView.layer.cornerRadius = 5;
        _bottomContainerView.clipsToBounds = YES;
        [self.view addSubview:_bottomContainerView];
        
       
        
        CGFloat bottomContainerViewBottomOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:55.0f];
        CGFloat bottomContainerViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:342.0f];
        CGFloat bottomContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
        [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).with.offset(-bottomContainerViewBottomOffset);
            make.height.mas_equalTo(bottomContainerViewHeight);
            make.width.mas_equalTo(bottomContainerViewWidth);
            make.centerX.equalTo(self.view);
        }];
        
        _phoneNumberTextField = [JCHUIFactory createTextField:CGRectZero
                                                  placeHolder:@"填写邀请码"
                                                    textColor:JCHColorMainBody
                                                       aligin:NSTextAlignmentLeft];
        _phoneNumberTextField.font = [UIFont jchSystemFontOfSize:15.0f];
        _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
        _phoneNumberTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, bottomContainerViewHeight)] autorelease];
        [_bottomContainerView addSubview:_phoneNumberTextField];
        
        CGFloat rightButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:45.0f];
        [_phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bottomContainerView);
            make.right.equalTo(_bottomContainerView.mas_right).with.offset(-rightButtonWidth);
            make.top.equalTo(_bottomContainerView);
            make.bottom.equalTo(_bottomContainerView);
        }];
        
        UIButton *nextPageButton = [JCHUIFactory createButton:CGRectZero
                                                       target:self
                                                       action:@selector(joinShop)
                                                        title:nil
                                                   titleColor:nil
                                              backgroundColor:JCHColorHeaderBackground];
        [nextPageButton setImage:[UIImage imageNamed:@"guide_next"] forState:UIControlStateNormal];
        [_bottomContainerView addSubview:nextPageButton];
        
        [nextPageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_phoneNumberTextField.mas_right);
            make.right.equalTo(_bottomContainerView);
            make.top.and.bottom.equalTo(_bottomContainerView);
        }];
        
        UILabel *topLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"也可以填写短信里的店铺邀请码"
                                                 font:[UIFont jchSystemFontOfSize:15.0f]
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
        [self.view addSubview:topLabel];
        
        fitSize = [topLabel sizeThatFits:CGSizeZero];
        [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
            make.right.equalTo(_bottomContainerView);
            make.bottom.equalTo(_bottomContainerView.mas_top);
            make.height.mas_equalTo(fitSize.height + 10);
        }];
#endif
    }
}

- (void)scanBarCode
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [appDelegate.homePageController handleScanQRCode];
}

- (void)joinShop
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)selectOption:(UIButton *)sender
{
    _nextPageButton.enabled = YES;
    self.selectedButton.selected = NO;
    sender.selected = YES;
    self.selectedButton = sender;
}

- (void)nextPage
{
    JCHGuideThirdViewController *guideThirdVC = [[[JCHGuideThirdViewController alloc] initWithBookType:self.selectedButton.currentTitle] autorelease];
    [self.navigationController pushViewController:guideThirdVC animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)popAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
