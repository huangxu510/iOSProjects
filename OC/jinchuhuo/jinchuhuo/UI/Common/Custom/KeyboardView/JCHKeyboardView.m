//
//  JCHKeyboardView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHKeyboardView.h"
#import "JCHAddProductMainViewController.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import "JCHTransactionUtility.h"
#import "JCHManifestMemoryStorage.h"
#import "UIImage+JCHImage.h"
#import <Masonry.h>

@implementation JCHKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.totalDiscountView release];
    [self.skuListView release];
    [super dealloc];
}


- (void)createUI
{
    //f3f3f3   e7ecf1
    UIFont *numberButtonFont = [UIFont jchSystemFontOfSize:24.0f];
    UIFont *buttonFont = [UIFont jchSystemFontOfSize:21.0f];
    UIColor *buttonTitleColor = JCHColorMainBody;
    UIImage *numberButtonBackgroundImage_nomal = [UIImage imageWithColor:UIColorFromRGB(0xf3f3f3)];
    UIImage *numberButtonBackgroundImage_hightlighted = [UIImage imageWithColor:UIColorFromRGB(0xe7ecf1)];
    UIImage *okButtonBackgroundImage_nomal = [UIImage imageWithColor:JCHColorHeaderBackground];
    UIImage *okButtonBackgroundImage_highlighted = [UIImage imageWithColor:JCHColorRedButtonHeighlighted];
    
    zeroButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"0"
                                 titleColor:buttonTitleColor
                            backgroundColor:nil];
    zeroButton.titleLabel.font = buttonFont;
    [zeroButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:UIControlStateNormal];
    [zeroButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    zeroButton.tag = kJCHKeyboardViewZeroButton;
    [self addSubview:zeroButton];
    
    oneButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"1"
                                titleColor:buttonTitleColor
                           backgroundColor:nil];
    oneButton.titleLabel.font = numberButtonFont;
    oneButton.tag = kJCHKeyboardViewOneButton;
    [oneButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [oneButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:oneButton];
    
    twoButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"2"
                                titleColor:buttonTitleColor
                           backgroundColor:nil];
    twoButton.titleLabel.font = numberButtonFont;
    twoButton.tag = kJCHKeyboardViewTwoButton;
    [twoButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [twoButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:twoButton];
    
    threeButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"3"
                                  titleColor:buttonTitleColor
                             backgroundColor:nil];
    threeButton.titleLabel.font = numberButtonFont;
    threeButton.tag = kJCHKeyboardViewThreeButton;
    [threeButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [threeButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:threeButton];
    
    fourButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"4"
                                 titleColor:buttonTitleColor
                            backgroundColor:nil];
    fourButton.titleLabel.font = numberButtonFont;
    fourButton.tag = kJCHKeyboardViewFourButton;
    [fourButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [fourButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:fourButton];
    
    fiveButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"5"
                                 titleColor:buttonTitleColor
                            backgroundColor:nil];
    fiveButton.titleLabel.font = numberButtonFont;
    fiveButton.tag = kJCHKeyboardViewFiveButton;
    [fiveButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [fiveButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:fiveButton];
    
    sixButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"6"
                                titleColor:buttonTitleColor
                           backgroundColor:nil];
    sixButton.titleLabel.font = numberButtonFont;
    sixButton.tag = kJCHKeyboardViewSixButton;
    [sixButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [sixButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:sixButton];
    
    sevenButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"7"
                                  titleColor:buttonTitleColor
                             backgroundColor:nil];
    sevenButton.titleLabel.font = numberButtonFont;
    sevenButton.tag = kJCHKeyboardViewSevenButton;
    [sevenButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [sevenButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:sevenButton];
    
    eightButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"8"
                                  titleColor:buttonTitleColor
                             backgroundColor:nil];
    eightButton.tag = kJCHKeyboardViewEightButton;
    eightButton.titleLabel.font = numberButtonFont;
    [eightButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [eightButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:eightButton];
    
    nineButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleKeyboardKeyEvent:)
                                      title:@"9"
                                 titleColor:buttonTitleColor
                            backgroundColor:nil];
    nineButton.titleLabel.font = numberButtonFont;
    nineButton.tag = kJCHKeyboardViewNineButton;
    [nineButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [nineButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:nineButton];
    
    dotButton = [JCHUIFactory createButton:CGRectZero
                                    target:self
                                    action:@selector(handleKeyboardKeyEvent:)
                                     title:@"."
                                titleColor:buttonTitleColor
                           backgroundColor:nil];
    dotButton.titleLabel.font = numberButtonFont;
    dotButton.tag = kJCHKeyboardViewDotButton;
    [dotButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:0];
    [dotButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:UIControlStateHighlighted];
    [self addSubview:dotButton];
    
    backspaceButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(handleKeyboardKeyEvent:)
                                           title:nil
                                      titleColor:buttonTitleColor
                                 backgroundColor:nil];
    backspaceButton.titleLabel.font = numberButtonFont;
    backspaceButton.tag = kJCHKeyboardViewBackspaceButton;
    [backspaceButton setImage:[UIImage imageNamed:@"addgoods_keyboard_delete"] forState:0];
    [backspaceButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:0];
    [backspaceButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:UIControlStateHighlighted];
    [self addSubview:backspaceButton];
    
    clearButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleKeyboardKeyEvent:)
                                       title:@"清零"
                                  titleColor:buttonTitleColor
                             backgroundColor:nil];
    clearButton.titleLabel.font = buttonFont;
    clearButton.tag = kJCHKeyboardViewClearButton;
    [clearButton setBackgroundImage:numberButtonBackgroundImage_hightlighted forState:0];
    [clearButton setBackgroundImage:numberButtonBackgroundImage_nomal forState:UIControlStateHighlighted];
    [self addSubview:clearButton];
    
    okButton = [JCHUIFactory createButton:CGRectZero
                                   target:self
                                   action:@selector(handleKeyboardKeyEvent:)
                                    title:@"确定"
                               titleColor:[UIColor whiteColor]
                          backgroundColor:nil];
    okButton.titleLabel.font = buttonFont;
    okButton.tag = kJCHKeyboardViewOKButton;
    [okButton setBackgroundImage:okButtonBackgroundImage_nomal forState:0];
    [okButton setBackgroundImage:okButtonBackgroundImage_highlighted forState:UIControlStateHighlighted];
    [self addSubview:okButton];
    
    
    for (int i = 0; i < kKeyboardVerticalSeperatorLineCount; ++i) {
        UIView *lineView = [JCHUIFactory createSeperatorLine:0.0f];
        lineView.tag = kKeyboardVerticalSeperatorLineViewTagBase + i;
        [self addSubview:lineView];
    }
    
    for (int i = 0; i < kKeyboardHorizonSeperatorLineCount; ++i) {
        UIView *lineView = [JCHUIFactory createSeperatorLine:0.0f];
        lineView.tag = kKeyboardHorizonSeperatorLineViewTagBase + i;
        [self addSubview:lineView];
    }
    
    bottomView = [[[UIView alloc] init] autorelease];
    bottomView.backgroundColor = UIColorFromRGB(0xf3f3f3);
    [self addSubview:bottomView];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    const CGFloat keyboardButtonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:49.0f];
    const CGFloat keyboardButtonWidth = kScreenWidth / 4;
    
    
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self);
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
        make.left.equalTo(oneButton);
        make.top.equalTo(oneButton.mas_bottom);
    }];
    
    [dotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(threeButton);
        make.height.mas_equalTo(threeButton);
        make.left.equalTo(threeButton.mas_left);
        make.top.equalTo(threeButton.mas_bottom);
    }];
    
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self);
    }];
    
    [backspaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.height.mas_equalTo(keyboardButtonHeight);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(clearButton.mas_bottom);
    }];
    
    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(keyboardButtonWidth);
        make.bottom.mas_equalTo(self);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(backspaceButton.mas_bottom);
    }];
    
    
    CGFloat topOffset = 0;
    for (int i = 0; i < kKeyboardHorizonSeperatorLineCount; ++i) {
        UIView *lineView = [self viewWithTag:kKeyboardHorizonSeperatorLineViewTagBase + i];
        [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right).with.offset((i < 3) ? 0 : -keyboardButtonWidth);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.top.equalTo(self.mas_top).with.offset(topOffset);
        }];
        
        topOffset += keyboardButtonHeight;
    }
    
    for (int i = 0; i < kKeyboardVerticalSeperatorLineCount; ++i) {
        UIView *lineView = [self viewWithTag:kKeyboardVerticalSeperatorLineViewTagBase + i];
        
        CGFloat lineHeight = 0.0f;
        CGFloat leftOffset = 0.0f;
        
        if (0 == i) {
            leftOffset = keyboardButtonWidth;
            lineHeight = keyboardButtonHeight * 3;
        } else if (1 == i) {
            leftOffset = keyboardButtonWidth * 2;
            lineHeight = keyboardButtonHeight * 4;
        } else if (2 == i) {
            leftOffset = keyboardButtonWidth * 3;
            lineHeight = keyboardButtonHeight * 2;
        }
        
        [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(leftOffset);
            make.top.equalTo(self);
            make.height.mas_equalTo(lineHeight);
            make.width.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(okButton.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(100);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    return;
}

- (void)handleKeyboardKeyEvent:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    
    ManifestTransactionDetail *transactionDetail = self.skuListView.dataSource[0];
    NSInteger unit_digits = transactionDetail.productUnit_digits;
    
    for (ManifestTransactionDetail *detail in self.skuListView.dataSource) {
        
        NSArray *selectedData = nil;
        if (self.skuListView.singleEditing) {
            selectedData = @[self.skuListView.singleEditingData];
        }
        else
        {
            selectedData = self.skuListView.selectedData;
        }
        
        for (ManifestTransactionDetail *selectedDetail in selectedData) {
            if ([JCHTransactionUtility skuUUIDs:detail.skuValueUUIDs isEqualToArray:selectedDetail.skuValueUUIDs]) {
                NSMutableString *editStr = nil;
                if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellPriceLableTag) { //价格
                    editStr = [NSMutableString stringWithString:detail.productPrice];
                }
                else if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellCountLableTag) //数量
                {
                    editStr = [NSMutableString stringWithString:detail.productCount];
                }
                else if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag) { //折扣
                    NSString *discountStr = [JCHTransactionUtility getOrderDiscountFromFloat:[detail.productDiscount doubleValue]];
                    if ([discountStr isEqualToString:@"不打折"]) {
                        editStr = [NSMutableString stringWithString:@""];
                    }
                    else
                    {
                        editStr = [NSMutableString stringWithString:[discountStr substringToIndex:discountStr.length - 1]];
                    }
                }
                
                //数量或单价获取焦点后，录入时，原数值清空
                if ((self.skuListView.lastEditLabelTag != self.skuListView.currentEditLabelTag) && (tag != kJCHKeyboardViewOKButton)) {
                    editStr = [NSMutableString stringWithFormat:@""];
                }
                
                //价格或数量
                if ((self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellCountLableTag) ||
                    (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellPriceLableTag)) {
                    if ((tag >= 0) && (tag <= 9)) {
                        if (([editStr doubleValue] == 0) && (![editStr isEqualToString:@"0."]) && (![editStr isEqualToString:@"0.0"])) {
                            editStr = [NSMutableString stringWithFormat:@"%ld", (long)tag];
                        }
                        else{
                            if ([editStr containsString:@"."]) {
                                NSRange range = [editStr rangeOfString:@"."];
                                
                                //数量小数点位数不超过单位设置的小数点位数，单价小数点位数不超过两位
                                if (((editStr.length - range.location) <= unit_digits && self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellCountLableTag) ||
                                    ((editStr.length - range.location) <= 2 && (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellPriceLableTag))) {
                                    [editStr appendString:[NSString stringWithFormat:@"%ld", (long)tag]];
                                }
                            }
                            else
                            {
                                [editStr appendString:[NSString stringWithFormat:@"%ld", (long)tag]];
                            }
                            
                        }
                    }
                    else if (tag == kJCHKeyboardViewDotButton)
                    {
                        if (![editStr containsString:@"."]) {
                            if ((self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellPriceLableTag) ||
                                ((self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellCountLableTag) && (detail.productUnit_digits > 0))) {
                                [editStr appendString:@"."];
                            }
                        }
                    }
                    else if (tag == kJCHKeyboardViewClearButton)
                    {
                        editStr = [NSMutableString stringWithString:@"0"];
                    }
                    else if (tag == kJCHKeyboardViewBackspaceButton)
                    {
                        if (editStr.length > 0) {
                            editStr = [NSMutableString stringWithString:[editStr substringToIndex:editStr.length - 1]];
                        }
                        
                        if ([editStr isEqualToString:@""]) {
                            editStr = [NSMutableString stringWithString:@"0"];
                        }
                    }
                    else{
                        //pass
                    }
                    
                    if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellPriceLableTag) {
                        detail.productPrice = editStr;
                    }
                    else if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellCountLableTag)
                    {
                        detail.productCount = editStr;
                    }
                    else{
                        //pass
                    }
                }
                else if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag)
                {
                    if ((tag >= 0) && (tag <= 9)) {
                        
                        if (editStr.length == 2)
                        {
                            editStr = [NSMutableString stringWithString:@""];
                        }
                        
                        if ((tag == 0) && [editStr isEqualToString:@""]) {
                            return;
                        }
                        
                        [editStr appendString:[NSString stringWithFormat:@"%ld", (long)tag]];
                    }
                    else if (tag == kJCHKeyboardViewDotButton)
                    {
                        //折扣不能输入小数点
                        if (self.skuListView.currentEditLabelTag == kJCHAddProductSKUListTableViewCellTotalAmountLableTag) {
                            return;
                        }
                    }
                    else if (tag == kJCHKeyboardViewClearButton)
                    {
                        editStr = [NSMutableString stringWithString:@"不打"];
                    }
                    else if (tag == kJCHKeyboardViewBackspaceButton)
                    {
                        if (editStr.length > 0) {
                            editStr = [NSMutableString stringWithString:[editStr substringToIndex:editStr.length - 1]];
                        }
                        
                        if ([editStr isEqualToString:@""]) {
                            editStr = [NSMutableString stringWithString:@"不打"];
                        }
                        
                    }
                    else{
                        //pass
                    }
                    
                    if (tag != kJCHKeyboardViewOKButton) {
                        detail.productDiscount = [NSString stringWithFormat:@"%g", [JCHTransactionUtility getOrderDiscountFromString:editStr]];
                    }
                }
                
            }
        }
        
        
        if (tag == kJCHKeyboardViewOKButton)
        {
            JCHManifestMemoryStorage *storage = [JCHManifestMemoryStorage sharedInstance];
            //更新或添加storage中的transaction
            BOOL isTransactionInStorage = NO;
            for (ManifestTransactionDetail *storedTransactionDetail in [storage getAllManifestRecord]) {
                if ((([storedTransactionDetail.goodsNameUUID isEqualToString: detail.goodsNameUUID] && [storedTransactionDetail.goodsCategoryUUID isEqualToString:detail.goodsCategoryUUID]) && detail.skuHidenFlag) ||  //没有规格 根据名称和类型的uuid判断是否为同一商品
                    (([storedTransactionDetail.goodsNameUUID isEqualToString: detail.goodsNameUUID] && [storedTransactionDetail.goodsCategoryUUID isEqualToString:detail.goodsCategoryUUID]) && [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:detail.skuValueUUIDs] && !detail.skuHidenFlag)) { //有规格 根据名称类型的uuid还有sku判断是否为同一规格
                    
                    //当数量、价格、折扣改变是重新取当前时间
                    if ((detail.productCount != storedTransactionDetail.productCount) || (detail.productPrice != storedTransactionDetail.productPrice) || (detail.productDiscount != storedTransactionDetail.productDiscount)) {
                        storedTransactionDetail.productAddedTimestamp = time(NULL);
                    }
                    
                    storedTransactionDetail.productCount = detail.productCount;
                    storedTransactionDetail.productDiscount = detail.productDiscount;
                    storedTransactionDetail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
                    
                    if (self.tag == kKeyboardTransactionListTag) {
                        isTransactionInStorage = YES;
                    }
                    
                    
                    //数量为0，从storage中删除
                    if (storedTransactionDetail.productCountFloat == 0) {
                        [storage removeManifestRecord:detail];
                    }
                    break;
                }
            }
            
            if (self.tag == kKeyboardTransactionListTag) {
                detail.productAddedTimestamp = time(NULL);
                
                //如果没有在storage中发现，则增加一个detail
                if (!isTransactionInStorage && ([detail.productCount doubleValue] != 0)) {
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", [detail.productPrice doubleValue]];
                    [storage addManifestRecord:detail];
                }
            }
            
        }
        
    }
    
    if (tag == kJCHKeyboardViewOKButton) {
        //收回当前的sku详情
        if ([self.delegate respondsToSelector:@selector(handleKeyboardOK:editStr:)]) {
            [self.delegate handleKeyboardOK:self editStr:nil];
        }
    }
    
    
    [self.skuListView reloadData];
    
    self.skuListView.lastEditLabelTag = self.skuListView.currentEditLabelTag;
    
}



@end
