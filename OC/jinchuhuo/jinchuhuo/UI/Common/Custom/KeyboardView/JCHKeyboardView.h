//
//  JCHKeyboardView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHAddProductSKUListView.h"
#import "JCHCreateManifestTotalDiscountEditingView.h"

enum kJCHKeyboardViewTag
{
    kJCHKeyboardViewZeroButton = 0,
    kJCHKeyboardViewOneButton,
    kJCHKeyboardViewTwoButton,
    kJCHKeyboardViewThreeButton,
    kJCHKeyboardViewFourButton,
    kJCHKeyboardViewFiveButton,
    kJCHKeyboardViewSixButton,
    kJCHKeyboardViewSevenButton,
    kJCHKeyboardViewEightButton,
    kJCHKeyboardViewNineButton,
    kJCHKeyboardViewDotButton,
    kJCHKeyboardViewClearButton,
    kJCHKeyboardViewBackspaceButton,
    kJCHKeyboardViewOKButton,
};

enum kJCHKeyboardEventTag
{
    kKeyboardSingleTransactionDetailTag,
    kKeyboardTransactionListTag,
};

enum JCHKeyboardSettings
{
    kKeyboardVerticalSeperatorLineCount = 3,
    kKeyboardVerticalSeperatorLineViewTagBase = 10000,
    
    kKeyboardHorizonSeperatorLineCount = 4,
    kKeyboardHorizonSeperatorLineViewTagBase = 20000,
};

@class JCHKeyboardView;

@protocol JCHKeyboardViewDelegate <NSObject>

- (void)handleKeyboardOK:(JCHKeyboardView *)keyboard editStr:(NSString *)editStr;

@end


@interface JCHKeyboardView : UIView
{
    UIButton *zeroButton;
    UIButton *oneButton;
    UIButton *twoButton;
    UIButton *threeButton;
    UIButton *fourButton;
    UIButton *fiveButton;
    UIButton *sixButton;
    UIButton *sevenButton;
    UIButton *eightButton;
    UIButton *nineButton;
    
    UIButton *dotButton;
    UIButton *backspaceButton;
    UIButton *clearButton;
    
    UIButton *okButton;
    
    UIButton *currentSelectedButton;
    UIView *bottomView;
}

@property (nonatomic, assign) id <JCHKeyboardViewDelegate> delegate;
@property (nonatomic, assign) BOOL clearCount;
@property (nonatomic, assign) BOOL clearPrice;
@property (nonatomic, retain) JCHAddProductSKUListView *skuListView;
@property (nonatomic, retain) JCHCreateManifestTotalDiscountEditingView *totalDiscountView;


@end
