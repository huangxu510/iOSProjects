//
//  JCHRestaurantSKUItemCollectionCell.h
//  jinchuhuo
//
//  Created by apple on 2017/1/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHRestaurantSKUItemCollectionCellData : NSObject

@property (retain, nonatomic, readwrite) NSString *skuItemName;
@property (assign, nonatomic, readwrite) BOOL isSelected;

@end

@class JCHRestaurantSKUItemCollectionCell;
@protocol JCHRestaurantSKUItemCollectionCellDelegate <NSObject>

- (void)handleCellClick:(JCHRestaurantSKUItemCollectionCell *)cell;

@end

@interface JCHRestaurantSKUItemCollectionCell : UICollectionViewCell

@property (assign, nonatomic, readwrite) id<JCHRestaurantSKUItemCollectionCellDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)setSelected:(BOOL)isSelected;
- (void)setCellData:(JCHRestaurantSKUItemCollectionCellData *)data;

@end
