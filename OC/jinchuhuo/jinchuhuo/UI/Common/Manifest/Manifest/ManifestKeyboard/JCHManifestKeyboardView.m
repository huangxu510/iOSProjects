//
//  JCHManifestKeyboardView.m
//  jinchuhuo
//
//  Created by apple on 15/8/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestKeyboardView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIDebugger.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "Masonry.h"

@implementation JCHManifestKeyboardViewData

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.productCategory release];
    [self.productName release];
    
    [super dealloc];
    return;
}

@end

@interface JCHManifestKeyboardView ()
@end

@implementation JCHManifestKeyboardView

- (id)initWithKeyboardHeight:(CGFloat)height unit:(NSString *)unit unitDigits:(NSInteger)digits
{
    _unit = unit;
    _digits = digits;
    keyboardHeight = height;
    
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isFirstTimeToEditCount = YES;
        isFirstTimeToEditDiscount = YES;
        isFirstTimeToEditPrice = YES;
        isFirstShowKeyboard = YES;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [self.productNameString release];
    [self.productCategoryString release];
    [self.productCountString release];
    [self.productDiscountString release];
    [self.productPriceString release];
    
    [super dealloc];
    return;
}

- (void)createUI
{
    UIFont *buttonFont = [UIFont jchSystemFontOfSize:28.0f];
    UIColor *buttonTitleColor = JCHColorAuxiliary;
    
    UIFont *labelFont = [UIFont jchSystemFontOfSize:19.0f];
    UIColor *labelTitleColor = JCHColorMainBody;

    
    UIColor *whiteColor = [UIColor whiteColor];
    
    maskView = [[[UIView alloc] init] autorelease];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.4;
    [self addSubview:maskView];
    
    
    keyboardContentView = [[[UIView alloc] init] autorelease];
    keyboardContentView.backgroundColor = UIColorFromRGB(0xfdf9f6);
    [self addSubview:keyboardContentView];
    
    topTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"键盘"
                                         font:labelFont
                                    textColor:labelTitleColor
                                       aligin:NSTextAlignmentCenter];
    topTitleLabel.clipsToBounds = YES;
    [self addSubview:topTitleLabel];
    
    
    closeButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:nil
                                  titleColor:nil
                             backgroundColor:nil];
    [closeButton setImage:[UIImage imageNamed:@"bt_close"] forState:0];
    [closeButton setImage:[UIImage imageNamed:@"bt_close_click"] forState:UIControlStateHighlighted];
    closeButton.tag = kJCHManifestKeyboardViewCloseButton;
    [self addSubview:closeButton];

    
    countButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:nil
                                  titleColor:JCHColorMainBody
                             backgroundColor:nil];
    countButton.titleLabel.numberOfLines = 2;
    countButton.tag = kJCHManifestKeyboardViewCountButton;
    [countButton setBackgroundImage:[UIImage imageNamed:@"numTab_bg"] forState:0];
    [countButton setBackgroundImage:[UIImage imageNamed:@"numTab_bg_active"] forState:UIControlStateSelected];
    countButton.adjustsImageWhenHighlighted = NO;
    countButton.clipsToBounds = YES;
    [self addSubview:countButton];
    
    
    priceButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:nil
                                  titleColor:JCHColorMainBody
                             backgroundColor:nil];
    priceButton.titleLabel.numberOfLines = 2;
    priceButton.tag = kJCHManifestKeyboardViewPriceButton;
    [priceButton setBackgroundImage:[UIImage imageNamed:@"numTab_bg"] forState:0];
    [priceButton setBackgroundImage:[UIImage imageNamed:@"numTab_bg_active"] forState:UIControlStateSelected];
    priceButton.adjustsImageWhenHighlighted = NO;
    priceButton.clipsToBounds = YES;
    [self addSubview:priceButton];
    
    discountButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(handleKeyboardKeyEvent:)
                                          title:nil
                                     titleColor:JCHColorMainBody
                                backgroundColor:nil];
    discountButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    discountButton.titleLabel.numberOfLines = 2;
    discountButton.tag = kJCHManifestKeyboardViewDiscountButton;
    discountButton.adjustsImageWhenHighlighted = NO;
    discountButton.clipsToBounds = YES;
    [self addSubview:discountButton];
    
    zeroButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"0"
                                 titleColor:buttonTitleColor
                            backgroundColor:nil];
    zeroButton.titleLabel.font = buttonFont;
    [zeroButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [zeroButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    zeroButton.tag = kJCHManifestKeyboardViewZeroButton;
    [self addSubview:zeroButton];
    
    oneButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"1"
                                titleColor:buttonTitleColor
                           backgroundColor:whiteColor];
    oneButton.titleLabel.font = buttonFont;
    oneButton.tag = kJCHManifestKeyboardViewOneButton;
    [oneButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [oneButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:oneButton];
    
    twoButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"2"
                                titleColor:buttonTitleColor
                           backgroundColor:whiteColor];
    twoButton.titleLabel.font = buttonFont;
    twoButton.tag = kJCHManifestKeyboardViewTwoButton;
    [twoButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [twoButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:twoButton];
    
    threeButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"3"
                                  titleColor:buttonTitleColor
                             backgroundColor:whiteColor];
    threeButton.titleLabel.font = buttonFont;
    threeButton.tag = kJCHManifestKeyboardViewThreeButton;
    [threeButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [threeButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:threeButton];
    
    fourButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"4"
                                 titleColor:buttonTitleColor
                            backgroundColor:whiteColor];
    fourButton.titleLabel.font = buttonFont;
    fourButton.tag = kJCHManifestKeyboardViewFourButton;
    [fourButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [fourButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:fourButton];
    
    fiveButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"5"
                                 titleColor:buttonTitleColor
                            backgroundColor:whiteColor];
    fiveButton.titleLabel.font = buttonFont;
    fiveButton.tag = kJCHManifestKeyboardViewFiveButton;
    [fiveButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [fiveButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:fiveButton];
    
    sixButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"6"
                                titleColor:buttonTitleColor
                           backgroundColor:whiteColor];
    sixButton.titleLabel.font = buttonFont;
    sixButton.tag = kJCHManifestKeyboardViewSixButton;
    [sixButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [sixButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:sixButton];
    
    sevenButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"7"
                                  titleColor:buttonTitleColor
                             backgroundColor:whiteColor];
    sevenButton.titleLabel.font = buttonFont;
    sevenButton.tag = kJCHManifestKeyboardViewSevenButton;
    [sevenButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [sevenButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:sevenButton];
    
    eightButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"8"
                                  titleColor:buttonTitleColor
                             backgroundColor:whiteColor];
    eightButton.tag = kJCHManifestKeyboardViewEightButton;
    eightButton.titleLabel.font = buttonFont;
    [eightButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [eightButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:eightButton];
    
    nineButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"9"
                                 titleColor:buttonTitleColor
                            backgroundColor:whiteColor];
    nineButton.titleLabel.font = buttonFont;
    nineButton.tag = kJCHManifestKeyboardViewNineButton;
    [nineButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [nineButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:nineButton];
    
    dotButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"."
                                titleColor:buttonTitleColor
                           backgroundColor:whiteColor];
    dotButton.titleLabel.font = buttonFont;
    dotButton.tag = kJCHManifestKeyboardViewDotButton;
    [dotButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_left"] forState:0];
    [dotButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:dotButton];
    
    backspaceButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(handleKeyboardKeyEvent:)
                                           title:nil
                                      titleColor:buttonTitleColor
                                 backgroundColor:nil];
    backspaceButton.titleLabel.font = buttonFont;
    backspaceButton.tag = kJCHManifestKeyboardViewBackspaceButton;
    [backspaceButton setImage:[UIImage imageNamed:@"bt_del"] forState:0];
    [backspaceButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_right"] forState:0];
    [backspaceButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:backspaceButton];
    
    clearButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"清零"
                                  titleColor:buttonTitleColor
                             backgroundColor:nil];
    clearButton.titleLabel.font = labelFont;
    clearButton.tag = kJCHManifestKeyboardViewClearButton;
    [clearButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_right"] forState:0];
    [clearButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_click"] forState:UIControlStateHighlighted];
    [self addSubview:clearButton];
    
    okButton = [JCHUIFactory createButton:CGRectZero
                                   target:self
                                   action:@selector(handleKeyboardKeyEvent:)
                                    title:@"确定"
                               titleColor:whiteColor
                          backgroundColor:JCHColorPriceText];
    okButton.titleLabel.font = buttonFont;
    okButton.tag = kJCHManifestKeyboardViewOKButton;
    [okButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_dengYu"] forState:0];
    [okButton setBackgroundImage:[UIImage imageNamed:@"num_bt_bg_dengYu_click"] forState:UIControlStateHighlighted];
    [self addSubview:okButton];
    
    bottomView = [[[UIView alloc] init] autorelease];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    for (int i = 0; i < kVerticalSeperatorLineCount; ++i) {
        UIView *lineView = [JCHUIFactory createSeperatorLine:0.0f];
        lineView.tag = kVerticalSeperatorLineViewTagBase + i;
        [self addSubview:lineView];
    }
    
    for (int i = 0; i < kHorizonSeperatorLineCount; ++i) {
        UIView *lineView = [JCHUIFactory createSeperatorLine:0.0f];
        lineView.tag = kHorizonSeperatorLineViewTagBase + i;
        [self addSubview:lineView];
    }
    
    [self bringSubviewToFront:arrowImageView1];
    [self bringSubviewToFront:arrowImageView2];
    [self bringSubviewToFront:arrowImageView3];

    
    self.productCountString = @"";
    self.productPriceString = @"";
    self.productDiscountString = @"";
    [self setButtonTitle:countButton topTitle:@"数量" bottomValue:self.productCountString];
    [self setButtonTitle:priceButton topTitle:@"价格" bottomValue:self.productPriceString];
    [self setButtonTitle:discountButton topTitle:@"折扣" bottomValue:self.productDiscountString];
    
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    
    return;
}

- (void)setViewData:(JCHManifestKeyboardViewData *)viewData
{
    self.productNameString = viewData.productName;
    self.productCategoryString = viewData.productCategory;
    if (_digits == 0) {
        self.productCountString = [NSString stringWithFormat:@"%.0f", viewData.productCount];
    }
    else
    {
        self.productCountString = [NSString stringWithFormat:@"%.2f", viewData.productCount];
    }
    if (viewData.productDiscount == 1) {
        self.productDiscountString = @"不打";
    }
    else
    {
        // 对于0.X这种折扣形式，展示为 X折
        // 对于0.XY这种折扣形式，展示为 XY折
        // 所以需要判断当前的折扣为几位小数，并进行截断
        NSString *discountString = [NSString stringWithFormat:@"%g", viewData.productDiscount];
        if (discountString.length >= 4) {
            self.productDiscountString = [NSString stringWithFormat:@"%d", (int)(viewData.productDiscount * 100)];
        } else {
            self.productDiscountString = [NSString stringWithFormat:@"%d", (int)(viewData.productDiscount * 10)];
        }
    }
    self.productPriceString = [NSString stringWithFormat:@"%.2f", viewData.productPrice];

    topTitleLabel.text = viewData.productName;

    return;
}

- (JCHManifestKeyboardViewData *)getViewData
{
    JCHManifestKeyboardViewData *viewData = [[[JCHManifestKeyboardViewData alloc] init] autorelease];
    viewData.productName = topTitleLabel.text;
    viewData.productCount = self.productCountString.doubleValue;
    viewData.productPrice = self.productPriceString.doubleValue;
    if ([self.productDiscountString isEqualToString:@"不打"])
    {
        viewData.productDiscount = 1;
    }
    else
    {
        NSString *discountString = self.productDiscountString;
        if (discountString.length == 1) {
            discountString = [NSString stringWithFormat:@"%.2f", discountString.doubleValue / 10];
        }
        else
        {
             discountString = [NSString stringWithFormat:@"%.2f", discountString.doubleValue / 100];
        }
        viewData.productDiscount = discountString.doubleValue;
    }
    viewData.productCategory = self.productCategoryString;
    
    return viewData;
}

- (void)handleKeyboardKeyEvent:(id)sender
{
    UIButton *theButton = (UIButton *)sender;
    
    NSString *appendString = @"";
    BOOL clearButtonTitle = NO;
    BOOL removeLastChar = NO;
    
    switch (theButton.tag) {
        case kJCHManifestKeyboardViewCloseButton:
        {
            // pass
        }
            break;
            
        case kJCHManifestKeyboardViewCountButton:
        {
            currentSelectedButton = countButton;
        }
            break;
            
        case kJCHManifestKeyboardViewPriceButton:
        {
            currentSelectedButton = priceButton;
        }
            break;
            
        case kJCHManifestKeyboardViewDiscountButton:
        {
            currentSelectedButton = discountButton;
        }
            break;
            
        case kJCHManifestKeyboardViewZeroButton:
        {
            appendString = @"0";
        }
            break;
            
        case kJCHManifestKeyboardViewOneButton:
        {
            appendString = @"1";
        }
            break;
            
        case kJCHManifestKeyboardViewTwoButton:
        {
            appendString = @"2";
        }
            break;
            
        case kJCHManifestKeyboardViewThreeButton:
        {
            appendString = @"3";
        }
            break;
            
        case kJCHManifestKeyboardViewFourButton:
        {
            appendString = @"4";
        }
            break;
            
        case kJCHManifestKeyboardViewFiveButton:
        {
            appendString = @"5";
        }
            break;
            
        case kJCHManifestKeyboardViewSixButton:
        {
            appendString = @"6";
        }
            break;
            
        case kJCHManifestKeyboardViewSevenButton:
        {
            appendString = @"7";
        }
            break;
            
        case kJCHManifestKeyboardViewEightButton:
        {
            appendString = @"8";
        }
            break;
            
        case kJCHManifestKeyboardViewNineButton:
        {
            appendString = @"9";
        }
            break;
            
        case kJCHManifestKeyboardViewDotButton:
        {
            appendString = @".";
        }
            break;
            
        case kJCHManifestKeyboardViewClearButton:
        {
            clearButtonTitle = YES;
        }
            break;
            
        case kJCHManifestKeyboardViewBackspaceButton:
        {
            removeLastChar = YES;
        }
            break;
            
        case kJCHManifestKeyboardViewOKButton:
        {
            // pass
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    
    //当数量为整数或者当前选择折扣时，“.”按钮失效
    dotButton.enabled = YES;
    if (((currentSelectedButton == countButton) && (_digits == 0)) || (currentSelectedButton == discountButton)) {
        dotButton.enabled = NO;
    }
    
    if (currentSelectedButton == nil) {
        return;
    }
    
    if (YES == removeLastChar) {
        if (currentSelectedButton == countButton) {
            if ([self.productCountString isEqualToString:@""]) {
                return;
            }
            if (self.productCountString.length == 1) {
                if (_digits == 0) {
                    self.productCountString = @"0";
                }
                else
                {
                    self.productCountString = @"0.00";
                }
            }
            else if ([self.productCountString isEqualToString:@"0.00"])
            {
                self.productCountString = @"0.00";
            }
            else
            {
                self.productCountString = [self.productCountString substringWithRange:NSMakeRange(0, self.productCountString.length - 1)];
            }
            
            [self setButtonTitle:currentSelectedButton topTitle:@"数量" bottomValue:self.productCountString];
        } else if (currentSelectedButton == priceButton) {
            if ([self.productPriceString isEqualToString:@""] || [self.productPriceString isEqualToString:@"0.00"]) {
                return;
            }
            if (self.productPriceString.length == 1) {
                 self.productPriceString = @"0.00";
            }
            else
            {
                self.productPriceString = [self.productPriceString substringWithRange:NSMakeRange(0, self.productPriceString.length - 1)];
            }
            [self setButtonTitle:currentSelectedButton topTitle:@"价格" bottomValue:self.productPriceString];
        } else if (currentSelectedButton == discountButton) {
            if ([self.productDiscountString isEqualToString:@"不打"]) {
                return;
            }
            if (self.productDiscountString.length == 1) {
                self.productDiscountString = @"不打";
            }
            else
            {
                self.productDiscountString = [self.productDiscountString substringWithRange:NSMakeRange(0, self.productDiscountString.length - 1)];
            }
            
            [self setButtonTitle:currentSelectedButton topTitle:@"折扣" bottomValue:self.productDiscountString];
        }
    }
    
    if (YES == clearButtonTitle) {
        if (currentSelectedButton == countButton) {
            if (_digits == 0) {
                self.productCountString = @"0";
            }
            else
            {
                self.productCountString = @"0.00";
            }
            [self setButtonTitle:currentSelectedButton topTitle:@"数量" bottomValue:self.productCountString];
        } else if (currentSelectedButton == priceButton) {
            self.productPriceString = @"0.00";
            [self setButtonTitle:currentSelectedButton topTitle:@"价格" bottomValue:@"0.00"];
        } else if (currentSelectedButton == discountButton) {
            self.productDiscountString = @"不打";
            [self setButtonTitle:currentSelectedButton topTitle:@"折扣" bottomValue:@"不打"];
        }
    }
    
    if (NO == [appendString isEqualToString:@""]) {
        if (currentSelectedButton == countButton) {
            if (isFirstTimeToEditCount) {
                self.productCountString = @"";
                isFirstTimeToEditCount = NO;
            } else if ([self.productCountString isEqualToString:@"0"] || [self.productCountString isEqualToString:@"0.00"])
            {
                if ([appendString isEqualToString:@"."] && [self.productCountString isEqualToString:@"0"]) {
                    self.productCountString = @"0";
                }
                else
                {
                    self.productCountString = @"";
                }
            }
            
            self.productCountString = [self.productCountString stringByAppendingString:appendString];
            [self setButtonTitle:currentSelectedButton topTitle:@"数量" bottomValue:self.productCountString];
        } else if (currentSelectedButton == priceButton) {
            if (isFirstTimeToEditPrice) {
                self.productPriceString = @"";
                isFirstTimeToEditPrice = NO;
            } else if ([self.productPriceString isEqualToString:@"0.00"])
            {
                self.productPriceString = @"";
            }
            
            self.productPriceString = [self.productPriceString stringByAppendingString:appendString];
            
            [self setButtonTitle:currentSelectedButton topTitle:@"价格" bottomValue:self.productPriceString];
        } else if (currentSelectedButton == discountButton) {
            if (isFirstTimeToEditDiscount) {
                self.productDiscountString = @"不打";
                isFirstTimeToEditDiscount = NO;
            }
            
            if ([self.productDiscountString isEqualToString:@"不打"]) {
                self.productDiscountString = @"";
            }
            
            if (self.productDiscountString.length < 2) {
                self.productDiscountString = [self.productDiscountString stringByAppendingString:appendString];
            }
            
            
            [self setButtonTitle:currentSelectedButton topTitle:@"折扣" bottomValue:self.productDiscountString];
        }
         zeroButton.enabled = YES;
    }

    
    [self showButtonHighlighted:(enum kJCHManifestKeyboardViewTag)theButton.tag];
    
    
    //当前点击折扣时,首数字不能输入0
    zeroButton.enabled = YES;
    if ((currentSelectedButton == discountButton) && ([self.productDiscountString isEqualToString:@"不打"])) {
        zeroButton.enabled = NO;
    }
    
    if (!isFirstShowKeyboard) {
        if ([self.delegate respondsToSelector:@selector(handleKeyboardEvent:buttonTag:)]) {
            [self.delegate handleKeyboardEvent:self buttonTag:@(theButton.tag)];
        }
    }
    isFirstShowKeyboard = NO;
    
    return;
}

- (void)showButtonHighlighted:(enum kJCHManifestKeyboardViewTag)buttonTag
{
    if ((buttonTag != kJCHManifestKeyboardViewCountButton) &&
        (buttonTag != kJCHManifestKeyboardViewDiscountButton) &&
        (buttonTag != kJCHManifestKeyboardViewPriceButton)) {
        return;
    }
    
    UIColor *highlightBackgroundColor = JCHColorPriceText;
    UIColor *normalBackgroundColor = [UIColor clearColor];
    
    UIColor *highlightTitleColor = [UIColor whiteColor];
    
    UIButton *targetButton = (UIButton *)[self viewWithTag:buttonTag];
    [targetButton setBackgroundColor:highlightBackgroundColor];
    [targetButton setTitleColor:highlightTitleColor
                    forState:UIControlStateNormal];
    
    if ((buttonTag == kJCHManifestKeyboardViewCountButton) || (buttonTag == kJCHManifestKeyboardViewDiscountButton) || (buttonTag == kJCHManifestKeyboardViewPriceButton))
    {
        arrowImageView1.hidden = YES;
        arrowImageView2.hidden = YES;
        arrowImageView3.hidden = YES;
    }
    if (buttonTag != kJCHManifestKeyboardViewPriceButton) {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewPriceButton];
        theButton.selected = NO;
        [self setButtonTitle:priceButton topTitle:@"价格" bottomValue:self.productPriceString];
        
    } else {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewPriceButton];
        [theButton setBackgroundColor:highlightBackgroundColor];
        [self setButtonTitle:priceButton topTitle:@"价格" bottomValue:self.productPriceString];
        arrowImageView2.hidden = NO;
        theButton.selected = YES;
    }
    
    if (buttonTag != kJCHManifestKeyboardViewCountButton) {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewCountButton];
        [theButton setBackgroundColor:normalBackgroundColor];
        [self setButtonTitle:countButton topTitle:@"数量" bottomValue:self.productCountString];
        theButton.selected = NO;

    } else {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewCountButton];
        [theButton setBackgroundColor:highlightBackgroundColor];
        [self setButtonTitle:countButton topTitle:@"数量" bottomValue:self.productCountString];
        arrowImageView1.hidden = NO;
        theButton.selected = YES;
    }
    
    if (buttonTag != kJCHManifestKeyboardViewDiscountButton) {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewDiscountButton];
        [theButton setBackgroundColor:normalBackgroundColor];
        [self setButtonTitle:discountButton topTitle:@"折扣" bottomValue:self.productDiscountString];
        theButton.selected = NO;
    } else {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewDiscountButton];
        [self setButtonTitle:discountButton topTitle:@"折扣" bottomValue:self.productDiscountString];
        arrowImageView3.hidden = NO;
  
        [theButton setBackgroundColor:[UIColor clearColor]];
        [theButton setTitleColor:JCHColorAuxiliary forState:UIControlStateNormal];
        theButton.selected = NO;
       
    }

    return;
}

- (void)setButtonTitle:(UIButton *)theButton topTitle:(NSString *)topTitle bottomValue:(NSString *)bottomValue
{
    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIColor *titleColor = nil;
    UIColor *valueColor = nil;
    UIFont *titleFont = [UIFont jchSystemFontOfSize:16.0f];
    UIFont *valueFont = [UIFont jchSystemFontOfSize:21.0f];

    if (currentSelectedButton != theButton) {
        titleColor = JCHColorAuxiliary;
        valueColor = JCHColorMainBody;
    } else {
        titleColor = [UIColor whiteColor];
        valueColor = [UIColor whiteColor];
    }

    NSAttributedString *topTitleAttributedString = [[NSAttributedString.alloc initWithString:topTitle
                                                                                  attributes:@{NSParagraphStyleAttributeName:paragraphStyle,
                                                                                               NSForegroundColorAttributeName:titleColor,
                                                                                               NSFontAttributeName:titleFont}] autorelease];
    
    NSAttributedString *bottomValueAttributedString = [[NSAttributedString.alloc initWithString:bottomValue
                                                                                     attributes:@{NSParagraphStyleAttributeName:paragraphStyle,
                                                                                                  NSForegroundColorAttributeName:valueColor,
                                                                                                  NSFontAttributeName: valueFont}] autorelease];
    NSMutableAttributedString *buttonTitle = [[[NSMutableAttributedString alloc] initWithAttributedString:topTitleAttributedString] autorelease];
    [buttonTitle appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
    
    [buttonTitle appendAttributedString:bottomValueAttributedString];
    
    
    if (theButton == countButton) {
        NSAttributedString *unit = [[[NSAttributedString alloc] initWithString:_unit
                                                                   attributes:@{NSParagraphStyleAttributeName:paragraphStyle,
                                                                                NSForegroundColorAttributeName:valueColor,
                                                                                NSFontAttributeName:valueFont}] autorelease];
        [buttonTitle appendAttributedString:unit];
    }
    
    if (theButton == discountButton)
    {
        NSAttributedString *discount = [[[NSAttributedString alloc] initWithString:@"折"
                                                       attributes:@{NSParagraphStyleAttributeName:paragraphStyle,
                                                                    NSForegroundColorAttributeName:valueColor,
                                                                    NSFontAttributeName:valueFont}] autorelease];
        [buttonTitle appendAttributedString:discount];
    }
    
    
    [theButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];

    
    if (kCurrentSystemVersion < 8.0) {
        [theButton setNeedsLayout];
    }
    
    
    return;
}

- (void)setMaskViewAlpha:(CGFloat)alphaValue
{
    maskView.alpha = alphaValue;
}

- (void)showMaskView:(BOOL)showMaskView
{
    maskView.hidden = !showMaskView;
}

- (void)selectDiscountButton
{
    [self showButtonHighlighted:kJCHManifestKeyboardViewDiscountButton];
}

- (NSString *)getDiscountString
{
    NSString *discountString = self.productDiscountString;
    if (discountString.length == 1) {
        discountString = [NSString stringWithFormat:@"%.2f", discountString.doubleValue / 10];
    }
    else
    {
        discountString = [NSString stringWithFormat:@"%.2f", discountString.doubleValue / 100];
    }
    return discountString;
}


@end
