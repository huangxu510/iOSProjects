//
//  JCHShopCategorySelectButton.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopCategorySelectButton.h"
#import "CommonHeader.h"

@implementation JCHShopCategorySelectButton
{
    UIImageView *_selectImageView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kinds_select"]] autorelease];
        _selectImageView.hidden = YES;
        [self addSubview:_selectImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:21.0f];
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:25.0f];
    [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageViewWidth);
        make.height.mas_equalTo(imageViewHeight);
        make.left.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.imageView.mas_bottom);
    }];
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat x = (contentRect.size.width - 40) / 2;
    CGFloat y = 15;
    CGFloat height = 40;
    CGFloat width = 40;
    return CGRectMake(x, y, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = 55;
    CGFloat height = contentRect.size.height - y;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _selectImageView.hidden = !selected;
}

@end
