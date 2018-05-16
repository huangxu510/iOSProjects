//
//  MTNavigationBar.m
//  NavigationBarTest
//
//  Created by huangxu on 2017/9/22.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import "MTNavigationBar.h"

@implementation MTNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subView in self.subviews) {
        NSString *stringFromClass = NSStringFromClass(subView.class);
        NSLog(@"%@", stringFromClass);
        if ([stringFromClass containsString:@"BarBackground"]) {
            subView.frame = self.bounds;
        }
        if ([stringFromClass containsString:@"UINavigationBarContentView"]) {
            CGRect frame = subView.frame;
            frame.origin.y = 20;
            subView.frame = frame;
        }
    }
}

@end
