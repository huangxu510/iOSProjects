//
//  JCHUnitSpecificationInventoryTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHUnitSpecificationInventoryTableViewCell.h"
#import "JCHTagTextField.h"
#import "CommonHeader.h"


@implementation JCHUnitSpecificationInventoryTableViewCellData

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
    [self.countPlaceholderText release];
    [self.pricePlaceholderText release];
    [self.countText release];
    [self.priceText release];
    
    [super dealloc];
    return;
}

@end





@interface JCHUnitSpecificationInventoryTableViewCell ()
{
    UILabel *titleLabel;
    JCHLengthLimitTextField *countTextfield;
    JCHLengthLimitTextField *priceTextfield;
    UIView *bottomSeperateLine;
    BOOL isBottomLastCell;
}
@end

@implementation JCHUnitSpecificationInventoryTableViewCell

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
        make.height.equalTo(self.contentView);
        make.width.equalTo(self.contentView).with.multipliedBy(1.0/3).offset(-2 * kStandardLeftMargin / 3);
    }];
    
    [countTextfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
        make.width.equalTo(self.contentView).with.multipliedBy(1.0/3).offset(-2 * kStandardLeftMargin / 3);
    }];
    
    [priceTextfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countTextfield.mas_right);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
        make.width.equalTo(self.contentView).with.multipliedBy(1.0/3).offset(-2 * kStandardLeftMargin / 3);
    }];
    
    [bottomSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isBottomLastCell) {
            make.left.equalTo(self.contentView);
        } else {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        }
        
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.width.equalTo(self.contentView);
    }];
    
    return;
}

- (void)createUI
{
    UIFont *textFont = [UIFont systemFontOfSize:15.0];
    UIColor *textColor = JCHColorMainBody;

    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:textFont
                                 textColor:textColor
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:titleLabel];
    
    countTextfield = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                  placeHolder:@""
                                                    textColor:textColor
                                                       aligin:NSTextAlignmentCenter];
    countTextfield.font = textFont;
    countTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    countTextfield.textfieldType = kInventoryTextFieldCount;
    countTextfield.keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview:countTextfield];
    
    
    priceTextfield = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                  placeHolder:@""
                                                    textColor:textColor
                                                       aligin:NSTextAlignmentRight];
    priceTextfield.font = textFont;
    priceTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    priceTextfield.textfieldType = kInventoryTextFieldPrice;
    priceTextfield.keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview:priceTextfield];
    
    bottomSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:bottomSeperateLine];
    
    return;
}

- (void)setCellData:(JCHUnitSpecificationInventoryTableViewCellData *)cellData
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
         isLastCell:(BOOL)isLastCell
{
    titleLabel.text = cellData.cellTitle;
    priceTextfield.placeholder = cellData.pricePlaceholderText;
    priceTextfield.text = cellData.priceText;
    countTextfield.placeholder = cellData.countPlaceholderText;
    countTextfield.text = cellData.countText;
    priceTextfield.delegate = textfieldDelegate;
    countTextfield.delegate = textfieldDelegate;
    priceTextfield.textfieldTag = cellData.cellTag;
    countTextfield.textfieldTag = cellData.cellTag;
    isBottomLastCell = isLastCell;
    
    return;
}

- (void)enableEditCellContent:(BOOL)enable
{
    countTextfield.enabled = enable;
    priceTextfield.enabled = enable;
    
    countTextfield.userInteractionEnabled = enable;
    priceTextfield.userInteractionEnabled = enable;
}

@end
