//
//  JCHTextImageView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTextImageView.h"

@implementation JCHTextImageView

- (void)drawRect:(CGRect)rect
{
    [self.text drawInRect:rect];
}

- (void)dealloc
{
    [self.text release];
    [super dealloc];
}


@end
