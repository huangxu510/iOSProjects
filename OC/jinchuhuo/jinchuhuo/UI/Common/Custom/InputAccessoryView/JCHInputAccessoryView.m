//
//  JCHInputAccessoryView.m
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHInputAccessoryView.h"
#import "JCHUIFactory.h"
#import "JCHUIDebugger.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"

@interface JCHInputAccessoryView ()
{
    UIButton *hideKeyboardButton;
    UIView *topLine;
    UIView *bottomLine;
}
@end

@implementation JCHInputAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    self.backgroundColor = JCHColorGlobalBackground;

    hideKeyboardButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(hide)
                                              title:@"完成"
                                         titleColor:JCHColorMainBody
                                    backgroundColor:[UIColor clearColor]];
    [self addSubview:hideKeyboardButton];
    
    topLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    topLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:topLine];
    
    bottomLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:bottomLine];
    
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat buttonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:60.0f];
    CGRect buttonRect = CGRectMake(self.frame.size.width - buttonWidth - 10, 0, buttonWidth, self.frame.size.height);
    hideKeyboardButton.frame = buttonRect;
    
    topLine.frame = CGRectMake(0, 0, self.frame.size.width, kSeparateLineWidth);
    bottomLine.frame = CGRectMake(0, self.frame.size.height - kSeparateLineWidth, self.frame.size.width, kSeparateLineWidth);
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    return;
}

- (void)hide
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                               to:nil
                                             from:nil
                                         forEvent:nil];
}

@end
