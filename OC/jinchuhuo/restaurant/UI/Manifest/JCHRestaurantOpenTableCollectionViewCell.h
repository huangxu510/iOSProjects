//
//  JCHRestaurantOpenTableCollectionViewCell.h
//  jinchuhuo
//
//  Created by apple on 2017/1/3.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum JCHRestaurantOpenTableCollectionViewCellType
{
    kJCHRestaurantOpenTableCollectionViewCellAvaliable = 0, // 可选
    kJCHRestaurantOpenTableCollectionViewCellLock = 1,      // 锁定
    kJCHRestaurantOpenTableCollectionViewCellReserved = 2,  // 预订
    kJCHRestaurantOpenTableCollectionViewCellInUse = 3,     // 就餐中
};

@interface JCHRestaurantOpenTableCollectionViewCellData : NSObject

@property(retain, nonatomic, readwrite) NSString *tableName;
@property(retain, nonatomic, readwrite) NSString *regionName;
@property(assign, nonatomic, readwrite) NSInteger seatCount;
@property(assign, nonatomic, readwrite) NSInteger peopleCount;
@property(assign, nonatomic, readwrite) enum JCHRestaurantOpenTableCollectionViewCellType enumType;

@end

@interface JCHRestaurantOpenTableCollectionViewCell : UICollectionViewCell


- (id)initWithFrame:(CGRect)frame;
- (void)setCellData:(JCHRestaurantOpenTableCollectionViewCellData *)cellData;

@end
