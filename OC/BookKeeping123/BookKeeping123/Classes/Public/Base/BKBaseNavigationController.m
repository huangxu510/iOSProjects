//
//  BKBaseNavigationController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKBaseNavigationController.h"

@interface BKBaseNavigationController ()

@end

@implementation BKBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 拦截Push
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated{
    if (viewControllers.count > 0) {
        viewControllers.lastObject.hidesBottomBarWhenPushed = YES;
    }
    [super setViewControllers:viewControllers animated:animated];
}

@end
