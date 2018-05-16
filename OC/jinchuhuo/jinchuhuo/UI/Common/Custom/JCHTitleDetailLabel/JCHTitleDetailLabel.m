//
//  JCHTitleDetailView.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTitleDetailLabel.h"
#import "CommonHeader.h"

@implementation JCHTitleDetailLabel
{
    UILabel *_titleLabel;
}

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                    textColor:(UIColor *)textColor
                       detail:(NSString *)detail
             bottomLineHidden:(BOOL)hidden
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:title
                                               font:font
                                          textColor:textColor
                                             aligin:NSTextAlignmentLeft];
        [self addSubview:_titleLabel];
        
        self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:font
                                       textColor:textColor
                                          aligin:NSTextAlignmentRight];
        [self addSubview:self.detailLabel];
        
        self.bottomLine = [[[UIView alloc] init] autorelease];
        self.bottomLine.backgroundColor = JCHColorSeparateLine;
        self.bottomLine.hidden = hidden;
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)dealloc
{
    self.detailLabel = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize fitSize = [_titleLabel sizeThatFits:CGSizeZero];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width + 10);
    }];
    
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).with.offset(kStandardLeftMargin * 4);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.and.bottom.equalTo(self);
    }];
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

@end
