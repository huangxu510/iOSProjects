//
//  JCHEnforceLoginViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHEnforceLoginViewController.h"
#import "JCHLoginViewController.h"
#import "JCHRegisterViewController.h"
#import "CommonHeader.h"
#import "AppDelegate.h"
#import <Masonry.h>

@interface JCHEnforceLoginViewController () <UIScrollViewDelegate>
{
    UIScrollView *_textScrollView;
    UIScrollView *_containerScrollView;
    UIPageControl *_pageControl;
}
@end

@implementation JCHEnforceLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
#if MMR_TAKEOUT_VERSION
    [self createTakeoutUI];
#else
    [self createUI];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)createTakeoutUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:172.0f];
    CGFloat buttonHeight = [JCHSizeUtility calculateHeightFor4SAndOther:50.0f];
    CGFloat buttonLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
    CGFloat buttonBottomOffset =  [JCHSizeUtility calculateHeightFor4SAndOther:10.0f];
    CGFloat buttonSpacing = [JCHSizeUtility calculateWidthWithSourceWidth:11.0f];
    UIButton *registerButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleRegister)
                                                    title:@"注册"
                                               titleColor:[UIColor whiteColor]
                                          backgroundColor:JCHColorHeaderBackground];
    
    registerButton.layer.cornerRadius = 5;
    registerButton.clipsToBounds = YES;
    [self.view addSubview:registerButton];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(buttonLeftOffset);
        make.width.mas_equalTo(buttonWidth);
        make.bottom.equalTo(self.view).with.offset(-buttonBottomOffset);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    UIButton *loginButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(handleLogin)
                                                 title:@"登录"
                                            titleColor:JCHColorHeaderBackground
                                       backgroundColor:[UIColor whiteColor]];
    loginButton.layer.borderColor = JCHColorHeaderBackground.CGColor;
    loginButton.layer.borderWidth = 1;
    loginButton.layer.cornerRadius = 5;
    loginButton.clipsToBounds = YES;
    [self.view addSubview:loginButton];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(registerButton.mas_right).with.offset(buttonSpacing);
        make.width.equalTo(registerButton);
        make.top.equalTo(registerButton);
        make.bottom.equalTo(registerButton);
    }];
    
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:300.0f];
    CGFloat imageViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:350.0f];
    CGFloat imageViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:80];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takeout_login_pic"]] autorelease];
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset((kScreenWidth - imageViewWidth) / 2);
        make.width.mas_equalTo(imageViewWidth);
        make.top.equalTo(self.view).offset(imageViewTopOffset);
        make.height.mas_equalTo(imageViewHeight);
    }];
    
    UIView *textContainerView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:textContainerView];
    
    [textContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(registerButton.mas_top);
    }];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"聚合外卖"
                                               font:[UIFont jchBoldSystemFontOfSize:iPhone6Plus ? 20.0f :19.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    [textContainerView addSubview:titleLabel];
    
    CGSize fitSize = [titleLabel sizeThatFits:CGSizeZero];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(textContainerView.mas_centerY).offset(-20);
        make.height.mas_equalTo(fitSize.height);
        make.left.right.equalTo(textContainerView);
    }];
    
    UILabel *detailLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"打通多个外卖平台，集中接单管理"
                                                font:[UIFont jchSystemFontOfSize:iPhone6Plus ? 14.0f : 13.0f]
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentCenter];
    [textContainerView addSubview:detailLabel];
    
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textContainerView.mas_centerY);
        make.left.right.equalTo(textContainerView);
        make.height.mas_equalTo(titleLabel);
    }];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:172.0f];
    CGFloat buttonHeight = [JCHSizeUtility calculateHeightFor4SAndOther:50.0f];
    CGFloat buttonLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
    CGFloat buttonBottomOffset =  [JCHSizeUtility calculateHeightFor4SAndOther:10.0f];
    CGFloat buttonSpacing = [JCHSizeUtility calculateWidthWithSourceWidth:11.0f];
    UIButton *registerButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleRegister)
                                                    title:@"注册"
                                               titleColor:[UIColor whiteColor]
                                          backgroundColor:JCHColorHeaderBackground];
    
    registerButton.layer.cornerRadius = 5;
    registerButton.clipsToBounds = YES;
    [self.view addSubview:registerButton];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(buttonLeftOffset);
        make.width.mas_equalTo(buttonWidth);
        make.bottom.equalTo(self.view).with.offset(-buttonBottomOffset);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    UIButton *loginButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(handleLogin)
                                                 title:@"登录"
                                            titleColor:JCHColorHeaderBackground
                                       backgroundColor:[UIColor whiteColor]];
    loginButton.layer.borderColor = JCHColorHeaderBackground.CGColor;
    loginButton.layer.borderWidth = 1;
    loginButton.layer.cornerRadius = 5;
    loginButton.clipsToBounds = YES;
    [self.view addSubview:loginButton];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(registerButton.mas_right).with.offset(buttonSpacing);
        make.width.equalTo(registerButton);
        make.top.equalTo(registerButton);
        make.bottom.equalTo(registerButton);
    }];
    
    CGFloat containerScrollViewBottomOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:10.0f];
    
    _containerScrollView = [[[UIScrollView alloc] init] autorelease];
    _containerScrollView.contentSize = CGSizeMake(3 * kScreenWidth, 0);
    _containerScrollView.pagingEnabled = YES;
    _containerScrollView.bounces = NO;
    _containerScrollView.showsHorizontalScrollIndicator = NO;
    _containerScrollView.delegate = self;
    [self.view addSubview:_containerScrollView];
    
    [_containerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(registerButton.mas_top).with.offset(-containerScrollViewBottomOffset);
        make.left.and.right.and.top.equalTo(self.view);
    }];
    
    _pageControl = [[[UIPageControl alloc] init] autorelease];
    _pageControl.numberOfPages = 3;
    _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xd5d5d5);
    _pageControl.currentPageIndicatorTintColor = JCHColorHeaderBackground;
    _pageControl.enabled = NO;
    [self.view addSubview:_pageControl];
    
    CGFloat pageControlHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:30];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_containerScrollView.mas_bottom);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(pageControlHeight);
        make.centerX.equalTo(self.view);
    }];
    
    CGFloat textScrollViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:420.0f];
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:270.0f];
    CGFloat imageViewLeftMargin = (kScreenWidth - imageViewWidth) / 2;
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat x = i * kScreenWidth + imageViewLeftMargin;
        CGFloat y = textScrollViewTopOffset - imageViewWidth - 40;
        CGFloat width = imageViewWidth;
        CGFloat height = imageViewWidth;
        CGRect frame = CGRectMake(x, y, width, height);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
#if MMR_RESTAURANT_VERSION
        NSString *imageName = [NSString stringWithFormat:@"restaruant_login_pic%ld", (long)i + 1];
#else
        NSString *imageName = [NSString stringWithFormat:@"enforceLogin_pic%ld", (long)i + 1];
#endif
        imageView.image = [UIImage imageNamed:imageName];
        [_containerScrollView addSubview:imageView];
    }
    
    _textScrollView = [[[UIScrollView alloc] init] autorelease];
    _textScrollView.contentSize = CGSizeMake(3 * kScreenWidth, 0);
    _textScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_textScrollView];
    
    [self.view sendSubviewToBack:_textScrollView];
    
    [_textScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(_containerScrollView);
        make.top.equalTo(self.view).with.offset(textScrollViewTopOffset);
    }];
    
#if MMR_RESTAURANT_VERSION
    NSArray *titleArray = @[@"", @"", @""];
    NSArray *detailArray = @[@"手机、收银台、多维立体管店",
                             @"清晰便捷的点菜下单流程",
                             @"全面支持桌台管理的餐厅开台模块"];
#else
    NSArray *titleArray = @[@"融合收银", @"多人协作", @"经营有数"];
    NSArray *detailArray = @[@"支持打折、挂单、抹零，会员\n提供现金、微信、赊欠收款",
                             @"一对多店员的管理\n店主管理、店员开单，数据自动同步",
                             @"资金变动和商品进出协同处理\n同时支持多维分析，透视店铺经营"];
#endif
    
    CGFloat titleLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:24.0f];
    CGFloat titleLabelBottomOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:9.0f];
    CGFloat detailLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:50.0f];
    CGFloat detailLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:325.0f];
    
    for (NSInteger i = 0; i < 3; i++) {
        UIView *textContanierView = [[[UIView alloc] init] autorelease];
        [_textScrollView addSubview:textContanierView];
        
        [textContanierView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_textScrollView).with.offset(i * kScreenWidth);
            make.width.mas_equalTo(kScreenWidth);
            make.top.and.bottom.equalTo(_textScrollView);
        }];
        
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:titleArray[i]
                                                   font:[UIFont jchBoldSystemFontOfSize:iPhone6Plus ? 20.0f :19.0f]
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentCenter];
        [textContanierView addSubview:titleLabel];
        
        CGSize fitSize = [titleLabel sizeThatFits:CGSizeZero];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(textContanierView).with.offset(titleLabelTopOffset);
            make.height.mas_equalTo(textContanierView.mas_height).multipliedBy(1.0 / 3);
            make.width.mas_equalTo(fitSize.width);
            make.centerX.equalTo(textContanierView);
        }];
        
        UILabel *detailLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:nil
                                                    font:[UIFont jchSystemFontOfSize:iPhone6Plus ? 14.0f : 13.0f]
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentCenter];
        detailLabel.numberOfLines = 2;
        NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:detailArray[i]] autorelease];
        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [paragraphStyle setLineSpacing:5];//调整行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [detailArray[i] length])];
        detailLabel.attributedText = attributedString;
        [textContanierView addSubview:detailLabel];
        
        
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).with.offset(titleLabelBottomOffset);
            make.height.mas_equalTo(detailLabelHeight);
            make.width.mas_equalTo(detailLabelWidth);
            make.centerX.equalTo(textContanierView);
        }];
    }
}

- (void)handleRegister
{
    JCHRegisterViewController *registerVC = [[[JCHRegisterViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:registerVC] autorelease];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)handleLogin
{
    JCHLoginViewController *loginVC = [[[JCHLoginViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:loginVC] autorelease];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)scrollView.contentOffset.x / kScreenWidth;
    _pageControl.currentPage = index;
    [_textScrollView setContentOffset:scrollView.contentOffset animated:YES];
}

@end
