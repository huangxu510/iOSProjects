//
//  JCHSettleAccountsKeyboardView.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    kJCHSettleAccountsKeyboardViewButtonTagDot = 10,
    kJCHSettleAccountsKeyboardViewButtonTagBackSpace = 11,
    kJCHSettleAccountsKeyboardViewButtonTagClear = 12,
    kJCHSettleAccountsKeyboardViewButtonTagOK = 13,
};

typedef NS_ENUM(NSInteger, JCHSettleAccountsKeyboardViewEditMode) {
    kJCHSettleAccountsKeyboardViewEditModePrice,
    kJCHSettleAccountsKeyboardViewEditModeCount,
    kJCHSettleAccountsKeyboardViewEditModeDiscount,
    kJCHSettleAccountsKeyboardViewEditModeTotalAmount,
};

@class JCHSettleAccountsKeyboardView;
@protocol JCHSettleAccountsKeyboardViewDelegate <NSObject>

@optional
- (void)keyboardViewInputNumber:(NSString *)number;
- (void)keyboardViewFunctionButtonClick:(NSInteger)buttonTag;

- (void)keyboardViewOKButtonClick;
- (NSString *)keyboardViewEditingChanged:(NSString *)editText;
- (void)keyboardViewDidHide:(JCHSettleAccountsKeyboardView *)keyboard;
- (void)keyboardViewDidShow:(JCHSettleAccountsKeyboardView *)keyboard;

@end

#ifndef kJCHSettleAccountsKeyboardWillShowNotification
#define kJCHSettleAccountsKeyboardWillShowNotification @"kJCHSettleAccountsKeyboardWillShowNotification"
#endif

#ifndef kJCHSettleAccountsKeyboardDidHideNotification
#define kJCHSettleAccountsKeyboardDidHideNotification @"kJCHSettleAccountsKeyboardDidHideNotification"
#endif


@interface JCHSettleAccountsKeyboardView : UIView

- (instancetype)initWithFrame:(CGRect)frame
               keyboardHeight:(CGFloat)keyboardHeight
                      topView:(UIView *)topView
       topContainerViewHeight:(CGFloat)topContainerViewHeight;

- (void)setEditText:(NSString *)editText
           editMode:(JCHSettleAccountsKeyboardViewEditMode)editMode;

@property (nonatomic, assign) id <JCHSettleAccountsKeyboardViewDelegate> delegate;

//当前的编辑模式
@property (nonatomic, assign) JCHSettleAccountsKeyboardViewEditMode editMode;

//允许输入的最大金额
@property (nonatomic, assign) CGFloat maxAmount;

//数量的小数点个数,默认是2
@property (nonatomic, assign) CGFloat unit_digits;

//金钱和数量首次输入要将之前的内容清空
@property (nonatomic, assign) BOOL isFirstEdit;

- (void)show;
- (void)hide;

@end
