//
//  JCHPlaceholderView.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPlaceholderView.h"
#import "CommonHeader.h"

@implementation JCHPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.label = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(14)
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentCenter];
        [self addSubview:self.label];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.mas_equalTo(20);
        }];
        
        self.imageView = [[[UIImageView alloc] init] autorelease];
        self.imageView.contentMode = UIViewContentModeBottom;
        [self addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.label.mas_top).with.offset(-20);
            make.left.right.top.equalTo(self);
        }];
        
        
    }
    return self;
}

- (void)dealloc
{
    self.label = nil;
    self.imageView = nil;
    [super dealloc];
    return;
}

@end
