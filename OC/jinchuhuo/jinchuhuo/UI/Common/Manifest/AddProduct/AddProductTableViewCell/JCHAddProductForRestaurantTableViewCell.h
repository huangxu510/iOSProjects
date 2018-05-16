//
//  JCHAddProductForRestaurantTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 2017/2/21.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHAddProductTableViewCell.h"

@class JCHAddProductForRestaurantTableViewCell;
@protocol JCHAddProductForRestaurantTableViewCellDelegate <NSObject>

- (void)handleRestaurantAddSKUDish:(JCHAddProductForRestaurantTableViewCell *)cell;
- (void)handleRestaurantIncreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID;
- (void)handleRestaurantDecreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID;
- (void)handleRestaurantMainUnitIncreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID;
- (void)handleRestaurantMainUnitDecreaseDishCount:(JCHAddProductForRestaurantTableViewCell *)cell unitUUID:(NSString *)unitUUID;

@end

@interface JCHAddProductForRestaurantTableViewCell : UITableViewCell

@property (assign, nonatomic, readwrite) id<JCHAddProductForRestaurantTableViewCellDelegate> delegate;
@property (assign, nonatomic, readwrite) CGFloat pullDownCellHeight;
@property (assign, nonatomic, readwrite) CGFloat normalCellHeight;

@property (assign, nonatomic, readwrite) NSInteger addProductListStyle;
@property (copy, nonatomic) void(^tapBlock)(JCHAddProductForRestaurantTableViewCell *cell);

- (void)setCellData:(JCHAddProductTableViewCellData *)cellData;


@end
