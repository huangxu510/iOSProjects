//
//  JCHBeginInventoryForSKUView.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBeginInventoryForSKUView.h"
#import "CommonHeader.h"

@implementation JCHBeginInventoryForSKUViewData

- (void)dealloc
{
    self.skuCombine = nil;
    self.unit = nil;
    self.skuUUIDVector = nil;
    self.goodsSKUUUID = nil;
    self.unitUUID = nil;
    self.warehouseUUID = nil;
    self.warehouseName = nil;
    [super dealloc];
}


@end


@implementation JCHBeginInventoryForSKUView
{
    UILabel *_skuCombineLabel;
    UILabel *_priceLabel;
    UILabel *_countLabel;
    UIImageView *_arrowImageView;
    JCHTitleTextField *_priceTitleTextField;
    JCHTitleTextField *_inventoryTitleTextField;
    UIView *_bottomLine;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.viewTapBlock = nil;
    self.data  = nil;
    
    [super dealloc];
}


- (void)createUI
{
    CGFloat arrowImageWidth = 18.0f;
    CGFloat skuCombineLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120];
    CGFloat priceLabelWidth = (kScreenWidth - arrowImageWidth - skuCombineLabelWidth - kStandardLeftMargin * 5) / 2;
    
    UIView *topContainerView = [[[UIView alloc] init] autorelease];
    [self addSubview:topContainerView];
    
    [topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction)] autorelease];
    [topContainerView addGestureRecognizer:tap];
    
    _arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beginInventory_btn_open"]] autorelease];
    [topContainerView addSubview:_arrowImageView];
    
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topContainerView).with.offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(arrowImageWidth);
        make.top.equalTo(topContainerView).with.offset((kStandardItemHeight - arrowImageWidth) / 2);
    }];
    
    _skuCombineLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFontStandard
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    _skuCombineLabel.numberOfLines = 2;
    _skuCombineLabel.adjustsFontSizeToFitWidth = YES;
    [topContainerView addSubview:_skuCombineLabel];
    
    [_skuCombineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topContainerView).with.offset(kStandardLeftMargin);
        make.top.equalTo(topContainerView);
        make.height.mas_equalTo(kStandardItemHeight);
        make.width.mas_equalTo(skuCombineLabelWidth);
    }];
    
    _priceLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    _priceLabel.adjustsFontSizeToFitWidth = YES;
    [topContainerView addSubview:_priceLabel];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuCombineLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(priceLabelWidth);
        make.top.bottom.equalTo(_skuCombineLabel);
    }];
    
    _countLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    _countLabel.adjustsFontSizeToFitWidth = YES;
    [topContainerView addSubview:_countLabel];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_priceLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.top.bottom.equalTo(_priceLabel);
    }];
    
    UIView *middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [topContainerView addSubview:middleLine];
    
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topContainerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(topContainerView);
        make.bottom.equalTo(topContainerView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _priceTitleTextField = [[JCHTitleTextField alloc] initWithTitle:@"期初单价"
                                                               font:JCHFontStandard
                                                        placeholder:@"请输入期初单价"
                                                          textColor:JCHColorMainBody];
    _priceTitleTextField.bottomLine.hidden = YES;
    _priceTitleTextField.textField.keyboardType = UIKeyboardTypeDecimalPad;
    [_priceTitleTextField addSeparateLineWithMasonryTop:NO bottom:YES];
    [_priceTitleTextField.textField addTarget:self
                                       action:@selector(textFieldEditingChanged:)
                             forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_priceTitleTextField];
    
    [_priceTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuCombineLabel);
        make.right.equalTo(self);
        make.top.equalTo(_skuCombineLabel.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _inventoryTitleTextField = [[JCHTitleTextField alloc] initWithTitle:@"期初库存"
                                                                   font:JCHFontStandard
                                                            placeholder:@"请输入期初库存"
                                                              textColor:JCHColorMainBody];
    _inventoryTitleTextField.bottomLine.hidden = YES;
    _inventoryTitleTextField.textField.keyboardType = UIKeyboardTypeDecimalPad;
    [_inventoryTitleTextField.textField addTarget:self
                                           action:@selector(textFieldEditingChanged:)
                                 forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_inventoryTitleTextField];
    
    [_inventoryTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_priceTitleTextField.mas_bottom);
        make.left.right.height.equalTo(_priceTitleTextField);
    }];
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_bottomLine];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)handleTapAction
{
    self.expand = !self.isExpand;
    if (self.viewTapBlock) {
        self.viewTapBlock(self.expand);
    }
}

- (void)setExpand:(BOOL)expand
{
    _expand = expand;
    if (expand) {
        _arrowImageView.image = [UIImage imageNamed:@"beginInventory_btn_close"];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(3 * kStandardItemHeight);
        }];
        
        _priceTitleTextField.textField.text = self.data.price == 0 ? @"" : [NSString stringWithFormat:@"%.2f", self.data.price];
        _inventoryTitleTextField.textField.text = self.data.count == 0 ? @"" : [NSString stringWithFormat:@"%@", [NSString stringFromCount:self.data.count unitDigital:self.data.unitDigital]];
        _priceLabel.hidden = YES;
        _countLabel.hidden = YES;
    } else {
        _arrowImageView.image = [UIImage imageNamed:@"beginInventory_btn_open"];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStandardItemHeight);
        }];
        
        self.data.price = [_priceTitleTextField.textField.text doubleValue];
        self.data.count = [_inventoryTitleTextField.textField.text doubleValue];
        [self setViewData:self.data];
        _priceLabel.hidden = NO;
        _countLabel.hidden = NO;
    }
}

- (void)setViewData:(JCHBeginInventoryForSKUViewData *)data
{
    self.data = data;
    _skuCombineLabel.text = data.skuCombine;
    _priceLabel.text = [NSString stringWithFormat:@"¥%.2f", data.price];
    _countLabel.text = [NSString stringWithFormat:@"%@%@", [NSString stringFromCount:data.count unitDigital:data.unitDigital], data.unit];
}

- (void)setBottomLineHidden:(BOOL)hidden
{
    _bottomLine.hidden = hidden;
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    if (textField == _priceTitleTextField.textField) {
        self.data.price = [_priceTitleTextField.textField.text doubleValue];
        [self setViewData:self.data];
    } else {
        self.data.count = [_inventoryTitleTextField.textField.text doubleValue];
        [self setViewData:self.data];
    }
}


@end
