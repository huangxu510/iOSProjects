//
//  JCHOpenWeChatPayViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHOpenWeChatPayViewController.h"
#import "JCHClauseViewController.h"
#import "JCHBindingAccountViewController.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHOpenWeChatPayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"开通微信支付";
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:305.0f];
    CGFloat imageViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:120.0f];
    
    CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:125.0f];
    CGFloat buttonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:40.0f];
    CGFloat buttonRightOffset = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    CGFloat buttonBottomOffset = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    UIView *topContainerView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:topContainerView];
    
    [topContainerView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    [topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY);
    }];
    
    UIImageView *topImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_checkout_sign"]] autorelease];
    [self.view addSubview:topContainerView];
    
    [topContainerView addSubview:topImageView];
    
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(topContainerView);
        make.width.mas_equalTo(imageViewWidth);
        make.centerY.equalTo(topContainerView);
        make.height.mas_equalTo(imageViewHeight);
    }];
    
    UIButton *topButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(handleKnowSignDetail)
                                               title:@"了解签约详情"
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:JCHColorBlueButton];
    topButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    topButton.layer.cornerRadius = 5.0f;
    [topContainerView addSubview:topButton];
    
    [topButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.bottom.equalTo(topImageView);
        make.right.equalTo(topImageView).with.offset(-buttonRightOffset);
    }];
    

    UIView *bottomContainerView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:bottomContainerView];
    
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_centerY);
    }];

    UIImageView *bottomImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_checkout_related"]] autorelease];
    
    [self.view addSubview:bottomImageView];
    
    [bottomContainerView addSubview:bottomImageView];
    
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bottomContainerView);
        make.width.mas_equalTo(imageViewWidth);
        make.centerY.equalTo(bottomContainerView);
        make.height.mas_equalTo(imageViewHeight);
    }];

    UIButton *bottomButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(handleBinding)
                                               title:@"已签约，去绑定"
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:JCHColorBlueButton];
    bottomButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    bottomButton.layer.cornerRadius = 5.0f;
    [bottomContainerView addSubview:bottomButton];
    
    [bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.bottom.equalTo(bottomImageView).with.offset(buttonBottomOffset);
        make.right.equalTo(bottomImageView).with.offset(-buttonRightOffset);
    }];
}

- (void)handleKnowSignDetail
{
    JCHClauseViewController *clauseVC = [[[JCHClauseViewController alloc] initWithHTMLName:@"bindguide" title:@"签约绑定指引"] autorelease];
    [self.navigationController pushViewController:clauseVC animated:YES];
}

- (void)handleBinding
{
    JCHBindingAccountViewController *bindingAccountVC = [[[JCHBindingAccountViewController alloc] init] autorelease];
    [self.navigationController pushViewController:bindingAccountVC animated:YES];
}

@end
