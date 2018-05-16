//
//  JCHHomePageView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHHomePageView.h"

@implementation JCHHomePageView

- (void)dealloc
{
    [self.subView release];
    [super dealloc];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.bounds, point) ||
        CGRectContainsPoint(self.subView.frame, point))
    {
        return YES;
    }
    return NO;
}

@end
