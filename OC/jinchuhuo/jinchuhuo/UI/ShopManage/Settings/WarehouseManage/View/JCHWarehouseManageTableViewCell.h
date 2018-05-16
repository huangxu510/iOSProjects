//
//  JCHWarehouseManageTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/10/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHWarehouseManageTableViewCellData : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) BOOL status;

@end

@interface JCHWarehouseManageTableViewCell : JCHBaseTableViewCell

@property (nonatomic, copy) void(^switchAction)(BOOL status);

- (void)setCellData:(JCHWarehouseManageTableViewCellData *)data;

@end
