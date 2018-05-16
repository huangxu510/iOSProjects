//
//  JCHInputView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInputView.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"

@interface JCHInputView () <UITextViewDelegate>
{
    CGFloat _textViewWidth;
}

@end

@implementation JCHInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = JCHColorGlobalBackground;
        _textViewWidth = kScreenWidth -  2 * kStandardLeftMargin;
        
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.textView release];
    [self.placeholderLabel release];
    
    [super dealloc];
}


- (void)createUI
{
    self.textView = [[[UITextView alloc] init] autorelease];
    self.textView.delegate = self;
    self.textView.frame = CGRectMake(kStandardLeftMargin, 5, _textViewWidth, self.frame.size.height - 10);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [UIFont systemFontOfSize:14.0f];
    self.textView.textColor = UIColorFromRGB(0x4a4a4a);
    self.textView.returnKeyType = UIReturnKeyDone;
    
    self.textView.layer.borderColor = JCHColorSeparateLine.CGColor;
    self.textView.layer.borderWidth = kSeparateLineWidth;
    self.textView.layer.cornerRadius = 2;
    [self addSubview:self.textView];
    
    self.placeholderLabel = [[[UILabel alloc] init] autorelease];
    self.placeholderLabel.frame = CGRectMake(2 * kStandardLeftMargin, 5, kScreenWidth / 2, self.frame.size.height - 10);
    self.placeholderLabel.textColor = UIColorFromRGB(0xd5d5d5);
    self.placeholderLabel.text = @"请输入备注";
    self.placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:self.placeholderLabel];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //按return键
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(inputViewWillHide:textView:)]) {
            [self.delegate inputViewWillHide:self textView:textView];
        }
        [self hide];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.text != nil && ![textView.text isEqualToString:@""]) {
        self.placeholderLabel.text = @"";
    } else {
        self.placeholderLabel.text = @"请输入备注";
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.placeholderLabel.text = @"";
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@""]) {
        self.placeholderLabel.text = @"请输入备注";
    }
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    
    self.backgroundMaskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)] autorelease];
    self.backgroundMaskView.backgroundColor = [UIColor blackColor];
    self.backgroundMaskView.alpha = 0;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)] autorelease];
    [self.backgroundMaskView addGestureRecognizer:tap];
    [window addSubview:self.backgroundMaskView];
    
    //self.textView.inputAccessoryView = self;
    [self.textView becomeFirstResponder];
    
    [window addSubview:self];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundMaskView.alpha = 0.3;
    }];
}

- (void)hide
{
    [self.textView resignFirstResponder];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundMaskView removeFromSuperview];
        self.backgroundMaskView = nil;
    }];
}




@end
