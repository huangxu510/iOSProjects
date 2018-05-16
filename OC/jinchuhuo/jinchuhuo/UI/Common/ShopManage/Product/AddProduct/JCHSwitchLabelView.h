//
//  JCHSwitchLabelView.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHSwitchLabelView : UIView

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UISwitch *switchButton;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setBottomLineHidden:(BOOL)hidden;
- (void)setTopLineHidden:(BOOL)hidden;
@end
