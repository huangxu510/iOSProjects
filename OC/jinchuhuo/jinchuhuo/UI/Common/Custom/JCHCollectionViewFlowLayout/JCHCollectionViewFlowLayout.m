//
//  JCHCollectionViewFlowLayout.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCollectionViewFlowLayout.h"

@implementation JCHCollectionViewFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for(int i = 1; i < [attributes count]; ++i) {
        //当前attributes
        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
        //上一个attributes
        UICollectionViewLayoutAttributes *prevLayoutAttributes = attributes[i - 1];
        
        //前一个cell的最右边
        CGFloat origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        //如果当前一个cell的最右边加上我们想要的间距加上当前cell的宽度依然在contentSize中，我们改变当前cell的原点位置
        //不加这个判断的后果是，UICollectionView只显示一行，原因是下面所有cell的x值都被加到第一行最后一个元素的后面了
        if(origin + self.maxInteritemSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + self.maxInteritemSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return attributes;
}

@end

