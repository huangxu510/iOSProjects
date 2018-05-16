//
//  JCHProductDetailFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHProductDetailFooterView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import <Masonry.h>


@implementation JCHProductDetailFooterViewData

- (void)dealloc
{
    [self.traderCode release];
    [self.barCode release];
    [self.remark release];
    
    [super dealloc];
}


@end
@interface JCHProductDetailFooterView ()
{
    UILabel *_traderCodeLabel;
    UILabel *_barCodeLabel;
    UILabel *_remarkLabel;
    CGFloat _remarkLabelHeight;
    CGFloat _remarkLabelWidth;
}
@end

@implementation JCHProductDetailFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *textFont = [UIFont systemFontOfSize:13.0f];
    UIColor *textColor = JCHColorAuxiliary;
    CGFloat labelHeight = 38.0f;
    
    _traderCodeLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:textFont
                                       textColor:textColor
                                          aligin:NSTextAlignmentLeft];
    [self addSubview:_traderCodeLabel];
    
    [_traderCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.mas_equalTo(labelHeight);
    }];
    
    _barCodeLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:textFont
                                    textColor:textColor
                                       aligin:NSTextAlignmentLeft];
    [self addSubview:_barCodeLabel];
    
    [_barCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_traderCodeLabel);
        make.right.equalTo(_traderCodeLabel);
        make.height.equalTo(_traderCodeLabel);
        make.top.equalTo(_traderCodeLabel.mas_bottom);
    }];
    
    UILabel *remarkTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"备注："
                                                     font:textFont
                                                textColor:textColor
                                                   aligin:NSTextAlignmentLeft];
    CGSize fitSize = [@"备注：" sizeWithAttributes:@{NSFontAttributeName : textFont}];
    [self addSubview:remarkTitleLabel];
    
    [remarkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_barCodeLabel);
        make.width.mas_equalTo(fitSize.width + 5);
        make.top.equalTo(_barCodeLabel.mas_bottom);
        make.height.equalTo(_barCodeLabel);
    }];
    
    _remarkLabelWidth = kScreenWidth - 4 * kStandardLeftMargin - fitSize.width;
    _remarkLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:textFont
                                   textColor:textColor
                                      aligin:NSTextAlignmentLeft];
    _remarkLabel.numberOfLines = 0;
    [self addSubview:_remarkLabel];
    
    [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(remarkTitleLabel.mas_right);
        make.right.equalTo(_barCodeLabel);
        make.top.equalTo(_barCodeLabel.mas_bottom);
        make.height.mas_equalTo(_remarkLabelHeight);
    }];
    
    for (NSInteger i = 0; i < 2; i++) {
        UIImageView *horizontalLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
        [self addSubview:horizontalLine];
        
        [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_traderCodeLabel);
            make.right.equalTo(_traderCodeLabel);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.top.equalTo(self).with.offset((i + 1) * labelHeight);
        }];
    }
}

- (void)setViewData:(JCHProductDetailFooterViewData *)data
{
    _traderCodeLabel.text = [NSString stringWithFormat:@"商家简称：%@", data.traderCode];
    _barCodeLabel.text = [NSString stringWithFormat:@"条码：%@", data.barCode];
    _remarkLabel.text = [NSString stringWithFormat:@"%@", data.remark];
    
    CGRect rect = [data.remark boundingRectWithSize:CGSizeMake(_remarkLabelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f]} context:nil];
    
    _remarkLabelHeight = rect.size.height + 5;
    if (_remarkLabelHeight < 38) {
        _remarkLabelHeight = 38;
    }
    
    [_remarkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_remarkLabelHeight);
    }];
    
    
    self.viewHeight = 2 * 38 + _remarkLabelHeight;
}



@end
