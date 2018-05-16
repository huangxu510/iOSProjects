//
//  JCHPickerView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHPickerView.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "UIView+JCHView.h"

enum {
    kUIPickerTopBarHeight = 48,
};

@interface JCHPickerView ()
{
    BOOL hasCreateUI;
    BOOL isPickerShow;
    UILabel *topTitleLabel;
}

@property (nonatomic, retain) NSString *pickerTopTitle;

@end

@implementation JCHPickerView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title  showInView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        hasCreateUI = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.pickerTopTitle = title;
        [superView addSubview:self];
    }
    
    return self;
}

- (void)dealloc
{
    [self.pickerTopTitle release];
    [self.pickerView release];
    
    [super dealloc];
    return;
}

- (BOOL)isShow
{
    return isPickerShow;
}

- (void)setTitle:(NSString *)title
{
    topTitleLabel.text = title;
}

- (void)createUI:(NSString *)title superView:(UIView *)superView
{
    //CGFloat currentPickerTopBarHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kUIPickerTopBarHeight];
    CGRect menuBarRect = CGRectMake(0,
                                    0,
                                    self.frame.size.width,
                                    kUIPickerTopBarHeight);
    UIView *topMenuBar = [[[UIView alloc] initWithFrame:menuBarRect] autorelease];
    topMenuBar.backgroundColor = JCHColorGlobalBackground;
    [topMenuBar addSeparateLineWithFrameTop:YES bottom:YES];
    [self addSubview:topMenuBar];
    
    CGRect titleLabelRect = CGRectMake(self.frame.size.width / 4,
                                       0,
                                       self.frame.size.width / 2,
                                       kUIPickerTopBarHeight);
    topTitleLabel = [JCHUIFactory createLabel:titleLabelRect
                                              title:title
                                               font:[UIFont systemFontOfSize:18.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    [topMenuBar addSubview:topTitleLabel];
    
    const CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    CGRect buttonRect = CGRectMake(self.frame.size.width - buttonWidth - 10, 0, buttonWidth, kUIPickerTopBarHeight);
    UIButton *hideKeyboardButton = [JCHUIFactory createButton:buttonRect
                                                    target:self
                                                    action:@selector(hide)
                                                     title:@"完成"
                                                titleColor:JCHColorMainBody
                                           backgroundColor:[UIColor clearColor]];
    [topMenuBar addSubview:hideKeyboardButton];
    
    CGRect pickerRect = CGRectMake(0,
                                   kUIPickerTopBarHeight,
                                   self.frame.size.width,
                                   self.frame.size.height - kUIPickerTopBarHeight);
    self.pickerView = [[[UIPickerView alloc] initWithFrame:pickerRect] autorelease];
    self.pickerView.delegate = self.delegate;
    self.pickerView.dataSource = self.dataSource;
    [self addSubview:self.pickerView];
    
    [superView addSubview:self];
    
    return;
}

- (void)show
{
    if ([self.delegate respondsToSelector:@selector(pickerViewWillShow:)]) {
        [self.delegate pickerViewWillShow:self];
    }
    
    isPickerShow = YES;
    
    if (NO == hasCreateUI) {
        hasCreateUI = YES;
        [self createUI:self.pickerTopTitle
             superView:self.superview];
    }
    
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
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(pickerViewDidShow:)]) {
                             [self.delegate pickerViewDidShow:self];
                         }
                     }];
    
}

- (void)hide
{
    if ([self.delegate respondsToSelector:@selector(pickerViewWillHide:)]) {
        [self.delegate pickerViewWillHide:self];
    }
    
    isPickerShow = NO;
    
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect targetPickerFrame = self.frame;
                         targetPickerFrame.origin.y = self.superview.frame.size.height + targetPickerFrame.size.height;
                         self.frame = targetPickerFrame;
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(pickerViewDidHide:)]) {
                             [self.delegate pickerViewDidHide:self];
                         }
                     }];
    
}


@end
