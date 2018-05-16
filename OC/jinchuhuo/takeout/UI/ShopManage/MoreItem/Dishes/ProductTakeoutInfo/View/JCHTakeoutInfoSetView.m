//
//  JCHTakeoutInfoSetView.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutInfoSetView.h"
#import "CommonHeader.h"

@implementation JCHTakeoutInfoSetViewData

- (void)dealloc
{
    self.skuName = nil;
    self.skuUUIDVector = nil;
    
    [super dealloc];
}

@end

@interface JCHTakeoutInfoSetView ()

@property (retain, nonatomic) JCHTakeoutInfoSetViewData *data;

@end

@implementation JCHTakeoutInfoSetView
{
    JCHTitleDetailLabel *_skuNameLabel;
    JCHTitleTextField *_boxCountLabel;
    JCHTitleTextField *_boxPriceLabel;
    
    JCHProductSKUMode _currentMode;
}
- (instancetype)initWithFrame:(CGRect)frame productSKUMode:(JCHProductSKUMode)productSKUMode
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentMode = productSKUMode;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.data = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.backgroundColor = JCHColorGlobalBackground;
    
    _skuNameLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"规格名称" font:JCHFont(14) textColor:JCHColorMainBody detail:@"" bottomLineHidden:NO] autorelease];
    [self addSubview:_skuNameLabel];
    
    [_skuNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kStandardSeparateViewHeight);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _boxCountLabel = [[[JCHTitleTextField alloc] initWithTitle:@"餐盒数量" font:JCHFont(14) placeholder:@"0" textColor:JCHColorMainBody isLengthLimitTextField:YES] autorelease];
    _boxCountLabel.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self addSubview:_boxCountLabel];
    
    [_boxCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_skuNameLabel.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _boxPriceLabel = [[[JCHTitleTextField alloc] initWithTitle:@"餐盒价格" font:JCHFont(14) placeholder:@"0.00" textColor:JCHColorMainBody isLengthLimitTextField:YES] autorelease];
    _boxPriceLabel.textField.keyboardType = UIKeyboardTypeDecimalPad;
    _boxPriceLabel.bottomLine.hidden = YES;
    [_boxPriceLabel addSeparateLineWithMasonryTop:NO bottom:YES];
    [self addSubview:_boxPriceLabel];
    
    [_boxPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_boxCountLabel.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    
    if (_currentMode == kJCHProductWithoutSKU) {
        [_skuNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [_boxCountLabel addSeparateLineWithMasonryTop:YES bottom:NO];
        self.viewHeight = 2 * kStandardItemHeight + kStandardSeparateViewHeight;
    } else {
        self.viewHeight = 3 * kStandardItemHeight + kStandardSeparateViewHeight;
        [_skuNameLabel addSeparateLineWithMasonryTop:YES bottom:NO];
    }
}


- (void)setViewData:(JCHTakeoutInfoSetViewData *)data
{
    if (_currentMode == kJCHProductWithSKU) {
        _skuNameLabel.detailLabel.text = data.skuName;
    }
    
    if (data.boxCount == 0) {
        _boxCountLabel.textField.text = @"";
    } else {
        _boxCountLabel.textField.text = [NSString stringWithFormat:@"%ld", data.boxCount];
    }
    
    if (data.boxPrice == 0) {
        _boxPriceLabel.textField.text = @"";
    } else {
        _boxPriceLabel.textField.text = [NSString stringWithFormat:@"%.2f", data.boxPrice];
    }
    
    self.data = data;
}

- (JCHTakeoutInfoSetViewData *)getData
{
    self.data.boxCount = _boxCountLabel.textField.text.integerValue;
    self.data.boxPrice = _boxPriceLabel.textField.text.doubleValue;
    return self.data;
}

@end
