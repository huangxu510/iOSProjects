//
//  JCHCreateManifestTotalDiscountEditingView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHSettleAccountsKeyboardView.h"
//typedef NS_ENUM(NSInteger, JCHCreateManifestTotalDiscountEditingViewEditMode) {
    //kJCHCreateManifestTotalDiscountEditingViewEditModeDiscount,
    //kJCHCreateManifestTotalDiscountEditingViewEditModeAmount,
//};


@class JCHCreateManifestTotalDiscountEditingView;
@protocol JCHCreateManifestTotalDiscountEditingViewDelegate <NSObject>

- (void)createManifestTotalDiscountEditingViewTaped:(JCHCreateManifestTotalDiscountEditingView *)discountEditingView;

@end

@interface JCHCreateManifestTotalDiscountEditingView : UIView

@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, assign) CGFloat discount;
@property (nonatomic, retain) NSString *reducedAmountString;
@property (nonatomic, assign) CGFloat reduceAmount;

@property (nonatomic, retain) UILabel *discountLabel;
@property (nonatomic, retain) UILabel *reducedAmountLabel;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, assign) JCHSettleAccountsKeyboardViewEditMode editMode;

@property (nonatomic, assign) id<JCHCreateManifestTotalDiscountEditingViewDelegate> delegate;


@end
