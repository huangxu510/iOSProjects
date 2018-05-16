//
//  JCHStepperView.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHStepperView.h"
#import "JCHUISizeSettings.h"
#import "JCHInputAccessoryView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "Masonry.h"


@interface JCHStepperView ()
{
    UIButton *decreaseButton;
    UIButton *increaseButton;
    UITextField *stepperValueTextfield;
    enum JCHOrderType enumCurrentManifestType;
}
@end

@implementation JCHStepperView



- (id)initWithFrame:(CGRect)frame manifestType:(enum JCHOrderType)manifestType
{
    self = [super initWithFrame:frame];
    if (self) {
        enumCurrentManifestType = manifestType;
        [self createUI];
        stepperValueTextfield.enabled = NO;
        stepperValueTextfield.userInteractionEnabled = NO;
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
    if (enumCurrentManifestType == kJCHOrderShipment)
    {
        decreaseButton = [JCHUIFactory createButton:CGRectZero target:self
                                             action:@selector(handleStepperDecrease:)
                                              title:@""
                                         titleColor:nil
                                    backgroundColor:nil];
        [decreaseButton setBackgroundImage:[UIImage imageNamed:@"bt_jian"] forState:0];
        [decreaseButton setBackgroundImage:[UIImage imageNamed:@"bt_jian_click"] forState:UIControlStateHighlighted];
        [self addSubview:decreaseButton];
    }
    
    increaseButton = [JCHUIFactory createButton:CGRectZero target:self
                                         action:@selector(handleStepperIncrease:)
                                          title:@""
                                     titleColor:nil
                                backgroundColor:nil];
    [increaseButton setBackgroundImage:[UIImage imageNamed:@"bt_jia"] forState:0];
    [increaseButton setBackgroundImage:[UIImage imageNamed:@"bt_jia_click"] forState:UIControlStateHighlighted];
    [self addSubview:increaseButton];
    
    if (enumCurrentManifestType == kJCHOrderShipment)
    {
        stepperValueTextfield = [JCHUIFactory createTextField:CGRectZero
                                                  placeHolder:@"00"
                                                    textColor:JCHColorPriceText
                                                       aligin:NSTextAlignmentCenter];
        stepperValueTextfield.font = [UIFont jchSystemFontOfSize:16.0f];
        [self addSubview:stepperValueTextfield];
        stepperValueTextfield.delegate = self;
        stepperValueTextfield.keyboardType = UIKeyboardTypeNumberPad;
        [stepperValueTextfield addTarget:self
                                  action:@selector(handleTextfieldValueChanged:)
                        forControlEvents:UIControlEventValueChanged];
        
        stepperValueTextfield.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    stepperValueTextfield.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:CGRectZero] autorelease];
    
    CGFloat stepperValueWidth = 0;
    if (enumCurrentManifestType == kJCHOrderShipment)
    {
       stepperValueWidth = self.frame.size.width - 2 * self.frame.size.height;
        [decreaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.width.equalTo(self.mas_height);
        }];
    }
    else
    {
        stepperValueWidth = self.frame.size.width - self.frame.size.height;
    }
    [increaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.width.equalTo(self.mas_height);
    }];
    
    [stepperValueTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.height.equalTo(self.mas_height);
        make.right.equalTo(increaseButton.mas_left);
        make.width.mas_equalTo(stepperValueWidth);
    }];
    
    CGRect accessoryFrame = CGRectMake(0, 0, self.frame.size.width, [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    stepperValueTextfield.inputAccessoryView.frame = accessoryFrame;
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    
    return;
}

- (void)setStepperValue:(CGFloat)stepperValue
{
    if (YES == self.showStepperValueAsInteger) {
        stepperValueTextfield.text = [NSString stringWithFormat:@"%d", (int)stepperValue];
    } else {
        stepperValueTextfield.text = [NSString stringWithFormat:@"%.2f", stepperValue];
    }
    
    return;
}

- (CGFloat)stepperValue
{
    return stepperValueTextfield.text.doubleValue;
}

- (void)handleStepperIncrease:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleStepperValueIncrease:)]) {
        [self.delegate performSelector:@selector(handleStepperValueIncrease:) withObject:self];
    }
    
    return;
}

- (void)handleStepperDecrease:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleStepperValueDecrease:)]) {
        [self.delegate performSelector:@selector(handleStepperValueDecrease:) withObject:self];
    }
    
    return;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(handleStepperValueEndEditing:)]) {
        [self.delegate performSelector:@selector(handleStepperValueEndEditing:) withObject:self];
    }
    
    return;
}

- (void)handleTextfieldValueChanged:(UITextField *)textfield
{
    if ([self.delegate respondsToSelector:@selector(handleStepperValueEditChanged:)]) {
        [self.delegate performSelector:@selector(handleStepperValueEditChanged:) withObject:self];
    }
    
    return;
}


@end
