//
//  JCHManifestTotalDiscountKeyboardView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHManifestTotalDiscountKeyboardView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIDebugger.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "Masonry.h"

@interface JCHManifestTotalDiscountKeyboardView ()
{
    UILabel *titleLabel;
}
@end

@implementation JCHManifestTotalDiscountKeyboardView


- (void)createUI
{
    [super createUI];
//    
//    NSInteger buttonCount = 1;
//    
//    const CGFloat topTitleHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:52.0f];
//    arrowImageView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"numTab_active_sanJiao"]] autorelease];
//    arrowImageView1.frame = CGRectMake(kScreenWidth / (buttonCount * 2 ) - 5, kScreenHeight - keyboardHeight + topTitleHeight - 1 - 64, 10, 6);
//    [self addSubview:arrowImageView1];
//    
//    arrowImageView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"numTab_active_sanJiao"]] autorelease];
//    arrowImageView2.frame = CGRectMake(kScreenWidth / (buttonCount * 2 ) * 3 - 5, kScreenHeight - keyboardHeight + topTitleHeight - 1 - 64, 10, 6);
//    [self addSubview:arrowImageView2];
//    
//    arrowImageView3 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"numTab_active_sanJiao"]] autorelease];
//    arrowImageView3.frame = CGRectMake(kScreenWidth / (buttonCount * 2 ) * 5 - 5, kScreenHeight - keyboardHeight + topTitleHeight - 1 - 64, 10, 6);
//    [self addSubview:arrowImageView3];
//    
//    arrowImageView2.hidden = YES;
//    arrowImageView3.hidden = YES;
    
    discountButton.enabled = NO;
    discountButton.titleLabel.font = [UIFont jchSystemFontOfSize:25];
    discountButton.backgroundColor = UIColorFromRGB(0xfdf9f6);
    [discountButton setBackgroundImage:nil forState:UIControlStateNormal];
    [discountButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    countButton.hidden = YES;
    priceButton.hidden = YES;
    
    UIFont *titleFont = [UIFont jchSystemFontOfSize:22.0f];
    titleLabel = [JCHUIFactory createLabel:CGRectZero title:@"整单折扣" font:titleFont textColor:JCHColorAuxiliary aligin:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topTitleHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:52.0f];
    const CGFloat closeButtonWidth = topTitleHeight;
    const CGFloat closeButtonHeight = closeButtonWidth;
    
    const CGFloat keyboardButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:70.0f];
    const CGFloat keyboardButtonWidth = self.frame.size.width / 4;
    CGFloat categoryButtonHeight = keyboardButtonHeight;
    


    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.height - keyboardHeight + topTitleHeight);
    }];
    
    [keyboardContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(keyboardHeight - topTitleHeight);
    }];
    
    [topTitleLabel removeFromSuperview];
    [countButton removeFromSuperview];
    [priceButton removeFromSuperview];
    
    [discountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(keyboardContentView.mas_top);
        make.height.mas_equalTo(categoryButtonHeight);
    }];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(discountButton.mas_left);
        make.width.mas_equalTo(self.frame.size.width / 3);
        make.top.equalTo(discountButton.mas_top);
        make.bottom.equalTo(discountButton.mas_bottom);
    }];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(discountButton.mas_centerY);
        make.width.mas_equalTo(closeButtonWidth);
        make.height.mas_equalTo(closeButtonHeight);
    }];
    

    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(discountButton.mas_bottom);
    }];
    
    [eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(sevenButton.mas_right);
        make.top.equalTo(sevenButton.mas_top);
    }];
    
    [nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(eightButton.mas_right);
        make.top.equalTo(sevenButton.mas_top);
    }];
    
    [fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(sevenButton.mas_bottom);
    }];
    
    [fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(fourButton.mas_right);
        make.top.equalTo(fourButton.mas_top);
    }];
    
    [sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(fiveButton.mas_right);
        make.top.equalTo(fourButton.mas_top);
    }];
    
    [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(fourButton.mas_bottom);
    }];
    
    [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(oneButton.mas_right);
        make.top.equalTo(oneButton.mas_top);
    }];
    
    [threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(twoButton.mas_right);
        make.top.equalTo(oneButton.mas_top);
    }];
    
    [zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth * 2);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(threeButton.mas_bottom);
    }];
    
    [dotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(zeroButton.mas_right);
        make.top.equalTo(threeButton.mas_bottom);
    }];
    
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(discountButton.mas_bottom);
    }];
    
    [backspaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(clearButton.mas_bottom);
    }];
    
    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight * 2);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(backspaceButton.mas_bottom);
    }];
    
    //! @todo
    const CGFloat seperatorLineWidth = kSeparateLineWidth;
    CGFloat topOffset = keyboardButtonHeight;
    for (int i = 0; i < kVerticalSeperatorLineCount - 1; ++i) {
        UIView *lineView = [self viewWithTag:kVerticalSeperatorLineViewTagBase + i];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            const NSInteger lineIndex = kVerticalSeperatorLineCount - 2;
            make.right.equalTo(self.mas_right).with.offset(( lineIndex != i) ? 0 : -keyboardButtonWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.top.equalTo(keyboardContentView.mas_top).with.offset(topOffset);
        }];
        
        topOffset += keyboardButtonHeight;
    }
    
    for (int i = 0; i < 3; ++i) {
        UIView *lineView = [self viewWithTag:kHorizonSeperatorLineViewTagBase + i];
        
        CGFloat topOffset = 0.0f;
        CGFloat lineHeight = 0.0f;
        CGFloat leftOffset = 0.0f;
        
        if (0 == i) {
            topOffset = categoryButtonHeight;
            leftOffset = keyboardButtonWidth;
            lineHeight = keyboardButtonHeight * 3;
        } else if (1 == i) {
            topOffset = categoryButtonHeight;
            leftOffset = keyboardButtonWidth * 2;
            lineHeight = keyboardButtonHeight * 4;
        } else if (2 == i) {
            topOffset = categoryButtonHeight;
            leftOffset = keyboardButtonWidth * 3;
            lineHeight = keyboardButtonHeight * 4;
        }
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(leftOffset);
            make.top.equalTo(keyboardContentView.mas_top).with.offset(topOffset);
            make.height.mas_equalTo(lineHeight);
            make.width.mas_equalTo(seperatorLineWidth);
        }];
    }
    
   
    currentSelectedButton = discountButton;
    
  
    [self handleKeyboardKeyEvent:discountButton];
    [self setButtonTitle:currentSelectedButton topTitle:@"折扣" bottomValue:self.productDiscountString];
    
   
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(100);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    return;
}

- (void)setViewData:(JCHManifestKeyboardViewData *)viewData
{
    [super setViewData:viewData];
    
    topTitleLabel.text = @"整单折扣";
}

- (void)showButtonHighlighted:(enum kJCHManifestKeyboardViewTag)buttonTag
{
    if (buttonTag != kJCHManifestKeyboardViewDiscountButton) {
        return;
    }
    
    UIColor *highlightBackgroundColor = JCHColorPriceText;
    UIColor *normalBackgroundColor = [UIColor clearColor];
    
    UIColor *highlightTitleColor = [UIColor whiteColor];
    
    UIButton *targetButton = (UIButton *)[self viewWithTag:buttonTag];
    [targetButton setBackgroundColor:highlightBackgroundColor];
    [targetButton setTitleColor:highlightTitleColor
                       forState:UIControlStateNormal];
    
    if (buttonTag != kJCHManifestKeyboardViewDiscountButton) {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewDiscountButton];
        [theButton setBackgroundColor:normalBackgroundColor];
        [self setButtonTitle:discountButton topTitle:@"折扣" bottomValue:self.productDiscountString];
        theButton.selected = NO;
    } else {
        UIButton *theButton = (UIButton *)[self viewWithTag:kJCHManifestKeyboardViewDiscountButton];
        [self setButtonTitle:discountButton topTitle:@"折扣" bottomValue:self.productDiscountString];

        [theButton setBackgroundColor:[UIColor clearColor]];
        [theButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
        theButton.selected = NO;
       
    }
    
    return;
}

- (void)setButtonTitle:(UIButton *)theButton topTitle:(NSString *)topTitle bottomValue:(NSString *)bottomValue
{
    NSString *buttonTitle = [NSString stringWithFormat:@"%@折",  bottomValue];
    [theButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    if (kCurrentSystemVersion < 8.0)
    {
        [theButton setNeedsLayout];
    }
    
    return;
}

- (void)selectDiscountButton
{
    [self showButtonHighlighted:kJCHManifestKeyboardViewDiscountButton];
}

- (NSString *)getDiscountString
{
    NSString *discountString = self.productDiscountString;
    if ([self.productDiscountString isEqualToString:@"不打"])
    {
        discountString = @"1.00";
    }
    else if (discountString.length == 1) {
        discountString = [NSString stringWithFormat:@"%.2f", discountString.doubleValue / 10];
    }
    else
    {
        discountString = [NSString stringWithFormat:@"%.2f", discountString.doubleValue / 100];
    }
    return discountString;
}


@end
