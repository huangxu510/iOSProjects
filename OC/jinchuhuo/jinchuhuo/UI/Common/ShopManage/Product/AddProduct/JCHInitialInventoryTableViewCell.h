//
//  JCHInitialInventoryTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHInitialInventoryTableViewCellData : NSObject

@property (nonatomic, retain) NSString *skuTypeName;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *productPrice;

@end

@interface JCHInitialInventoryTableViewCell : JCHBaseTableViewCell

@end
