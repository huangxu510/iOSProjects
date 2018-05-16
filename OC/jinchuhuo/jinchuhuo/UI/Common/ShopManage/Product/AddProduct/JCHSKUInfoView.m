//
//  JCHSKUInfoView.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSKUInfoView.h"
#import "CommonHeader.h"

@interface JCHSKUInfoView ()
@property (nonatomic, retain) NSDictionary *skuData;
@end

@implementation JCHSKUInfoView
{
    UIButton *_deleteButton;
    UILabel *_skuTypeLabel;
    UILabel *_skuValueLabel;
    UIView *_bottomLine;
}

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
    self.deleteSKUBlock = nil;
    self.skuData = nil;
    [super dealloc];
}


- (void)createUI
{
    CGFloat deleteButtonWidth = 23;
    CGFloat skuTypeLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:100.0f];
    _deleteButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(deleteSKU)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    [_deleteButton setImage:[UIImage imageNamed:@"bt_setting_delete"] forState:UIControlStateNormal];
    [self addSubview:_deleteButton];
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(deleteButtonWidth);
        make.top.bottom.equalTo(self);
    }];
    
    _skuTypeLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:JCHFont(15)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    _skuTypeLabel.numberOfLines = 1;
    [self addSubview:_skuTypeLabel];
    
    [_skuTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(_deleteButton.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(skuTypeLabelWidth);
    }];
    
    _skuValueLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(15)
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentRight];
    _skuValueLabel.numberOfLines = 2;
    _skuValueLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_skuValueLabel];

    [_skuValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuTypeLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self);
    }];
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_bottomLine];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_deleteButton);
        make.bottom.right.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)setViewData:(NSDictionary *)data
{
    NSString *skuType = [[data allKeys] firstObject];
    _skuTypeLabel.text = skuType;
    NSArray *skuValueArray = [[data allValues] firstObject];
    NSMutableString *skuValueCombine = [NSMutableString string];
    for (NSInteger i = 0; i < skuValueArray.count; i++) {
        SKUValueRecord4Cocoa *skuValueRecord = skuValueArray[i];
        [skuValueCombine appendString:skuValueRecord.skuValue];
        if (i != skuValueArray.count - 1) {
            [skuValueCombine appendString:@"/"];
        }
    }
    _skuValueLabel.text = skuValueCombine;
    self.skuData = data;
}

- (void)deleteSKU
{
    if (self.deleteSKUBlock) {
        self.deleteSKUBlock(self.skuData);
    }
}

- (void)hideBottomLine:(BOOL)hidden
{
    _bottomLine.hidden = hidden;
}
@end
