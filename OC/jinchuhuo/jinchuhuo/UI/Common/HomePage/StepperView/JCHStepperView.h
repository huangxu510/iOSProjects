//
//  JCHStepperView.h
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"

@class JCHStepperView;

@protocol JCHStepperViewDelegate <NSObject>

- (void)handleStepperValueIncrease:(JCHStepperView *)stepperView;
- (void)handleStepperValueDecrease:(JCHStepperView *)stepperView;
- (void)handleStepperValueEndEditing:(JCHStepperView *)stepperView;
- (void)handleStepperValueEditChanged:(JCHStepperView *)stepperView;
@end

@interface JCHStepperView : UIView<UITextFieldDelegate>

//! @brief 当前的stepper值是否为整数，YES: 整数，NO: 两位小数
@property (assign, nonatomic, readwrite) BOOL showStepperValueAsInteger;
@property (assign, nonatomic, readwrite) CGFloat stepperValue;
@property (assign, nonatomic, readwrite) id<JCHStepperViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType;
//- (void)textFieldBeginEditing:(void(^)())action;

@end
