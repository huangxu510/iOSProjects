//
//  UINavigationController+JCHNav.h
//  jinchuhuo
//
//  Created by huangxu on 16/6/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (JCHNav) <UIGestureRecognizerDelegate>

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                completion:(void (^)(void))completion;

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
                  animated:(BOOL)animated
                completion:(void (^)(void))completion;

@end
