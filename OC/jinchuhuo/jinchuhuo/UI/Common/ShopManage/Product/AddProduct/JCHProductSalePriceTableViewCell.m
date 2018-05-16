//
//  JCHProductSalePriceTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHProductSalePriceTableViewCell.h"
#import "JCHTagTextField.h"
#import "CommonHeader.h"



@interface JCHProductSalePriceTableViewCell ()
{
    UILabel *titleLabel;
    JCHLengthLimitTextField *priceTextfield;
    UIView *bottomSeperateView;
    UIView *topSeperateLine;
    UIView *middleSeperateLine;
    UIView *bottomSeperateLine;
    BOOL isLastBottomCell;
    BOOL isFirstTopCell;
}
@end

@implementation JCHProductSalePriceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.width.equalTo(self.contentView).with.multipliedBy(1.0/3);
        
        if (bottomSeperateView.hidden) {
            make.bottom.equalTo(self.contentView);
        } else {
            make.bottom.equalTo(self.contentView).with.offset(-kStandardSeparateViewHeight);
        }
    }];
    
    [priceTextfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardRightMargin);
        make.top.equalTo(titleLabel);
        make.bottom.equalTo(titleLabel);
        make.width.equalTo(self.contentView).with.multipliedBy(1.0/3);
    }];
    
    [bottomSeperateView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kStandardSeparateViewHeight);
        make.width.equalTo(self.contentView);
    }];
    
    [bottomSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isLastBottomCell || isFirstTopCell) {
            make.left.equalTo(self.contentView);
        } else {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        }
        
        make.bottom.equalTo(self.contentView.mas_bottom);
        
        make.height.mas_equalTo(kSeparateLineWidth);
        make.width.equalTo(self.contentView);
    }];
    
    [middleSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-kStandardSeparateViewHeight);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.width.equalTo(self.contentView);
    }];
    
    [topSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.width.equalTo(self.contentView);
    }];
    
    return;
}

- (void)createUI
{
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = JCHColorMainBody;
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:textFont
                                 textColor:textColor
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:titleLabel];
    
    priceTextfield = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                  placeHolder:@"¥0.00"
                                                    textColor:textColor
                                                       aligin:NSTextAlignmentRight];
    priceTextfield.font = textFont;
    priceTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    priceTextfield.keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview:priceTextfield];
    
    bottomSeperateView = [JCHUIFactory createSeperatorLine:1.0];
    bottomSeperateView.backgroundColor = JCHColorGlobalBackground;
    [self.contentView addSubview:bottomSeperateView];
    
    bottomSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:bottomSeperateLine];
    
    middleSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:middleSeperateLine];
    middleSeperateLine.hidden = YES;
    
    topSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:topSeperateLine];
    topSeperateLine.hidden = YES;
    
    return;
}

- (void)setCellData:(JCHProductSalePriceTableViewCellData *)cellData
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
     showBottomView:(BOOL)showBottomView
        isFirstCell:(BOOL)isFirstCell
         isLastCell:(BOOL)isLastCell
{
    titleLabel.text = cellData.cellTitle;
    priceTextfield.placeholder = @"0.00";
    priceTextfield.text = cellData.priceText;
    priceTextfield.delegate = textfieldDelegate;
    priceTextfield.textfieldTag = cellData.cellTag;
    
    CGFloat bottomViewHeight = 0.0;
    if (YES == showBottomView) {
        bottomViewHeight = kStandardSeparateViewHeight;
    }
    
    if (YES == showBottomView) {
        bottomSeperateView.hidden = NO;
        bottomSeperateLine.hidden = YES;
    } else {
        bottomSeperateView.hidden = YES;
        bottomSeperateLine.hidden = NO;
    }
    
    isFirstTopCell = isFirstCell;
    isLastBottomCell = isLastCell;
    
    if (isFirstTopCell) {
        topSeperateLine.hidden = NO;
        bottomSeperateLine.hidden = NO;
        middleSeperateLine.hidden = NO;
    } else {
        topSeperateLine.hidden = YES;
        middleSeperateLine.hidden = YES;
    }
    
    if (NO == showBottomView) {
        middleSeperateLine.hidden = YES;
    } else {
        middleSeperateLine.hidden = NO;
    }
    
    [bottomSeperateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(bottomViewHeight);
    }];
    
    [self setNeedsDisplay];
    
    return;
}

- (void)setCellText:(NSString *)cellText
{
    priceTextfield.text = cellText;
}

@end



@implementation JCHProductSalePriceTableViewCellData

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.cellTitle release];
    [self.priceText release];
    
    [super dealloc];
    return;
}

@end

