//
//  JCHUIDebugger.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHUIDebugger.h"

@implementation JCHUIDebugger

+ (void)showBorder:(UIView *)theView
{
    theView.layer.borderColor = [[UIColor redColor] CGColor];
    theView.layer.borderWidth = 1.0f;
    
}

@end
