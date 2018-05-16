//
//  JCHBottomArrowButton.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKIt/UIKIt.h>

@interface JCHBottomArrowButton : UIControl

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *detailLabel;

//默认是NO
@property (nonatomic, assign) BOOL detailLabelHidden;

@end
