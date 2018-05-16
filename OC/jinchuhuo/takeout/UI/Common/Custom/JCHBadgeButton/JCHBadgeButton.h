//
//  JCHBadgeButton.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHBadgeButton : UIButton

@property (nonatomic, assign) CGFloat imageViewVerticalOffset;
@property (nonatomic, assign) CGFloat labelVerticalOffset;

@property (nonatomic, assign) NSInteger badgeValue;
@property (nonatomic, retain) UIColor *badgeTextColor;
@property (nonatomic, retain) UIFont *badgeTextFont;
@property (nonatomic, retain) UIColor *badgeBackgroundColor;

@end
