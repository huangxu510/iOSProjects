//
//  JCHUnitSpecificationInventorySectionView.m
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHUnitSpecificationInventorySectionView.h"
#import "CommonHeader.h"

@interface JCHUnitSpecificationInventorySectionView()
{
    UILabel *titleLabel;
    UILabel *countLabel;
    UILabel *priceLabel;
    UIView *topLineView;
    UIView *bottomLineView;
}

@property (retain, nonatomic, readwrite) NSArray<NSString *> *titlesArray;

@end

@implementation JCHUnitSpecificationInventorySectionView

- (id)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titlesArray = titles;        
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [self.titlesArray release];
    [super dealloc];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self).with.multipliedBy(1.0/3).offset(-2 * kStandardLeftMargin / 3);
    }];
    
    [countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right);
        make.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self).with.multipliedBy(1.0/3).offset(-2 * kStandardLeftMargin / 3);
    }];
    
    [priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countLabel.mas_right);
        make.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self).with.multipliedBy(1.0/3).offset(-2 * kStandardLeftMargin / 3);
    }];
    
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self.mas_bottom).with.offset(-kSeparateLineWidth);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    return;
}

- (void)createUI
{
    UIFont *textFont = [UIFont systemFontOfSize:12.0];
    UIColor *textColor = JCHColorMainBody;
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:self.titlesArray[0]
                                      font:textFont
                                 textColor:textColor
                                    aligin:NSTextAlignmentLeft];
    [self addSubview:titleLabel];
    
    countLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:self.titlesArray[1]
                                      font:textFont
                                 textColor:textColor
                                    aligin:NSTextAlignmentCenter];
    [self addSubview:countLabel];
    
    priceLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:self.titlesArray[2]
                                      font:textFont
                                 textColor:textColor
                                    aligin:NSTextAlignmentRight];
    [self addSubview:priceLabel];
    
    bottomLineView = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self addSubview:bottomLineView];
    
    topLineView = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self addSubview:topLineView];
    
    return;
}

@end
