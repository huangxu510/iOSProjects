//
//  JCHSettingCollectionViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettingCollectionViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHSettingCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.headImageView = [[[UIImageView alloc] init] autorelease];
        self.headImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.headImageView];
        
        CGFloat headImageViewHeight = 27.0f;
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_centerY).with.offset(3);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.height.mas_equalTo(headImageViewHeight);
            make.width.mas_equalTo(headImageViewHeight);
        }];
        
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:nil
                                               font:[UIFont systemFontOfSize:12.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headImageView.mas_bottom);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.height.mas_equalTo(35);
        }];
        
        UIView *selectedBackgroundView = [[[UIView alloc] initWithFrame:frame] autorelease];
        selectedBackgroundView.backgroundColor = JCHColorSelectedBackground;
        self.selectedBackgroundView = selectedBackgroundView;
    }
    return self;
}

- (void)dealloc
{
    [self.titleLabel release];
    [self.headImageView release];
    [super dealloc];
}

@end
