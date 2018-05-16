//
//  JCHBubbleView.m
//  jinchuhuo
//
//  Created by huangxu on 16/2/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBubbleView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.topLabel release];
    [self.bottomLabel release];
    
    [super dealloc];
}


- (void)createUI
{
    UIImage *originalImage = [UIImage imageNamed:@"addgoods_bg_01"];
    UIImage *stretchImage = [originalImage stretchableImageWithLeftCapWidth:5 topCapHeight:1];
    self.image = stretchImage;
    
    self.topLabel  = [[[UILabel alloc] init] autorelease];
    
}

@end
