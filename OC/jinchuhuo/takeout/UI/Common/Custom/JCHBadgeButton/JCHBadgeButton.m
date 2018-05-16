//
//  JCHBadgeButton.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHBadgeButton.h"
#import <JSBadgeView.h>

@interface JCHBadgeButton ()

@property (nonatomic, retain) JSBadgeView *badgeView;

@end

@implementation JCHBadgeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.badgeView = [[[JSBadgeView alloc] initWithParentView:self.imageView alignment:JSBadgeViewAlignmentTopRight] autorelease];
        self.imageView.clipsToBounds = NO;
    }
    return self;
}

- (void)dealloc
{
    self.badgeTextColor = nil;
    self.badgeTextFont = nil;
    self.badgeBackgroundColor = nil;
    
    [super dealloc];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
#if 1
    CGFloat imageHeight = 0;
    CGFloat imageWidth = 0;
    if (self.currentImage) {
        imageHeight = self.currentImage.size.height;
        imageWidth = self.currentImage.size.width;
    }
    CGFloat x = (contentRect.size.width - imageWidth) / 2;
    CGFloat y = (contentRect.size.height * 3 / 4 - imageHeight) / 2 + self.imageViewVerticalOffset;
    CGFloat height = imageHeight;
    CGFloat width = imageWidth;

    return CGRectMake(x, y, width, height);
#else
    CGFloat x = 0;
    CGFloat y = 1 + self.imageViewVerticalOffset;
    CGFloat height = contentRect.size.height * 3 / 4;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
#endif
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = contentRect.size.height * 5 / 7 + self.labelVerticalOffset;
    CGFloat height = contentRect.size.height / 4;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
}

- (void)setBadgeValue:(NSInteger)badgeValue
{
    if (_badgeValue != badgeValue) {
        _badgeValue = badgeValue;
        self.badgeView.badgeText = [NSString stringWithFormat:@"%ld", badgeValue];
        if (badgeValue == 0) {
            self.badgeView.hidden = YES;
        } else {
            self.badgeView.hidden = NO;
        }
    }
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    if (_badgeTextColor != badgeTextColor) {
        [_badgeTextColor release];
        _badgeTextColor = [badgeTextColor retain];
        
        self.badgeView.badgeTextColor = badgeTextColor;
    }
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont
{
    if (_badgeTextFont != badgeTextFont) {
        [_badgeTextFont release];
        _badgeTextFont = [badgeTextFont retain];
        
        self.badgeView.badgeTextFont = badgeTextFont;
    }
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor
{
    if (_badgeBackgroundColor != badgeBackgroundColor) {
        [_badgeBackgroundColor release];
        _badgeBackgroundColor = [badgeBackgroundColor retain];
        
        self.badgeView.badgeBackgroundColor = badgeBackgroundColor;
    }
}

@end
