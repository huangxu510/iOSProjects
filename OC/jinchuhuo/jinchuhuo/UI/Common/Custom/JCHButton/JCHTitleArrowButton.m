//
//  JCHTitleArrowButton.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTitleArrowButton.h"

@implementation JCHTitleArrowButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = self.imageView;
        imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.maxWidth = CGFLOAT_MAX;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (self.autoReverseArrow) {
        UIImageView *buttonImageView = self.imageView;
        if (selected) {
            buttonImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            buttonImageView.transform = CGAffineTransformIdentity;
        }
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    CGSize labelSize = [self.titleLabel sizeThatFits:CGSizeZero];
    CGSize imageSize = self.imageView.image.size;
    if (self.arrowHidden) {
        imageSize = CGSizeZero;
    }
    if (self.autoAdjustButtonWidth) {
        CGRect frame = self.frame;
        frame.size.width = labelSize.width + imageSize.width + 2 < self.maxWidth ? labelSize.width + imageSize.width : self.maxWidth;
        self.frame = frame;
    }
    
    //CGFloat labelWidth = MIN(labelSize.width, self.titleLabel.frame.size.width);
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageSize.width - 2, 0, imageSize.width + 2)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, labelSize.width, 0, -labelSize.width)];
}

- (void)setArrowHidden:(BOOL)arrowHidden
{
    _arrowHidden = arrowHidden;
    
    if (_arrowHidden) {
        [self setImage:nil forState:UIControlStateNormal];
        [self setTitle:self.titleLabel.text forState:UIControlStateNormal];
    }
}

@end
