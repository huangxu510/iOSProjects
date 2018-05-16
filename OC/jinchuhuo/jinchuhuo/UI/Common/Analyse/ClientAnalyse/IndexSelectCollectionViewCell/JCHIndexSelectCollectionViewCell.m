//
//  JCHIndexSelectCollectionViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHIndexSelectCollectionViewCell.h"
#import "CommonHeader.h"

@implementation JCHIndexSelectCollectionViewCell
{
    JCHLabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = JCHColorSeparateLine;
        _titleLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                             title:@""
                                              font:JCHFont(12)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentCenter];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textInset = UIEdgeInsetsMake(0, 2, 0, 2);
        [self.contentView addSubview:_titleLabel];
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kSeparateLineWidth / 2);
        make.right.equalTo(self.contentView).with.offset(-kSeparateLineWidth / 2);
        make.top.equalTo(self.contentView).with.offset(kSeparateLineWidth / 2);
        make.bottom.equalTo(self.contentView).with.offset(-kSeparateLineWidth / 2);
    }];
}

- (void)dealloc
{
    self.contentString = nil;
    
    [super dealloc];
}

- (void)setContentString:(NSString *)contentString
{
    if (_contentString != contentString) {
        [_contentString release];
        _contentString = [contentString retain];
        _titleLabel.text = contentString;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    _titleLabel.textColor = selected ? JCHColorHeaderBackground : JCHColorMainBody;
}

@end
