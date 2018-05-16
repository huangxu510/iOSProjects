//
//  JCHShopAssistantView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopAssistantView.h"
#import "CommonHeader.h"
#import "UIImage+JCHImage.h"
#import <Masonry.h>

@implementation JCHShopAssistantViewData

- (void)dealloc
{
    [self.headImage release];
    [self.markImage release];
    [self.name release];
    
    [super dealloc];
}


@end

@interface JCHShopAssistantView ()
{
    UIImageView *_markImageView;
    UILabel *_nameLabel;
}
@end

@implementation JCHShopAssistantView

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
    CGFloat headImageButtonWidth = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:50.0f noStretchingIn6Plus:YES];
    self.headImageButton = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleButtonClick)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [self.headImageButton setImage:[UIImage imageNamed:@"setting_addclerk"] forState:UIControlStateNormal];
    self.headImageButton.layer.cornerRadius = headImageButtonWidth / 2;
    self.headImageButton.clipsToBounds = YES;
    [self addSubview:self.headImageButton];
    
    [self.headImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset([JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:16 noStretchingIn6Plus:YES]);
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(headImageButtonWidth);
        make.height.mas_equalTo(headImageButtonWidth);
    }];
    
    CGFloat markImageViewWidth = 17;
    _markImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_shopkeeper"]] autorelease];
    _markImageView.backgroundColor = [UIColor whiteColor];
    _markImageView.layer.cornerRadius = markImageViewWidth / 2;
    //    _markImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    //    _markImageView.layer.borderWidth = 1.5;
    _markImageView.clipsToBounds = YES;
    _markImageView.hidden = YES;
    _markImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_markImageView];
    
    [_markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headImageButton);
        make.bottom.equalTo(self.headImageButton);
        make.width.mas_equalTo(markImageViewWidth);
        make.height.mas_equalTo(markImageViewWidth);
    }];
    
    _nameLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"找店员"
                                      font:[UIFont jchSystemFontOfSize:12.0f]
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentCenter];
    [self addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageButton.mas_bottom);
        make.height.mas_equalTo([JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:25 noStretchingIn6Plus:YES]);
        make.width.equalTo(self).with.offset(-kStandardLeftMargin);
        make.centerX.equalTo(self.headImageButton);
    }];
}

- (void)handleButtonClick
{
    if ([self.delegate respondsToSelector:@selector(handleClickView:)]) {
        [self.delegate handleClickView:self];
    }
}

- (void)setData:(JCHShopAssistantViewData *)data
{
    if (self.headImageButton != nil && ![data.headImage isEqualToString:@""]) {
        [self.headImageButton setImage:[UIImage jchAvatarImageNamed:data.headImage] forState:UIControlStateNormal];
    }
    
    if (data.markImage != nil && ![data.markImage isEqualToString:@""]) {
        _markImageView.image = [UIImage imageNamed:data.markImage];
        _markImageView.hidden = NO;
    }
    
    _nameLabel.text = data.name;
}


@end
