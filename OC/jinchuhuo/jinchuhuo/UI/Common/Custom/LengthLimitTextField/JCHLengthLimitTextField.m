//
//  JCHLengthLimitTextField.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHLengthLimitTextField.h"

@interface JCHLengthLimitTextField () <UITextFieldDelegate>

@property (retain, nonatomic) NSString *textBeforeChanged;
@property (assign, nonatomic, readwrite) id<UITextFieldDelegate> textFieldDelegate;

@end

@implementation JCHLengthLimitTextField


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.decimalPointOnly = YES;
        self.integerLength = 15;
        self.decimalLength = 2;
        self.maxStringLength = 32;
        
        [super setDelegate:self];
         
//        self.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.textBeforeChanged = nil;
    [super dealloc];
}

- (void)setText:(NSString *)text
{
    if (text.length <= self.text.length) {
        [super setText:text];
    } else {
        // 当包含小数点不能继续输入小数点
        if (self.decimalPointOnly) {
            
            // 禁止输入超过一个小数点
            if ([self.text containsString:@"."]) {
                
                NSMutableString *tempText = [text mutableCopy];
                NSInteger numberOfPoint = [tempText replaceOccurrencesOfString:@"." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, tempText.length)];
                if (numberOfPoint > 1) {
                    return;
                }
                
                
                NSArray *components = [text componentsSeparatedByString:@"."];
                
                NSString *intengerString = nil;
                NSString *decimalString = nil;
                if (components.count >= 2) {
                    intengerString = [components firstObject];
                    decimalString = [components lastObject];
                } else if (components.count == 1){
                    NSRange range = [text rangeOfString:@"."];
                    if (range.location == text.length) {
                        intengerString = [components firstObject];
                    } else if (range.location == 0) {
                        decimalString = [components firstObject];
                    }
                } else {
                    // pass
                }
                
                
                // 整数部分不能超过限制
                if (intengerString.length > self.integerLength) {
                    return;
                }
                
                // 小数部分不能超过限制
                if (decimalString.length > self.decimalLength) {
                    return;
                }
            } else {
                if (text.length > self.integerLength) {
                    return;
                }
            }
        } else {
            if (text.length > self.maxStringLength) {
                return;
            }
        }
        
        [super setText:text];
    }
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.textFieldDelegate = delegate;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.textFieldDelegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.textFieldDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.textFieldDelegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.textFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)]) {
        [self.textFieldDelegate textFieldDidEndEditing:textField reason:reason];
    }
    
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.textFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.textFieldDelegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.textFieldDelegate textFieldShouldReturn:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [self.text stringByAppendingString:string];
    // 当包含小数点不能继续输入小数点
    if (self.decimalPointOnly) {
        
        // 禁止输入超过一个小数点
        if ([self.text containsString:@"."]) {
            
            if ([string containsString:@"."]) {
                return NO;
            }
            
            
            NSArray *components = [newText componentsSeparatedByString:@"."];
            
            NSString *intengerString = nil;
            NSString *decimalString = nil;
            if (components.count >= 2) {
                intengerString = [components firstObject];
                decimalString = [components lastObject];
            } else if (components.count == 1){
                NSRange range = [newText rangeOfString:@"."];
                if (range.location == newText.length) {
                    intengerString = [components firstObject];
                } else if (range.location == 0) {
                    decimalString = [components firstObject];
                }
            } else {
                // pass
            }
            
            
            // 整数部分不能超过限制
            if (intengerString.length > self.integerLength) {
                return NO;
            }
            
            // 小数部分不能超过限制
            if (decimalString.length > self.decimalLength) {
                return NO;
            }
        } else {
            if (newText.length > self.integerLength) {
                return NO;
            }
        }
    } else {
        if (newText.length > self.maxStringLength) {
            return NO;
        }
    }
    return YES;
}



@end
