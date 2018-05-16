//
//  JCHTakeoutPutawayTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHTakeoutPutawayTableViewCellData : NSObject

@property (retain, nonatomic) NSString *skuName;
@property (retain, nonatomic) NSString *skuID;
@property (assign, nonatomic) CGFloat skuLocalPrice;
@property (assign, nonatomic) BOOL status;
@property (retain, nonatomic) NSString *skuTakeoutInventory;
@property (retain, nonatomic) NSString *skuTakeoutPrice;
@property (assign, nonatomic) NSInteger boxNum;
@property (assign, nonatomic) CGFloat boxPrice;

@end

@interface JCHTakeoutPutawayTableViewCell : JCHBaseTableViewCell

@property (copy, nonatomic) void(^selectBlock)(BOOL selected);

- (void)setViewData:(JCHTakeoutPutawayTableViewCellData *)data;

@end
