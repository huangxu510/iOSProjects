//
//  UIButton+EnlargeTouchArea.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeTouchArea)

//! @brief 扩大按钮的点击区域
- (void)setEnlargeEdgeWithTop:(CGFloat)top
                        right:(CGFloat)right
                       bottom:(CGFloat)bottom
                         left:(CGFloat)left;


@end
