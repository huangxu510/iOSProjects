//
//  UINavigationController+JCHNav.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "UINavigationController+JCHNav.h"

@implementation UINavigationController (JCHNav)

#if 0
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    
    UIView *gestureView = gesture.view;
    
    NSMutableArray *targets = [gesture valueForKey:@"targets"];
    
    id gestureRecognizerTarget = [targets firstObject];
    
    id navigationInteractiveTransition = [gestureRecognizerTarget valueForKey:@"target"];
    
    SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
    
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:navigationInteractiveTransition action:handleTransition];
    popRecognizer.delegate = self;
    [gestureView addGestureRecognizer:popRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.viewControllers.count != 1 && ![[self valueForKey:@"isTransitioning"] boolValue];
}
#endif

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self pushViewController:viewController animated:animated];
    [CATransaction commit];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated completion:(void (^)(void))completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self setViewControllers:viewControllers animated:animated];
    [CATransaction commit];
}

@end
