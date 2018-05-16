//
//  JCHProductDetailView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductDetailView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHProductDetailViewData

- (void)dealloc
{
    [self.productCategory release];
    [self.productUnit release];
    [self.productAmount release];
    [self.productCount release];
    
    [super dealloc];
}


@end

@interface JCHProductDetailView ()
{
    JCHLabel *_categoryLabel;
    JCHLabel *_unitLabel;
    JCHLabel *_countLabel;
    JCHLabel *_amountLabel;
}
@end

@implementation JCHProductDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:12.0f];
    UIFont *valueFont = [UIFont jchSystemFontOfSize:14.0f];
    UIColor *titleColor = JCHColorAuxiliary;
    UIColor *valueColor = JCHColorMainBody;
    CGFloat labelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:80.0f];
    CGFloat countLabelWidth = (kScreenWidth - 1.7 * labelWidth) / 2;
    CGFloat titleLabelHeight = 40.0f;
    CGFloat valueLabelHeight = 30.0f;
    
    UILabel *categoryTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                      title:@"类型"
                                                       font:titleFont
                                                  textColor:titleColor
                                                     aligin:NSTextAlignmentCenter];
    [self addSubview:categoryTitleLabel];
    
    [categoryTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(labelWidth);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _categoryLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                            title:@""
                                             font:valueFont
                                        textColor:valueColor
                                           aligin:NSTextAlignmentCenter];
    _categoryLabel.numberOfLines = 2;
    _categoryLabel.verticalAlignment = kVerticalAlignmentTop;
    [self addSubview:_categoryLabel];
    
    [_categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(categoryTitleLabel);
        make.top.equalTo(categoryTitleLabel.mas_bottom);
        make.width.equalTo(categoryTitleLabel);
        make.height.mas_equalTo(valueLabelHeight);
    }];
    
    UILabel *unitTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                      title:@"单位"
                                                       font:titleFont
                                                  textColor:titleColor
                                                     aligin:NSTextAlignmentCenter];
    [self addSubview:unitTitleLabel];
    
    [unitTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(categoryTitleLabel.mas_right);
        make.width.mas_equalTo(labelWidth  * 0.7);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _unitLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                            title:@""
                                             font:valueFont
                                        textColor:valueColor
                                           aligin:NSTextAlignmentCenter];
    _unitLabel.verticalAlignment = kVerticalAlignmentTop;
    [self addSubview:_unitLabel];
    
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(unitTitleLabel);
        make.top.equalTo(unitTitleLabel.mas_bottom);
        make.width.equalTo(unitTitleLabel);
        make.height.mas_equalTo(valueLabelHeight);
    }];
    
    UILabel *countTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                      title:@"数量"
                                                       font:titleFont
                                                  textColor:titleColor
                                                     aligin:NSTextAlignmentCenter];
    [self addSubview:countTitleLabel];
    
    [countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(unitTitleLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth * 0.8);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _countLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                            title:@""
                                             font:valueFont
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentCenter];
    _countLabel.verticalAlignment = kVerticalAlignmentTop;
    [self addSubview:_countLabel];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countTitleLabel);
        make.top.equalTo(countTitleLabel.mas_bottom);
        make.width.equalTo(countTitleLabel);
        make.height.mas_equalTo(valueLabelHeight);
    }];
    
    UILabel *amountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                      title:@"总价值"
                                                       font:titleFont
                                                  textColor:titleColor
                                                     aligin:NSTextAlignmentCenter];
    [self addSubview:amountTitleLabel];
    
    [amountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countTitleLabel.mas_right);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    _amountLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                            title:@""
                                             font:valueFont
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentCenter];
    _amountLabel.verticalAlignment = kVerticalAlignmentTop;
    [self addSubview:_amountLabel];
    
    [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(amountTitleLabel);
        make.top.equalTo(amountTitleLabel.mas_bottom);
        make.width.equalTo(amountTitleLabel);
        make.height.mas_equalTo(valueLabelHeight);
    }];
    
    NSArray *labels = @[_categoryLabel, _unitLabel, _countLabel, _amountLabel];
    CGFloat verticalLineTopOffset = 14.0f;
    for (NSInteger i = 0; i < 3; i++) {
        UIView *verticalLine = [[[UIView alloc] init] autorelease];
        verticalLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:verticalLine];
        
        UILabel *leftLabel = labels[i];
        [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).with.offset(verticalLineTopOffset);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.left.equalTo(leftLabel.mas_right);
        }];
    }
}

- (void)setViewData:(JCHProductDetailViewData *)data
{
    _categoryLabel.text = data.productCategory;
    _unitLabel.text = data.productUnit;
    _countLabel.text = data.productCount;
    JCHSyncStatusManager * statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isShopManager) {
        _amountLabel.text = data.productAmount;
    } else {
        _amountLabel.text = @"--.--";
    }
    
}

@end
