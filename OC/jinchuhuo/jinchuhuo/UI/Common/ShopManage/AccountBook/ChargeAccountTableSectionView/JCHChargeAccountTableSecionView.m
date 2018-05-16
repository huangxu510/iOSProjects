//
//  JCHChargeAccountTableSecionView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHChargeAccountTableSecionView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHChargeAccountTableSecionViewData

- (void)dealloc
{
    [self.headImageName release];
    [self.memberName release];
    [self.phoneNumber release];
    [self.manifestCountInfo release];
    
    [super dealloc];
}

@end

@implementation JCHChargeAccountTableSecionView
{
    UIImageView *_headImageView;
    UILabel *_memberInfoLabel;
    UILabel *_manifestCountLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //62
        self.backgroundColor = JCHColorGlobalBackground;
        _headImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homepage_avatar_default"]] autorelease];
        _headImageView.layer.cornerRadius = 20;
        _headImageView.clipsToBounds = YES;
        [self addSubview:_headImageView];
        
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(1.5 * kStandardLeftMargin);
            make.width.and.height.mas_equalTo(40);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        _manifestCountLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"1000个未收款"
                                                   font:[UIFont systemFontOfSize:15.0f]
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentRight];
        [self addSubview:_manifestCountLabel];
        
        CGSize size = [_manifestCountLabel sizeThatFits:CGSizeZero];
        [_manifestCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(size.width + 5);
            make.height.mas_equalTo(self);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        _memberInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"张小姐/1234567890"
                                                font:[UIFont systemFontOfSize:15.0f]
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentLeft];
        [self addSubview:_memberInfoLabel];
        
        [_memberInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
            make.right.equalTo(_manifestCountLabel.mas_left).with.offset(-kStandardLeftMargin);
            make.height.equalTo(self);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        UIView *bottomLine = [[[UIView alloc] init] autorelease];
        bottomLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:bottomLine];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    return self;
}

- (void)setViewData:(JCHChargeAccountTableSecionViewData *)data
{
    //_headImageView.image = [UIImage imageNamed:data.headImageName];
    _headImageView.image = [UIImage imageWithColor:nil size:_headImageView.frame.size text:data.memberName font:[UIFont systemFontOfSize:25.0f]];
    
    if ([data.phoneNumber isEmptyString]) {
        _memberInfoLabel.text = [NSString stringWithFormat:@"%@", data.memberName];
    } else {
        _memberInfoLabel.text = [NSString stringWithFormat:@"%@/%@", data.memberName, data.phoneNumber];
    }
    
    _manifestCountLabel.text = data.manifestCountInfo;
}

@end
