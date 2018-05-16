//
//  JCHCheckoutBottomMenuView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCheckoutBottomMenuView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHCheckoutBottomMenuView
{
    UIButton *_backButton;
}
- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat payWayTitleLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:44.0f noStretchingIn6Plus:YES];
    if (CGRectContainsPoint(self.bounds, point) ||
        CGRectContainsPoint(CGRectMake(kScreenWidth, -payWayTitleLabelHeight, kScreenWidth, payWayTitleLabelHeight), point))
    {
        return YES;
    }
    return NO;
}

- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonSpacing = 6;
    CGFloat leftButtonWidth = (kScreenWidth - 4 * buttonSpacing) / 3;
    CGFloat leftButtonHeight = (kHeight - 3 * buttonSpacing) / 2;
    
    NSArray *titleArray = @[@"抹零", @"打折", @"挂单", @"会员"];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    enum JCHOrderType currentManifestType = manifestStorage.currentManifestType;
    JCHManifestMemoryType currentMemoryType = manifestStorage.manifestMemoryType;
    
    for (NSInteger i = 0; i < 4; i++) {
        
        CGFloat buttonX = leftButtonWidth * (i % 2) + buttonSpacing * (i % 2 + 1);
        CGFloat buttonY = leftButtonHeight * (i / 2) + buttonSpacing * (i / 2 + 1);
        
        JCHButton *button = [JCHUIFactory createJCHButton:CGRectMake(buttonX, buttonY, leftButtonWidth, leftButtonHeight)
                                                   target:self
                                                   action:@selector(buttonAction:)
                                                    title:titleArray[i]
                                               titleColor:JCHColorMainBody
                                          backgroundColor:JCHColorGlobalBackground];
        
        
        button.layer.cornerRadius = 4;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
        button.labelVerticalOffset = -4;
        button.tag = i + kJCHCheckouBottomMenuTagBase + 1;
        
        NSString *imageName = [NSString stringWithFormat:@"icon_menu_%ld", (long)i + 1];
        NSString *disabledImageName = [NSString stringWithFormat:@"icon_menu_%ld_disable", (long)i + 1];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
        
        [button setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
        
        [self addSubview:button];
        
        
        if (currentMemoryType == kJCHManifestMemoryTypeNew || manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {//新建货单 / 复制货单
            //进货单
            if (currentManifestType == kJCHOrderPurchases) {
                if ((i == 0 || i == 1 || i == 2)) {
                    button.enabled = NO;
                }
                if (i == 3) [button setTitle:@"供应商" forState:UIControlStateNormal];
            } //出货单
        } else if (currentMemoryType == kJCHManifestMemoryTypeEdit) { //编辑货单
            //进货单
            if (currentManifestType == kJCHOrderPurchases) {
                if ((i == 0 || i == 1 || i == 2)) {
                    button.enabled = NO;
                }
                if (i == 3) [button setTitle:@"供应商" forState:UIControlStateNormal];
            } //出货单
            else if (currentManifestType == kJCHOrderShipment)  {
                if (i == 2) {
                    button.enabled = NO;
                }
            }
        } else {
            //pass
        }
    }
    
    UIButton *checkoutButton = [JCHUIFactory createButton:CGRectMake(3 * buttonSpacing + 2 * leftButtonWidth, buttonSpacing, leftButtonWidth, leftButtonHeight * 2 + buttonSpacing)
                                                   target:self
                                                   action:@selector(showPayWay)
                                                    title:@"收银"
                                               titleColor:[UIColor whiteColor]
                                          backgroundColor:UIColorFromRGB(0x69a4f1)];
    if (currentManifestType == kJCHOrderPurchases) {
        [checkoutButton setTitle:@"付款" forState:UIControlStateNormal];
    }
    checkoutButton.titleLabel.font = [UIFont jchSystemFontOfSize:25.0f];
    checkoutButton.layer.cornerRadius = 4;
    checkoutButton.clipsToBounds = YES;
    [self addSubview:checkoutButton];
    
    CGFloat payWayTitleLabelHeight = 44.0f;
    UILabel *payWayTitleLabel = [JCHUIFactory createLabel:CGRectMake(kScreenWidth, -payWayTitleLabelHeight, kScreenWidth, payWayTitleLabelHeight)
                                                    title:@"选择收款通道"
                                                     font:[UIFont jchSystemFontOfSize:15.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentCenter];
    if (currentManifestType == kJCHOrderPurchases || currentManifestType == kJCHOrderPayment) {
        payWayTitleLabel.text = @"选择付款通道";
    }
    [payWayTitleLabel layoutIfNeeded];
    payWayTitleLabel.backgroundColor = [UIColor whiteColor];
    [payWayTitleLabel addSeparateLineWithFrameTop:YES bottom:NO];
    [self addSubview:payWayTitleLabel];
    
    _backButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, payWayTitleLabelHeight)
                                      target:self
                                      action:@selector(hidePayWay)
                                       title:nil
                                  titleColor:nil
                             backgroundColor:nil];
    
    [_backButton setImage:[UIImage imageNamed:@"bt_payway_back"] forState:UIControlStateNormal];
    payWayTitleLabel.userInteractionEnabled = YES;
    [payWayTitleLabel addSubview:_backButton];
    
    if (currentManifestType == kJCHOrderPayment || currentManifestType == kJCHOrderReceipt) {
        _backButton.hidden = YES;
    }
    
    CGFloat rightButtonWidth = leftButtonWidth;
    CGFloat rightButtonHeight = (kHeight - 3 * buttonSpacing) / 2;
    titleArray = @[@"现金", @"银联", @"微信", @"支付宝", @"储值卡", @"赊销"];
    for (NSInteger i = 0; i < 6; i++) {
        
        CGFloat buttonX = rightButtonWidth * (i % 3) + buttonSpacing * (i % 3 + 1);
        CGFloat buttonY = rightButtonHeight * (i / 3) + buttonSpacing * (i / 3 + 1);
        
        JCHButton *button = [JCHUIFactory createJCHButton:CGRectMake(kScreenWidth + buttonX, buttonY, leftButtonWidth, rightButtonHeight)
                                                   target:self
                                                   action:@selector(payWayButtonAction:)
                                                    title:titleArray[i]
                                               titleColor:JCHColorMainBody
                                          backgroundColor:JCHColorGlobalBackground];
        
        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
        button.labelVerticalOffset = -6;
        button.tag = i + kJCHCheckouBottomMenuTagBase + 5;
        NSString *imageName = [NSString stringWithFormat:@"icon_payway_%ld", i + 1];
        NSString *disabledImageName = [NSString stringWithFormat:@"icon_payway_%ld_disable", i + 1];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
        [button setTitleColor:JCHColorAuxiliary forState:UIControlStateDisabled];
        [self addSubview:button];
        
        if (currentManifestType == kJCHOrderPurchases || currentManifestType == kJCHOrderPayment) {
            if (i == 5) [button setTitle:@"赊购" forState:UIControlStateNormal];
        }
        
        
        if (currentMemoryType == kJCHManifestMemoryTypeNew || manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
            //新建货单 / 复制货单
            
            
            if (currentManifestType == kJCHOrderPurchases || currentManifestType == kJCHOrderPayment) {
                // 进货单、付款单除现金和赊购按钮其余都置灰
                if (i != 0 && i != 5) {
                    button.enabled = NO;
                }
            } else if (currentManifestType == kJCHOrderShipment || currentManifestType == kJCHOrderReceipt) {
                // 出货单 或者 收款单 支持微信支付
                
            }
        } else if (currentMemoryType == kJCHManifestMemoryTypeEdit) {  //编辑货单
            //除现金按钮其余都置灰
            if (i != 0) {
                button.enabled = NO;
            }
        } else {
            //pass
        }
    }
    
    UIView *topLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSeparateLineWidth)] autorelease];
    topLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:topLine];
}

- (void)buttonAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleBottomMenuViewAction:)]) {
        [self.delegate handleBottomMenuViewAction:sender];
    }
}

- (void)payWayButtonAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleSelectPayWay:)]) {
        [self.delegate handleSelectPayWay:sender];
    }
}

- (void)showPayWay
{
    [self showPayWay:YES];
}

- (void)showPayWay:(BOOL)animation
{
    CGRect frame = self.frame;
    frame.origin.x -= kScreenWidth;
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
        }];
    } else {
        self.frame = frame;
    }
}

- (void)hidePayWay
{
    CGRect frame = self.frame;
    frame.origin.x += kScreenWidth;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
}

- (void)setButton:(NSInteger)buttonTag Enabled:(BOOL)enabled
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag == buttonTag) {
            UIButton *button = (UIButton *)subview;
            button.enabled = enabled;
        }
    }
}

- (void)setBackButtonHidden:(BOOL)hidden
{
    _backButton.hidden = hidden;
}

@end
