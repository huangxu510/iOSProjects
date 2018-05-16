//
//  JCHCreateManifestTotalDiscountEditingView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHCreateManifestTotalDiscountEditingView.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHCreateManifestTotalDiscountEditingView
{
    UIImageView *_discountArrowImageView;
    UIImageView *_amountArrowImageView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.editMode = kJCHSettleAccountsKeyboardViewEditModeDiscount;
        self.reducedAmountString = @"¥0.00";
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.discountLabel release];
    [self.reducedAmountLabel release];
    [self.closeButton release];
    [self.reducedAmountString release];
    
    [super dealloc];
}

- (void)createUI
{
    CGFloat closeButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:52.0f];
    CGFloat convertImageViewWidth = 50;
    
    CGFloat labelWidth = (kScreenWidth - closeButtonWidth - convertImageViewWidth - kStandardLeftMargin) / 2;
    UIFont *titleFont = [UIFont systemFontOfSize:13.0f];
    //UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              //title:@"整单折扣"
                                               //font:titleFont
                                          //textColor:JCHColorAuxiliary
                                             //aligin:NSTextAlignmentLeft];
    //[self addSubview:titleLabel];
    
    //[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self).with.offset(kStandardLeftMargin);
        //make.width.mas_equalTo(kScreenWidth / 3);
        //make.top.equalTo(self);
        //make.bottom.equalTo(self);
    //}];
    
    self.discountLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"不打折"
                                              font:titleFont
                                         textColor:JCHColorHeaderBackground
                                            aligin:NSTextAlignmentCenter];
    self.discountLabel.tag = 0;
    self.discountLabel.userInteractionEnabled = YES;
    [self addSubview:self.discountLabel];
    
    [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(labelWidth);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectLabel:)] autorelease];
    [self.discountLabel addGestureRecognizer:tap];
    
    UIImageView *convertImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_discountconvert"]] autorelease];
    convertImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:convertImageView];
    
    [convertImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.discountLabel.mas_right);
        make.width.mas_equalTo(convertImageViewWidth);
        make.top.bottom.equalTo(self);
    }];
    
    self.reducedAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"¥0.00"
                                            font:titleFont
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentCenter];
    self.reducedAmountLabel.tag = 1;
    self.reducedAmountLabel.userInteractionEnabled = YES;
    [self addSubview:self.reducedAmountLabel];
    
    [self.reducedAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(convertImageView.mas_right);
        make.width.mas_equalTo(labelWidth);
        make.top.bottom.equalTo(self);
    }];
    
    tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectLabel:)] autorelease];
    [self.reducedAmountLabel addGestureRecognizer:tap];
    
    self.closeButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:nil
                                                 title:nil
                                            titleColor:nil
                                       backgroundColor:nil];
    [self.closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose"] forState:UIControlStateNormal];
    [self addSubview:self.closeButton];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:52.0f]);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    CGFloat arrowImageViewHeight = 7;
    _discountArrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_focus"]] autorelease];
    _discountArrowImageView.hidden = NO;
    _discountArrowImageView.contentMode = UIViewContentModeCenter;
    [self.discountLabel addSubview:_discountArrowImageView];
    
    [_discountArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.discountLabel);
        make.height.mas_equalTo(arrowImageViewHeight);
    }];
    
    _amountArrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_focus"]] autorelease];
    _amountArrowImageView.hidden = YES;
    _amountArrowImageView.contentMode = UIViewContentModeCenter;
    [self.discountLabel addSubview:_amountArrowImageView];
    
    [_amountArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.reducedAmountLabel);
        make.height.mas_equalTo(arrowImageViewHeight);
    }];
}

- (void)handleSelectLabel:(UITapGestureRecognizer *)tap
{
    if (tap.view.tag == 0) {
        _discountArrowImageView.hidden = NO;
        self.discountLabel.textColor = JCHColorHeaderBackground;
        _amountArrowImageView.hidden = YES;
        self.reducedAmountLabel.textColor = JCHColorMainBody;
        self.editMode = kJCHSettleAccountsKeyboardViewEditModeDiscount;
    } else {
        _discountArrowImageView.hidden = YES;
        self.discountLabel.textColor = JCHColorMainBody;
        _amountArrowImageView.hidden = NO;
        self.reducedAmountLabel.textColor = JCHColorHeaderBackground;
        self.editMode = kJCHSettleAccountsKeyboardViewEditModePrice;
    }
    
    if ([self.delegate respondsToSelector:@selector(createManifestTotalDiscountEditingViewTaped:)]) {
        [self.delegate createManifestTotalDiscountEditingViewTaped:self];
    }
}

- (void)setDiscount:(CGFloat)discount
{
    _discount = discount;
    NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:discount];
    _discountLabel.text = discountStr;
    
    CGFloat reducedAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:self.totalAmount - self.totalAmount * discount];
    self.reduceAmount = reducedAmount;
    _reducedAmountString = [[NSString stringWithFormat:@"¥%.2f", reducedAmount] retain];
    _reducedAmountLabel.text = _reducedAmountString;
}

- (void)setReducedAmountString:(NSString *)reducedAmountString
{
    if (_reducedAmountString != reducedAmountString) {
        [_reducedAmountString release];
        _reducedAmountString = [reducedAmountString retain];
        
        self.reducedAmountLabel.text = _reducedAmountString;
        
        CGFloat reductAmount = [[reducedAmountString stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
        self.reduceAmount = reductAmount;
        CGFloat discount = 1.0;
        
        if (self.totalAmount != 0) {
            //折扣向上取整，不够用抹零补齐
            discount = (self.totalAmount - reductAmount) / self.totalAmount;
            if ([JCHFinanceCalculateUtility floatValueIsZero:floor(discount * 100) / 100 - discount]) {
                
            } else {
                discount = ceil((self.totalAmount - reductAmount) / self.totalAmount * 100) / 100;
            }
        }
        _discount = [JCHFinanceCalculateUtility roundDownFloatNumber:discount];
        NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:_discount];
        _discountLabel.text = discountStr;
    }
}


@end
