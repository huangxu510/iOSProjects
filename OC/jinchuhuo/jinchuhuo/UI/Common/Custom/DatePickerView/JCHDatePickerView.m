//
//  JCHDatePickerView.m
//  jinchuhuo
//
//  Created by apple on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHDatePickerView.h"
#import "CommonHeader.h"

enum {
    kUIPickerTopBarHeight = 48,
};

@interface JCHDatePickerView ()
{
    UIDatePicker *contentPickerView;
    NSString *pickerTopTitle;
    BOOL isPickerShow;
    UIView *maskView;
}
@end

@implementation JCHDatePickerView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        pickerTopTitle = [title retain];
    }
    
    return self;
}

- (void)dealloc
{
    [pickerTopTitle release];
    [super dealloc];
    
    return;
}

- (BOOL)isShow
{
    return isPickerShow;
}

- (void)createUI:(NSString *)title
{
    CGRect menuBarRect = CGRectMake(0,
                                    0,
                                    self.frame.size.width,
                                    kUIPickerTopBarHeight);
    UIView *topMenuBar = [[[UIView alloc] initWithFrame:menuBarRect] autorelease];
    topMenuBar.backgroundColor = JCHColorGlobalBackground;
    [self addSubview:topMenuBar];
    
    CGRect titleLabelRect = CGRectMake(self.frame.size.width / 4,
                                       0,
                                       self.frame.size.width / 2,
                                       kUIPickerTopBarHeight);
    UILabel *topTitleLabel = [JCHUIFactory createLabel:titleLabelRect
                                              title:title
                                               font:nil
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    [topMenuBar addSubview:topTitleLabel];
    
    const CGFloat buttonWidth = 50;
    CGRect buttonRect = CGRectMake(self.frame.size.width - buttonWidth - 10, 0, buttonWidth, kUIPickerTopBarHeight);
    UIButton *hideKeyboardButton = [JCHUIFactory createButton:buttonRect
                                                    target:self
                                                       action:@selector(hide:)
                                                     title:@"完成"
                                                titleColor:JCHColorMainBody
                                           backgroundColor:[UIColor clearColor]];
    [topMenuBar addSubview:hideKeyboardButton];
    
    CGRect pickerRect = CGRectMake(0,
                                   kUIPickerTopBarHeight,
                                   self.frame.size.width,
                                   self.frame.size.height - kUIPickerTopBarHeight);
    contentPickerView = [[[UIDatePicker alloc] initWithFrame:pickerRect] autorelease];
    contentPickerView.datePickerMode = self.datePickerMode;//UIDatePickerModeDateAndTime;
    [contentPickerView addTarget:self
                          action:@selector(handleDateChanged:)
                forControlEvents:UIControlEventValueChanged];
    [self addSubview:contentPickerView];

    
    return;
}

- (void)handleDateChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleDateChanged:selectedDate:)]) {
        [self.delegate performSelector:@selector(handleDateChanged:selectedDate:) withObject:self withObject:contentPickerView.date];
    }
    
    return;
}

- (void)show
{
    isPickerShow = YES;
    
    UIView *window = [UIApplication sharedApplication].windows[0];
    
    maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)] autorelease];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [window addSubview:maskView];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)] autorelease];
    [maskView addGestureRecognizer:tap];
    
    
    [self createUI:pickerTopTitle];
    [window addSubview:self];
    
    
    CGRect viewRect = CGRectMake(0,
                                 self.superview.frame.size.height + self.frame.size.height,
                                 self.frame.size.width,
                                 self.frame.size.height);
    self.frame = viewRect;
    
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect targetPickerFrame = self.frame;
                         [self.superview bringSubviewToFront:self];
                         targetPickerFrame.origin.y = self.superview.frame.size.height - targetPickerFrame.size.height;
                         self.frame = targetPickerFrame;
                          maskView.alpha = 0.3;
                     }
                     completion:nil];
}

- (void)hide
{
    [self hide:nil];
}

- (void)hide:(id)sender
{
    isPickerShow = NO;
    
    if ([self.delegate respondsToSelector:@selector(handleDateChanged:selectedDate:)]) {
        [self.delegate performSelector:@selector(handleDateChanged:selectedDate:) withObject:self withObject:contentPickerView.date];
    }
    if ([self.delegate respondsToSelector:@selector(handleDatePickerViewWillHide:)]) {
        [self.delegate handleDatePickerViewWillHide:self];
    }
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect targetPickerFrame = self.frame;
                         targetPickerFrame.origin.y = self.superview.frame.size.height + targetPickerFrame.size.height;
                         self.frame = targetPickerFrame;
                         maskView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         
                         
                         if ([sender isKindOfClass:[UIButton class]]) {
                             if ([self.delegate respondsToSelector:@selector(handleDatePickerViewDidHide:selectedDate:)]) {
                                 [self.delegate performSelector:@selector(handleDatePickerViewDidHide:selectedDate:) withObject:self withObject:contentPickerView.date];
                             }
                         }
                         
                         [maskView removeFromSuperview];
                         maskView = nil;
                         [self removeFromSuperview];
                     }];
}


@end
