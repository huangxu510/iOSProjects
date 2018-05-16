//
//  MTRowIndexView.m
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import "MTRowIndexView.h"
#import "MTSeatButton.h"
#import "UIView+Extension.h"
#import "MTSeatSelectionView.h"
#import "UIColor+Hex.h"

@implementation MTRowIndexView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithHex:0xffffff];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat labelHeight = (self.height - 2 * kMTSmallMargin - (self.indexesArray.count - 1) * kMTSeatVerticalSpacing * self.scale) / self.indexesArray.count;
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        UILabel *label = self.subviews[i];
        label.frame = CGRectIntegral(CGRectMake(0, kMTSmallMargin + (kMTSeatVerticalSpacing * self.scale + labelHeight) * i, self.width, labelHeight));
    }
}

- (void)setHeight:(CGFloat)height {
    [super setHeight:height];
    
    [self setNeedsLayout];
}

- (void)setIndexesArray:(NSMutableArray *)indexesArray {
    
    _indexesArray = indexesArray;
    
    [self addIndexLabel];
}

- (void)addIndexLabel
{
    CGFloat labelHeight = (self.height - 2 * kMTSmallMargin - (self.indexesArray.count - 1) * kMTSeatVerticalSpacing * self.scale) / self.indexesArray.count;
    for (NSInteger i = 0; i < self.indexesArray.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = self.indexesArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:11];
        label.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
        label.frame = CGRectMake(0, kMTSmallMargin + (kMTSeatVerticalSpacing * self.scale + labelHeight) * i, self.width, labelHeight);
        label.tag = i;
        [self addSubview:label];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
    }
}

- (void)labelTaped:(UITapGestureRecognizer *)tap
{
    UIView *senderView = tap.view;
    if (self.labelTapAction) {
        self.labelTapAction(senderView.tag);
    }
}

//画索引条
//- (void)drawRect:(CGRect)rect {
//    
//    NSDictionary *attributeName = @{NSFontAttributeName: [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : [UIColor whiteColor]};
//    
//    CGFloat NuomberTitleH = (self.height - 2 * kMTSmallMargin - (self.indexesArray.count - 1) * kMTSeatVerticalSpacing) / self.indexesArray.count;
//    
//    [self.indexesArray enumerateObjectsUsingBlock:^(NSString *roomNumber, NSUInteger idx, BOOL *stop) {
//        
//        CGSize strsize =  [roomNumber sizeWithAttributes:attributeName];
//        
//        [roomNumber drawAtPoint:CGPointMake(self.width * 0.5 - strsize.width  * 0.5,10 + idx * (NuomberTitleH + kMTSeatVerticalSpacing) + NuomberTitleH  * 0.5 - strsize.height  * 0.5) withAttributes:attributeName];
//        
//    }];
//}


@end
