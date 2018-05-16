//
//  JCHManifestPurchasesKeyboardView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHManifestPurchasesKeyboardView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIDebugger.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "Masonry.h"

@implementation JCHManifestPurchasesKeyboardView

- (void)createUI
{
    [super createUI];
    
    NSInteger buttonCount = 2;
    
    const CGFloat topTitleHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:52.0f];
    arrowImageView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"numTab_active_sanJiao"]] autorelease];
    arrowImageView1.frame = CGRectMake(kScreenWidth / (buttonCount * 2 ) - 5, kScreenHeight - keyboardHeight + topTitleHeight - 1 - 64, 10, 6);
    [self addSubview:arrowImageView1];
    
    arrowImageView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"numTab_active_sanJiao"]] autorelease];
    arrowImageView2.frame = CGRectMake(kScreenWidth / (buttonCount * 2 ) * 3 - 5, kScreenHeight - keyboardHeight + topTitleHeight - 1 - 64, 10, 6);
    [self addSubview:arrowImageView2];
    
    arrowImageView2.hidden = YES;
    
    [discountButton setBackgroundImage:[UIImage imageNamed:@"numTab_bg"] forState:0];
    [discountButton setBackgroundImage:[UIImage imageNamed:@"numTab_bg_active"] forState:UIControlStateSelected];
    
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topTitleHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:52.0f];
    const CGFloat closeButtonWidth = topTitleHeight;
    const CGFloat closeButtonHeight = closeButtonWidth;
    const CGFloat topTitleWidth = self.frame.size.width;
    
    const CGFloat keyboardButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:70.0f];
    const CGFloat keyboardButtonWidth = self.frame.size.width / 4;
    CGFloat categoryButtonHeight = keyboardButtonHeight;
    
    CGFloat categoryButtonWidth = self.frame.size.width / 2;
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.height - keyboardHeight);
    }];
    
    [keyboardContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(keyboardHeight);
    }];
    
    [topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(keyboardContentView.mas_top);
        make.width.mas_equalTo(topTitleWidth);
        make.height.mas_equalTo(topTitleHeight);
    }];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.top.equalTo(keyboardContentView.mas_top);
        make.width.mas_equalTo(closeButtonWidth);
        make.height.mas_equalTo(closeButtonHeight);
    }];
    
    
    [countButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topTitleLabel.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.width.mas_equalTo(categoryButtonWidth);
        make.height.mas_equalTo(categoryButtonHeight);
    }];
    
    
    [priceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topTitleLabel.mas_bottom);
        make.left.equalTo(countButton.mas_right);
        make.width.mas_equalTo(categoryButtonWidth);
        make.height.mas_equalTo(categoryButtonHeight);
    }];
    
    [discountButton removeFromSuperview];
    
    
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(countButton.mas_bottom);
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
        make.top.equalTo(countButton.mas_bottom);
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
    CGFloat topOffset = topTitleHeight;
    for (int i = 0; i < kVerticalSeperatorLineCount; ++i) {
        UIView *lineView = [self viewWithTag:kVerticalSeperatorLineViewTagBase + i];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            const NSInteger lineIndex = kVerticalSeperatorLineCount - 1;
            make.right.equalTo(self.mas_right).with.offset(( lineIndex != i) ? 0 : -keyboardButtonWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.top.equalTo(keyboardContentView.mas_top).with.offset(topOffset);
        }];
        
        topOffset += keyboardButtonHeight;
    }
    
    for (int i = 0; i < kHorizonSeperatorLineCount; ++i) {
        UIView *lineView = [self viewWithTag:kHorizonSeperatorLineViewTagBase + i];
        
        CGFloat topOffset = 0.0f;
        CGFloat lineHeight = 0.0f;
        CGFloat leftOffset = 0.0f;
        
        if (0 == i) {
            topOffset = topTitleHeight;
            leftOffset = categoryButtonWidth;
            lineHeight = keyboardButtonHeight;
        } else if (1 == i) {
            topOffset = topTitleHeight;
            leftOffset = categoryButtonWidth * 2;
            lineHeight = keyboardButtonHeight;
        } else if (2 == i) {
            topOffset = topTitleHeight + categoryButtonHeight;
            leftOffset = keyboardButtonWidth;
            lineHeight = keyboardButtonHeight * 3;
        } else if (3 == i) {
            topOffset = topTitleHeight + categoryButtonHeight;
            leftOffset = keyboardButtonWidth * 2;
            lineHeight = keyboardButtonHeight * 4;
        } else if (4 == i) {
            topOffset = topTitleHeight + categoryButtonHeight;
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
    

    //默认数量按钮被选中
    currentSelectedButton = countButton;
    countButton.selected = YES;

    [self handleKeyboardKeyEvent:countButton];
    [self setButtonTitle:currentSelectedButton topTitle:@"数量" bottomValue:self.productCountString];

    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(okButton.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(100);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    return;
}

- (JCHManifestKeyboardViewData *)getViewData
{
    JCHManifestKeyboardViewData *viewData = [[[JCHManifestKeyboardViewData alloc] init] autorelease];
    viewData.productName = topTitleLabel.text;
    viewData.productCount = self.productCountString.doubleValue;
    viewData.productPrice = self.productPriceString.doubleValue;
    viewData.productCategory = self.productCategoryString;
    viewData.productDiscount = 1.0f;
    
    return viewData;
}

- (void)showButtonHighlighted:(enum kJCHManifestKeyboardViewTag)buttonTag
{
    if ((buttonTag != kJCHManifestKeyboardViewCountButton) &&
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
    
    if ((buttonTag == kJCHManifestKeyboardViewCountButton) || (buttonTag == kJCHManifestKeyboardViewPriceButton))
    {
        arrowImageView1.hidden = YES;
        arrowImageView2.hidden = YES;
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
    
    [theButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];

    
    if (kCurrentSystemVersion < 8.0) {
        [theButton setNeedsLayout];
    }
    
    
    return;
}



@end
