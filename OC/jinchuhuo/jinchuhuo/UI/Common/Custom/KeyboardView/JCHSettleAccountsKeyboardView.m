//
//  JCHSettleAccountsKeyboardView.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettleAccountsKeyboardView.h"
#import "CommonHeader.h"

@interface JCHSettleAccountsKeyboardView ()

@property (nonatomic, retain) NSArray *buttonTitleArray;
@property (nonatomic, retain) NSString *currentEditText;
@property (nonatomic, retain) UIView *backgroundMaskView;

@end

@implementation JCHSettleAccountsKeyboardView
{
    UIView *_topView;
    UIView *_keyboardContainerView;
    
    CGFloat _topContainerViewHeight;
    CGFloat _keyboardHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
               keyboardHeight:(CGFloat)keyboardHeight
                      topView:(UIView *)topView
       topContainerViewHeight:(CGFloat)topContainerViewHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonTitleArray = @[@"0", @"7", @"8", @"9", @"4", @"5",@"6", @"1", @"2", @"3", @"."];
        _keyboardHeight = keyboardHeight;
        _topContainerViewHeight = topContainerViewHeight;
        _topView = topView;
        self.maxAmount = MAXFLOAT;
        self.unit_digits = 2;
        self.isFirstEdit = YES;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.buttonTitleArray = nil;
    self.currentEditText = nil;
    self.backgroundMaskView = nil;
    
    [super dealloc];
}

- (void)createUI
{
    [self addSubview:_topView];
    
    CGFloat topViewHeightMax = kScreenHeight - _keyboardHeight - kStatusBarHeight - kNavigatorBarHeight;
    
    if (_topContainerViewHeight > topViewHeightMax) {
        _topContainerViewHeight = topViewHeightMax;
    }
    _topView.frame = CGRectMake(0, 0, kScreenWidth, _topContainerViewHeight);
    
    _keyboardContainerView = [[[UIView alloc] initWithFrame:CGRectMake(0, _topContainerViewHeight, kScreenWidth, _keyboardHeight)] autorelease];
    [self addSubview:_keyboardContainerView];
    
    CGFloat buttonWidth = kScreenWidth / 4;
    CGFloat buttonHeight = _keyboardHeight / 4 ;
    for (NSInteger i = 0; i < 9; i++) {
        
        CGFloat buttonX = buttonWidth * (i % 3);
        CGFloat buttonY = buttonHeight * (i / 3);
        
        UIButton *numberButton = [JCHUIFactory createButton:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)
                                                     target:self
                                                     action:@selector(clickButton:)
                                                      title:self.buttonTitleArray[i + 1]
                                                 titleColor:[UIColor whiteColor]
                                            backgroundColor:JCHColorMainBody];
        [numberButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x3f3f3f)] forState:UIControlStateHighlighted];
        numberButton.titleLabel.font = [UIFont systemFontOfSize:28.0f];
        numberButton.tag = i + 1;
        numberButton.layer.cornerRadius = 0;
        [_keyboardContainerView addSubview:numberButton];
    }
    
    UIButton *zeroButton = [JCHUIFactory createButton:CGRectMake(0, 3 * buttonHeight, buttonWidth * 2, buttonHeight)
                                               target:self
                                               action:@selector(clickButton:)
                                                title:@"0"
                                           titleColor:[UIColor whiteColor]
                                      backgroundColor:JCHColorMainBody];
    zeroButton.titleLabel.font = [UIFont systemFontOfSize:28.0f];
    zeroButton.tag = 0;
    zeroButton.layer.cornerRadius = 0;
    [zeroButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x3f3f3f)] forState:UIControlStateHighlighted];
    [_keyboardContainerView addSubview:zeroButton];
    
    
    UIButton *dotButton = [JCHUIFactory createButton:CGRectMake(2 * buttonWidth, 3 * buttonHeight, buttonWidth, buttonHeight)
                                              target:self
                                              action:@selector(clickButton:)
                                               title:@"."
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:JCHColorMainBody];
    dotButton.titleLabel.font = [UIFont systemFontOfSize:28.0f];
    dotButton.tag = 10;
    dotButton.layer.cornerRadius = 0;
    [dotButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x3f3f3f)] forState:UIControlStateHighlighted];
    [_keyboardContainerView addSubview:dotButton];
    
    NSArray *functionButtonTitleArray = @[@"", @"清零", @"确定"];
    
    buttonHeight = _keyboardHeight / 3;
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat buttonX = buttonWidth * 3;
        CGFloat buttonY = buttonHeight * i;
        
        UIButton *functionButton = [JCHUIFactory createButton:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)
                                                       target:self
                                                       action:@selector(clickButton:)
                                                        title:functionButtonTitleArray[i]
                                                   titleColor:[UIColor whiteColor]
                                              backgroundColor:UIColorFromRGB(0x3f3f3f)];
        if (i == 0) {
            [functionButton setImage:[UIImage imageNamed:@"settleAccount_keyboard_delete"] forState:UIControlStateNormal];
        }
        functionButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        functionButton.tag = i + 11;
        functionButton.layer.cornerRadius = 0;
        [functionButton setBackgroundImage:[UIImage imageWithColor:JCHColorMainBody] forState:UIControlStateHighlighted];
        [_keyboardContainerView addSubview:functionButton];
    }
}


- (void)clickButton:(UIButton *)sender
{
    if (sender.tag < 10) {
        if ([self.delegate respondsToSelector:@selector(keyboardViewInputNumber:)]) {
            [self.delegate keyboardViewInputNumber:self.buttonTitleArray[sender.tag]];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(keyboardViewFunctionButtonClick:)]) {
            [self.delegate keyboardViewFunctionButtonClick:sender.tag];
        }
    }
    
    if (sender.tag == kJCHSettleAccountsKeyboardViewButtonTagOK) {
        if ([self.delegate respondsToSelector:@selector(keyboardViewOKButtonClick)]) {
            [self.delegate keyboardViewOKButtonClick];
        }
    }
    
    
    switch (self.editMode) {
        case kJCHSettleAccountsKeyboardViewEditModePrice:
        {
            [self editPriceText:sender];
        }
            break;
            
        case kJCHSettleAccountsKeyboardViewEditModeCount:
        {
            [self editCountText:sender];
        }
            break;
            
        case kJCHSettleAccountsKeyboardViewEditModeDiscount:
        {
            [self editDiscountText:sender];
        }
            break;
            
        case kJCHSettleAccountsKeyboardViewEditModeTotalAmount:
        {
            [self editPriceText:sender];
        }
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(keyboardViewEditingChanged:)]) {
        self.currentEditText = [self.delegate keyboardViewEditingChanged:self.currentEditText];
    }
}

- (void)editPriceText:(UIButton *)button
{
    self.currentEditText = [self.currentEditText stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    [self editCountText:button];
    
    
    CGFloat amount = [self.currentEditText doubleValue];
    if (amount > self.maxAmount) {
        self.currentEditText = [NSString stringWithFormat:@"%.2f", self.maxAmount];
    }
    self.currentEditText = [NSString stringWithFormat:@"¥%@", self.currentEditText];
}

- (void)editCountText:(UIButton *)button
{
    NSString *text = self.currentEditText;
    
    
    if (button.tag < 10) {
        
        if (self.isFirstEdit) {
            text = @"";
            self.isFirstEdit = NO;
        }
        
        if ([text doubleValue] == 0 && ![text containsString:@"."]) {
            text = @"";
        }
        
        if ([text isEqualToString:@"0.00"]) {
            text = @"";
        }
        
        if ([text containsString:@"."]) {
            NSString *suffix = [text substringFromIndex:[text rangeOfString:@"."].location + 1];
            
            if (self.editMode == kJCHSettleAccountsKeyboardViewEditModeCount) {
                if (suffix.length >= self.unit_digits) {
                    return;
                }
            } else if (self.editMode == kJCHSettleAccountsKeyboardViewEditModePrice || self.editMode == kJCHSettleAccountsKeyboardViewEditModeTotalAmount) {
                if (suffix.length >= 2) {
                    return;
                }
            }
        }
        text = [text stringByAppendingString:button.currentTitle];
    } else if (button.tag == kJCHSettleAccountsKeyboardViewButtonTagDot) {
        //如果包含 "." 返回
        if ([text containsString:@"."]) {
            return;
        }
        
        if (self.editMode == kJCHSettleAccountsKeyboardViewEditModeCount && self.unit_digits == 0) {
            return;
        }
        
        text = [text stringByAppendingString:@"."];
        
    } else if (button.tag == kJCHSettleAccountsKeyboardViewButtonTagBackSpace) {
        if (text.length > 1) {
            text = [text substringToIndex:text.length - 1];
        } else {
            text = @"0";
        }
    } else if (button.tag == kJCHSettleAccountsKeyboardViewButtonTagClear) {
        text = @"0";
    }
    self.currentEditText = text;
    self.isFirstEdit = NO;
}

- (void)editDiscountText:(UIButton *)button
{
    NSString *discountString = [self.currentEditText stringByReplacingOccurrencesOfString:@"折" withString:@""];
    
    NSMutableString *editStr = [NSMutableString stringWithString:discountString];
    
    
    if (button.tag < 10) {
        NSInteger intNumber = button.tag;
        
        if ([discountString isEqualToString:@"不打"]) {
            editStr = [NSMutableString stringWithString:@""];
        }
        
        
        if ((intNumber >= 0) && (intNumber <= 9)) {
            
            if (editStr.length == 2)
            {
                editStr = [NSMutableString stringWithString:@""];
            }
            
            if ((intNumber == 0) && ([editStr isEqualToString:@""] || [editStr isEqualToString:@"1"])) {
                return;
            }
            
            [editStr appendString:button.currentTitle];
        }
    } else if (button.tag == kJCHSettleAccountsKeyboardViewButtonTagDot) {
        return;
    } else if (button.tag == kJCHSettleAccountsKeyboardViewButtonTagBackSpace) {
        if (editStr.length > 0 && ![editStr isEqualToString:@"不打"]) {
            editStr = [NSMutableString stringWithString:[editStr substringToIndex:editStr.length - 1]];
        }
        
        if (editStr.length == 1) {
            editStr = [NSMutableString stringWithString:@"不打"];
        }
    } else if (button.tag == kJCHSettleAccountsKeyboardViewButtonTagClear) {
        editStr = [NSMutableString stringWithString:@"不打"];
    }
    
    self.currentEditText = editStr;
}

- (void)setEditText:(NSString *)editText editMode:(JCHSettleAccountsKeyboardViewEditMode)editMode
{
    self.currentEditText = editText;
    self.editMode = editMode;
}

- (void)show
{
    [JCHNotificationCenter postNotificationName:kJCHSettleAccountsKeyboardWillShowNotification
                                         object:[UIApplication sharedApplication]];
    
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    
    self.backgroundMaskView = [[[UIView alloc] initWithFrame:window.bounds] autorelease];
    self.backgroundMaskView.backgroundColor = [UIColor blackColor];
    self.backgroundMaskView.alpha = 0;
    [window addSubview:self.backgroundMaskView];
    
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)] autorelease];
    [self.backgroundMaskView addGestureRecognizer:tap];
    
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, _keyboardHeight + _topView.frame.size.height);
    [window addSubview:self];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.8
                        options:0 animations:^{

                            self.frame = CGRectMake(0, kScreenHeight - (_keyboardHeight + _topView.frame.size.height), kScreenWidth, _keyboardHeight + _topView.frame.size.height);
                            self.backgroundMaskView.alpha = 0.5;
                        }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(keyboardViewDidShow:)]) {
                             [self.delegate keyboardViewDidShow:self];
                         }
                     }];
}

- (void)hide
{
    [JCHNotificationCenter postNotificationName:kJCHSettleAccountsKeyboardDidHideNotification
                                         object:[UIApplication sharedApplication]];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, _keyboardHeight + _topView.frame.size.height);
        self.backgroundMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundMaskView removeFromSuperview];
        self.backgroundMaskView = nil;
        
        [self removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(keyboardViewDidHide:)]) {
            [self.delegate keyboardViewDidHide:self];
        }
    }];
}



@end
