//
//  JCHShopSelectTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/28.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHShopSelectTableViewCellData : NSObject

@property (nonatomic, retain) NSString *shopIconName;
@property (nonatomic, retain) NSString *shopName;
@property (nonatomic, retain) NSString *shopManagerName;
@property (nonatomic, assign) BOOL status;

@end

@interface JCHShopSelectTableViewCell : JCHBaseTableViewCell

- (void)setCellData:(JCHShopSelectTableViewCellData *)data;

@end
