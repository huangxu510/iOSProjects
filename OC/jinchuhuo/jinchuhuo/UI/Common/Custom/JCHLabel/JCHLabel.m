//
//  JCHLabel.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHLabel.h"

@implementation JCHLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.verticalAlignment = kVerticalAlignmentMiddle;
    }
    return self;
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment
{
    _verticalAlignment = verticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case kVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case kVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case kVerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:UIEdgeInsetsInsetRect(actualRect, self.textInset)];
}


@end
