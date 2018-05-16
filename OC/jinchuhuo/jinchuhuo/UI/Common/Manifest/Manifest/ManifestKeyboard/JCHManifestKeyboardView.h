//
//  JCHManifestKeyboardView.h
//  jinchuhuo
//
//  Created by apple on 15/8/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum kJCHManifestKeyboardViewTag
{
    kJCHManifestKeyboardViewCloseButton,
    kJCHManifestKeyboardViewCountButton,
    kJCHManifestKeyboardViewPriceButton,
    kJCHManifestKeyboardViewDiscountButton,
    kJCHManifestKeyboardViewZeroButton,
    kJCHManifestKeyboardViewOneButton,
    kJCHManifestKeyboardViewTwoButton,
    kJCHManifestKeyboardViewThreeButton,
    kJCHManifestKeyboardViewFourButton,
    kJCHManifestKeyboardViewFiveButton,
    kJCHManifestKeyboardViewSixButton,
    kJCHManifestKeyboardViewSevenButton,
    kJCHManifestKeyboardViewEightButton,
    kJCHManifestKeyboardViewNineButton,
    kJCHManifestKeyboardViewDotButton,
    kJCHManifestKeyboardViewClearButton,
    kJCHManifestKeyboardViewBackspaceButton,
    kJCHManifestKeyboardViewOKButton,
};

enum JCHManifestKeyKeyboardSettings
{
    kVerticalSeperatorLineCount = 5,
    kVerticalSeperatorLineViewTagBase = 10000,
    
    kHorizonSeperatorLineCount = 5,
    kHorizonSeperatorLineViewTagBase = 20000,
};


#pragma mark -
#pragma mark keyboard delegate data
@interface JCHManifestKeyboardViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *productCategory;
@property (retain, nonatomic, readwrite) NSString *productName;
@property (assign, nonatomic, readwrite) CGFloat productCount;
@property (assign, nonatomic, readwrite) CGFloat productPrice;
@property (assign, nonatomic, readwrite) CGFloat productDiscount;

@end


@class JCHManifestKeyboardView;

#pragma mark -
#pragma mark keyboard delegate
@protocol JCHManifestKeyboardViewDelegate <NSObject>

@optional
- (void)handleKeyboardEvent:(JCHManifestKeyboardView *)keyboard
                  buttonTag:(NSNumber *)buttonTag;
@end





#pragma mark -
#pragma mark keyboard
@interface JCHManifestKeyboardView : UIView
{
@protected
    UILabel *topTitleLabel;
    UIButton *closeButton;
    
    UIButton *countButton;
    UIButton *priceButton;
    UIButton *discountButton;
    UIImageView *arrowImageView1;
    UIImageView *arrowImageView2;
    UIImageView *arrowImageView3;
    
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
    
    UIView *maskView;
    UIView *keyboardContentView;
    UIView *bottomView;
    CGFloat keyboardHeight;
    
    BOOL isFirstTimeToEditCount;
    BOOL isFirstTimeToEditPrice;
    BOOL isFirstTimeToEditDiscount;
    BOOL isFirstShowKeyboard;
    
    NSString *_unit;
    NSInteger _digits;
}

@property (retain, nonatomic, readwrite) NSString *productNameString;
@property (retain, nonatomic, readwrite) NSString *productCategoryString;
@property (retain, nonatomic, readwrite) NSString *productCountString;
@property (retain, nonatomic, readwrite) NSString *productPriceString;
@property (retain, nonatomic, readwrite) NSString *productDiscountString;
@property (assign, nonatomic, readwrite) id<JCHManifestKeyboardViewDelegate> delegate;
@property (assign, nonatomic, readwrite) NSInteger rowIndex;


- (id)initWithFrame:(CGRect)frame;
- (id)initWithKeyboardHeight:(CGFloat)height unit:(NSString *)unit unitDigits:(NSInteger)digits;
- (void)setViewData:(JCHManifestKeyboardViewData *)viewData;
- (JCHManifestKeyboardViewData *)getViewData;
- (void)setMaskViewAlpha:(CGFloat)alphaValue;
- (void)showMaskView:(BOOL)showMaskView;
- (void)selectDiscountButton;
- (NSString *)getDiscountString;
- (void)createUI;
- (void)handleKeyboardKeyEvent:(id)sender;
- (void)showButtonHighlighted:(enum kJCHManifestKeyboardViewTag)buttonTag;
- (void)setButtonTitle:(UIButton *)theButton topTitle:(NSString *)topTitle bottomValue:(NSString *)bottomValue;


@end
