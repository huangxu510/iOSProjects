//
//  JCHAddMainAuxilaryUnitCell.m
//  jinchuhuo
//
//  Created by apple on 16/9/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddMainAuxilaryUnitCell.h"
#import "JCHArrowTapView.h"
#import "CommonHeader.h"

@interface JCHAddMainAuxilaryUnitCell()
{
    UILabel *mainUnitNameLabel;
    UILabel *conversionLabel;
    UIView *topSeparateLine;
    UIView *middleSeperateLine;
    UIView *bottomSeparateLine;
    JCHTagTextField *conversionRateTextfield;
    UILabel *auxilaryUnitNameLabel;
    JCHArrowTapView *unitTapView;
    UIView *bottomSeperateView;
    JCHPreventEnventTransferView *bottomContainerView;
}

@end


@implementation JCHAddMainAuxilaryUnitCell

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
    self.productUnitRecord = nil;
    [super dealloc];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [unitTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left);
        make.width.equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(unitTapView.mas_bottom);
        make.left.right.height.equalTo(unitTapView);
    }];
    
    [conversionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomContainerView).with.offset(kStandardLeftMargin);
        make.top.equalTo(unitTapView.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
        make.width.mas_equalTo(80);
    }];
    
    [mainUnitNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomContainerView.mas_right).with.offset(-kStandardLeftMargin);
        make.top.equalTo(unitTapView.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
        make.width.mas_equalTo(40.0);
    }];
    
    [conversionRateTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(mainUnitNameLabel.mas_left);
        make.top.equalTo(unitTapView.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
        make.width.mas_equalTo(120);
    }];
    
    [auxilaryUnitNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(conversionRateTextfield.mas_left);
        make.top.equalTo(unitTapView.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
        make.width.mas_equalTo(80);
    }];
    
    [topSeparateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [middleSeperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(auxilaryUnitNameLabel.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [bottomSeperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(auxilaryUnitNameLabel.mas_bottom);
        make.height.mas_equalTo(kStandardTopMargin);
    }];
    
    [bottomSeparateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    return;
}

- (void)createUI
{
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = JCHColorMainBody;
    
    self.backgroundColor = [UIColor whiteColor];
    unitTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:unitTapView];
    unitTapView.button.hidden = YES;
    
    bottomContainerView = [[[JCHPreventEnventTransferView alloc] init] autorelease];
    [self.contentView addSubview:bottomContainerView];
    
    conversionLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"换算关系"
                                           font:textFont
                                      textColor:textColor
                                         aligin:NSTextAlignmentLeft];
    [bottomContainerView addSubview:conversionLabel];
    
    auxilaryUnitNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@""
                                                      font:textFont
                                                 textColor:textColor
                                                    aligin:NSTextAlignmentRight];
    [bottomContainerView addSubview:auxilaryUnitNameLabel];
    
    mainUnitNameLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:textFont
                                        textColor:textColor
                                           aligin:NSTextAlignmentRight];
    [bottomContainerView addSubview:mainUnitNameLabel];
    
    conversionRateTextfield = [JCHUIFactory createTagTextField:CGRectZero
                                                   placeHolder:@"请输入换算参数"
                                                     textColor:textColor
                                                        aligin:NSTextAlignmentRight];
    [bottomContainerView addSubview:conversionRateTextfield];
    conversionRateTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    conversionRateTextfield.keyboardType = UIKeyboardTypeDecimalPad;
    conversionRateTextfield.textfieldTag = nil;
    
    topSeparateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:topSeparateLine];
    
    middleSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:middleSeperateLine];
    
    bottomSeparateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:bottomSeparateLine];
    
    bottomSeperateView = [JCHUIFactory createSeperatorLine:0];
    bottomSeperateView.backgroundColor = JCHColorGlobalBackground;
    [self.contentView addSubview:bottomSeperateView];
    
    [self.contentView bringSubviewToFront:middleSeperateLine];
}

- (void)setCellData:(NSInteger)cellIndex
       mainUnitName:(NSString *)mainUnitName
   auxilaryUnitName:(NSString *)auxilaryUnitName
       convertRatio:(NSString *)convertRatio
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
{
    unitTapView.titleLabel.text = [NSString stringWithFormat:@"辅单位%ld", (long)cellIndex];
    unitTapView.detailLabel.text = auxilaryUnitName;
    mainUnitNameLabel.text = mainUnitName;
    auxilaryUnitNameLabel.text = [NSString stringWithFormat:@"1%@ = ", auxilaryUnitName];
    conversionRateTextfield.text = convertRatio;
    conversionRateTextfield.textfieldTag = self.productUnitRecord;
    conversionRateTextfield.delegate = textfieldDelegate;
    
    return;
}

@end
