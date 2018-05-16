//
//  JCHIntroductionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/10.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHIntroductionView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"

@interface JCHIntroductionView () <UIScrollViewDelegate>
{
    UIScrollView *_contentScrollView;
    UIPageControl *_pageControl;
    UIButton *_nextStepButton;
    UIView *_maskView;
}
@end

@implementation JCHIntroductionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    
    const CGFloat contentScrollViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:296];;
    const CGFloat nextStepButtonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    _contentScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kWidth,  contentScrollViewHeight)] autorelease];
    _contentScrollView.contentSize = CGSizeMake(kWidth * 3, 0);
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;

    [self addSubview:_contentScrollView];
    
    const CGFloat pageControlHeight = [JCHSizeUtility calculateWidthWithSourceWidth:20];
    const CGFloat pageControlBottomOffset = [JCHSizeUtility calculateWidthWithSourceWidth:5];
    _pageControl = [[[UIPageControl alloc] init] autorelease];
    _pageControl.frame = CGRectMake(0, contentScrollViewHeight - pageControlHeight - pageControlBottomOffset, kWidth, pageControlHeight);
    _pageControl.numberOfPages = 3;
    [self addSubview:_pageControl];
    
    NSArray *imageNames = @[@"homepage_welcome_pic1", @"homepage_welcome_pic2", @"homepage_welcome_pic3"];
    
    NSMutableArray *imageViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNames[i]]] autorelease];
        imageView.frame = CGRectMake(i * kWidth, 0, kWidth, contentScrollViewHeight);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_contentScrollView addSubview:imageView];
        [imageViews addObject:imageView];
    }
    
    UIView *leftView = [[[UIView alloc] initWithFrame:CGRectMake(-kWidth, 0, kWidth, contentScrollViewHeight)] autorelease];
    leftView.backgroundColor = UIColorFromRGB(0xef8080);
    [imageViews[0] addSubview:leftView];
    
    UIView *rightView = [[[UIView alloc] initWithFrame:CGRectMake(kWidth, 0, kWidth, contentScrollViewHeight)] autorelease];
    rightView.backgroundColor = UIColorFromRGB(0x8cbbeb);
    [imageViews[2] addSubview:rightView];
    
    _nextStepButton = [JCHUIFactory createButton:CGRectMake(0, contentScrollViewHeight, kWidth, nextStepButtonHeight)
                                      target:self
                                      action:@selector(nextStep)
                                       title:@"下一步"
                                  titleColor:JCHColorMainBody
                             backgroundColor:nil];
    _nextStepButton.titleLabel.font = [UIFont jchSystemFontOfSize:17.0f];
    _nextStepButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:_nextStepButton];
}

- (void)show
{
    _maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)] autorelease];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0;
    [self.superview addSubview:_maskView];
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
        _maskView.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformRotate(self.transform, M_PI / 36);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)hide
{
    CGRect frame = self.frame;
    frame.origin.y = kScreenHeight;
    [UIView animateWithDuration:0.08 animations:^{
        self.transform = CGAffineTransformRotate(self.transform, -M_PI / 36);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [_maskView removeFromSuperview];
        }];
    }];
}

- (void)nextStep
{
    CGPoint currentOffset = _contentScrollView.contentOffset;
    currentOffset.x += kWidth;
    [_contentScrollView setContentOffset:currentOffset animated:YES];
}

- (void)updateButtonAndPageControl:(CGPoint)offset
{
    NSInteger page = (NSInteger)((offset.x + 10) / kWidth);
    NSLog(@"%f", kWidth);
    _pageControl.currentPage = page;
    if (offset.x + 10 >= (kWidth * 2)) {
        [_nextStepButton setTitle:@"开始吧" forState:UIControlStateNormal];
        [_nextStepButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [_nextStepButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [_nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextStepButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [_nextStepButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateButtonAndPageControl:scrollView.contentOffset];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateButtonAndPageControl:scrollView.contentOffset];
}

@end
