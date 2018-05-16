//
//  JCHInputView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCHInputView;
@protocol JCHInputViewDelegate <NSObject>

- (void)inputViewWillHide:(JCHInputView *)inputView textView:(UITextView *)contentTextView;

@end

@interface JCHInputView : UIView

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, retain) UIView *backgroundMaskView;
@property (nonatomic, assign) id <JCHInputViewDelegate> delegate;

- (void)show;
- (void)hide;

@end
