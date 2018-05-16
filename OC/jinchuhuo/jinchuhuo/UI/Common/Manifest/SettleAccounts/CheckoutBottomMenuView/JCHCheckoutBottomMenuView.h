//
//  JCHCheckoutBottomMenuView.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"

enum
{
    kJCHCheckouBottomMenuTagBase = 1000,
    kJCHCheckoutBottomMenuEraseTag,         //抹零
    kJCHCheckoutBottomMenuDiscountTag,      //打折
    kJCHCheckoutBottomMenuTemporaryManifestTag,        //挂单
    kJCHCheckoutBottomMenuMemberTag,        //会员
    
    
    kJCHPayWayCachTag,                      //现金
    kJCHPayWayUnionPayTag,                  //银联
    kJCHPayWayWeChatTag,                    //微信
    kJCHPayWayAlipayTag,                    //支付宝
    kJCHPayWaySavingsCardTag,               //储值卡
    kJCHPayWayTickTag,                      //赊购
};

@protocol JCHCheckoutBottomMenuViewDelegate <NSObject>

@optional
- (void)handleBottomMenuViewAction:(UIButton *)button;
- (void)handleSelectPayWay:(UIButton *)button;

@end

@interface JCHCheckoutBottomMenuView : UIView

@property (nonatomic, assign) id <JCHCheckoutBottomMenuViewDelegate> delegate;

- (void)setButton:(NSInteger)buttonTag Enabled:(BOOL)enabled;
- (void)showPayWay:(BOOL)animation;
- (void)hidePayWay;
- (void)setBackButtonHidden:(BOOL)hidden;

@end
