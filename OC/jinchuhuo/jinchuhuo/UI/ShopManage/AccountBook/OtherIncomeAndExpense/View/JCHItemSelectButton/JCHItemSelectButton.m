//
//  JCHItemSelectButton.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHItemSelectButton.h"
#import "CommonHeader.h"

@interface JCHItemSelectButton ()

@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *selectedImage;

@end

@implementation JCHItemSelectButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = JCHColorMainBody;
    }
    return self;
}

- (void)dealloc
{
    self.normalImage = nil;
    self.selectedImage = nil;
    
    [super dealloc];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    
    CGFloat width = 40;//contentRect.size.width * 3 / 5;
    CGFloat height = width;

    CGFloat x = (contentRect.size.width - width) / 2;
    CGFloat y = 0;
    return CGRectMake(x, y, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = 40;//contentRect.size.width * 3 / 5;
    CGFloat height = 30;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    self.imageView.clipsToBounds = YES;
    self.titleLabel.textColor = JCHColorMainBody;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        if (self.imageViewBackgroundColorWhenSelected) {
            self.imageView.backgroundColor = self.imageViewBackgroundColorWhenSelected;
        }
    } else {
        self.imageView.backgroundColor = self.backgroundColor;
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    if (state == UIControlStateNormal) {
        self.normalImage = image;
        self.selectedImage = [image imageWithTintColor:[UIColor whiteColor]];
        [super setImage:self.selectedImage forState:UIControlStateSelected];
    } else if (state == UIControlStateSelected) {
        self.selectedImage = image;
    }
}

@end
