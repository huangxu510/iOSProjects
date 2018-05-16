//
//  JCHInventoryPullDownView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInventoryPullDownContainerView.h"
#import "JCHInventoryPullDownSKUView.h"
#import "CommonHeader.h"

@interface JCHInventoryPullDownContainerView()

@property (retain, nonatomic, readwrite) UIView *maskView;

@end

@implementation JCHInventoryPullDownContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maskView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0;
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAction)] autorelease];
        [self.maskView addGestureRecognizer:tap];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)dealloc
{
    self.maskView = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.maskView.frame = CGRectMake(0, self.frame.origin.y, kScreenWidth, kScreenHeight);
    
    [self.superview addSubview:self.maskView];
    [self.superview bringSubviewToFront:self];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)show:(JCHInventoryPullDownBaseView *)view
{
    if (view.maxHeight == 0 && [view isKindOfClass:[JCHInventoryPullDownSKUView class]]) {
        [self showAlertView];
        return;
    }
    
    
    self.maxHeight = view.maxHeight;
    
    [self bringSubviewToFront:view];
    
    CGRect frame = self.frame;
    frame.size.height = self.maxHeight;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
        _maskView.alpha = 0.5;
    }];
    self.isShow = YES;
}
 
- (void)hideCompletion:(CompletionBlock)completion
{
    CGRect frame = self.frame;
    frame.size.height = 0;
    self.isShow = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
        _maskView.alpha = 0;
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion();
        }
    }] ;
}


- (void)hideAction
{
    if ([self.delegate respondsToSelector:@selector(clickMaskView)]) {
        [self.delegate clickMaskView];
    }
}

- (void)showAlertView
{
    if ([self.delegate respondsToSelector:@selector(showAlertView)]) {
        [self.delegate showAlertView];
    }
}

@end
