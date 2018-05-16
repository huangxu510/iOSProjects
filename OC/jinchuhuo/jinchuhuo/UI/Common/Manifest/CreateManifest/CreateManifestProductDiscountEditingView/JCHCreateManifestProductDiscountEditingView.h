//
//  JCHCreateManifestProductDiscountEditingView.h
//  jinchuhuo
//
//  Created by huangxu on 16/9/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHCreateManifestProductDiscountEditingView : UIView

@property (nonatomic, retain) UILabel *discountLabel;
@property (nonatomic, copy) void(^hideViewBlock)(void);

@end
