//
//  JCHSavingCardLadderCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardLadderCell.h"
#import "CommonHeader.h"

@implementation JCHSavingCardLadderCellData


@end

@implementation JCHSavingCardLadderCell
{
    UILabel *_indexLabel;
    UITextField *_lowerLimitAmountTextField;
    UITextField *_upperLimitAmountTextField;
    UITextField *_discountTextField;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.textFieldDidEndEditingBlock = nil;
    self.textFieldEditingChangedBlock = nil;
    [super dealloc];
}


- (void)createUI
{
    UIFont *textFieldFont = JCHFont(15.0f);
    CGFloat indexLabelHeight = 23.0f;
    CGFloat discountTextFieldWidth = [JCHSizeUtility calculateWidthWithSourceWidth:65.0f];
    _indexLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"1"
                                       font:JCHFontStandard
                                  textColor:[UIColor whiteColor]
                                     aligin:NSTextAlignmentCenter];
    _indexLabel.layer.cornerRadius = indexLabelHeight / 2;
    _indexLabel.clipsToBounds = YES;
    _indexLabel.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_indexLabel];
    
    [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
        make.width.and.height.mas_equalTo(indexLabelHeight);
    }];
    
    _discountTextField = [JCHUIFactory createTextField:CGRectZero
                                          placeHolder:@"不打"
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentRight];
    _discountTextField.font = textFieldFont;
    _discountTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_discountTextField addRightView:@"折" font:textFieldFont];
    _discountTextField.delegate = self;
    _discountTextField.tag = kJCHSavingCardLadderCellDiscountTextFieldTag;
    [_discountTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_discountTextField];
    
    [_discountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(discountTextFieldWidth);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    
    UILabel *middleLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"至"
                                                font:textFieldFont
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentRight];
    CGSize middleLabelSize = [middleLabel sizeThatFits:CGSizeZero];
    [self.contentView addSubview:middleLabel];
    
    CGFloat lowerLimitAmountTextFieldWidth = (kScreenWidth - 6 * kStandardLeftMargin - discountTextFieldWidth - indexLabelHeight - middleLabelSize.width) / 2;
    _lowerLimitAmountTextField = [JCHUIFactory createTextField:CGRectZero
                                                   placeHolder:@"余额下限"
                                                     textColor:JCHColorMainBody
                                                        aligin:NSTextAlignmentRight];
    _lowerLimitAmountTextField.font = textFieldFont;
    [_lowerLimitAmountTextField addRightView:@"元" font:textFieldFont];
    _lowerLimitAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    _lowerLimitAmountTextField.delegate = self;
    _lowerLimitAmountTextField.tag = kJCHSavingCardLadderCellLowerLimitAmountTextFieldTag;
    [_lowerLimitAmountTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_lowerLimitAmountTextField];
    
    [_lowerLimitAmountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_indexLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(lowerLimitAmountTextFieldWidth);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    
    [middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lowerLimitAmountTextField.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(middleLabelSize.width);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    
    _upperLimitAmountTextField = [JCHUIFactory createTextField:CGRectZero
                                                   placeHolder:@"余额上限"
                                                     textColor:JCHColorMainBody
                                                        aligin:NSTextAlignmentRight];
    _upperLimitAmountTextField.font = textFieldFont;
    _upperLimitAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    _upperLimitAmountTextField.delegate = self;
    _upperLimitAmountTextField.tag = kJCHSavingCardLadderCellUpperLimitAmountTextFieldTag;
    [_upperLimitAmountTextField addRightView:@"元" font:textFieldFont];
    [_upperLimitAmountTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_upperLimitAmountTextField];
    
    [_upperLimitAmountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(middleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(lowerLimitAmountTextFieldWidth);
        make.top.and.bottom.equalTo(self.contentView);
    }];
}

- (void)setCellData:(JCHSavingCardLadderCellData *)data
{
    _indexLabel.text = [NSString stringWithFormat:@"%ld", (long)data.index];
    _lowerLimitAmountTextField.text = [JCHSavingCardUtility switchToAmountStringValue:data.lowerLimitAmount];
    _upperLimitAmountTextField.text = [JCHSavingCardUtility switchToAmountStringValue:data.upperLimitAmount];
    
    _discountTextField.text = [JCHSavingCardUtility switchToDiscountStringValue:data.discount];
}

- (void)setLowerLimitAmountTextFieldEnabled:(BOOL)enabled
{
    _lowerLimitAmountTextField.enabled = enabled;
}


- (void)textFieldEditingChanged:(UITextField *)textField
{
    if (self.textFieldEditingChangedBlock) {
        self.textFieldEditingChangedBlock(textField, self);
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.textFieldDidEndEditingBlock) {
        self.textFieldDidEndEditingBlock(textField, self);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _discountTextField) {
        if (textField.text.length < 2 || [string isEqualToString:@""]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}


@end
