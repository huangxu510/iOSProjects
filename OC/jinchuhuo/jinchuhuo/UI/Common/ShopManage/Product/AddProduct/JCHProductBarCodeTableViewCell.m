//
//  JCHProductBarCodeTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHProductBarCodeTableViewCell.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHTagTextField.h"
#import "CommonHeader.h"


@interface JCHProductBarCodeTableViewCell ()
{
    UILabel *titleLabel;
    JCHLengthLimitTextField *codeTextfield;
    UIButton *camareButton;
    UIView *bottomSeperateView;
    UIView *topSeperateLine;
    UIView *middleSeperateLine;
    UIView *bottomSeperateLine;
    UIViewController *cellHostController;
    BOOL isLastBottomCell;
    BOOL isFirstTopCell;
}
@end

@implementation JCHProductBarCodeTableViewCell

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
    
    
    codeTextfield = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                 placeHolder:@"请输入或扫描条码"
                                                   textColor:textColor
                                                      aligin:NSTextAlignmentRight];
    codeTextfield.decimalPointOnly = NO;
    codeTextfield.maxStringLength = kMaxSaveStringLength;
    [self.contentView addSubview:codeTextfield];
    
    camareButton = [JCHUIFactory createButton:CGRectMake(12, 0, 20, 20)
                                       target:self
                                       action:@selector(handleScanBarCode:)
                                        title:nil
                                   titleColor:[UIColor blueColor]
                              backgroundColor:nil];
    [camareButton setImage:[UIImage imageNamed:@"btn_setting_goods_scan"] forState:UIControlStateNormal];
    [self.contentView addSubview:camareButton];
    
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat barCodeButtonWidth = 20;
    const CGFloat titleLabelWidth = 120;
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.width.mas_equalTo(titleLabelWidth);
        if (bottomSeperateView.hidden) {
            make.bottom.equalTo(self.contentView);
        } else {
            make.bottom.equalTo(self.contentView).with.offset(-kStandardSeparateViewHeight);
        }
    }];
    
    [codeTextfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right);
        make.right.equalTo(camareButton.mas_left).with.offset(-kStandardLeftMargin);
        make.top.equalTo(titleLabel);
        make.bottom.equalTo(titleLabel);
    }];
    
    [camareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(codeTextfield.mas_centerY);
        make.height.mas_equalTo(barCodeButtonWidth);
        make.width.mas_equalTo(barCodeButtonWidth);
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

- (void)handleScanBarCode:(id)sender
{
    JCHBarCodeScannerViewController *controller = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
    controller.title = @"扫码";
    controller.metadataObjectTypes = @[AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code];
    WeakSelf;
    controller.barCodeBlock = ^(NSString *barCode) {
        weakSelf -> codeTextfield.text = barCode;
        [cellHostController performSelector:@selector(textFieldDidEndEditing:) withObject:weakSelf->codeTextfield];
    };
    [cellHostController presentViewController:controller animated:YES completion:nil];
    
    return;
}

- (void)setCellData:(JCHProductBarCodeTableViewCellData *)cellData
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
     showBottomView:(BOOL)showBottomView
        isFirstCell:(BOOL)isFirstCell
         isLastCell:(BOOL)isLastCell
{
    titleLabel.text = cellData.cellTitle;
    codeTextfield.placeholder = @"请输入或扫描条码";
    codeTextfield.text = cellData.barCode;
    codeTextfield.delegate = textfieldDelegate;
    codeTextfield.textfieldTag = cellData.cellTag;
    cellHostController = cellData.hostController;
    
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

@end




@implementation JCHProductBarCodeTableViewCellData

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
    [self.barCode release];
    
    [super dealloc];
    return;
}

@end





