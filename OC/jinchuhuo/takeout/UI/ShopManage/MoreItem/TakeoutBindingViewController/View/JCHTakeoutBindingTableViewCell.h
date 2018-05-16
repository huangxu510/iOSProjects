//
//  JCHTakeoutBindingTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHTakeoutBindingTableViewCellData : NSObject

@property (retain, nonatomic) NSString *imageName;
@property (retain, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL bindingStatus;

@end

@interface JCHTakeoutBindingTableViewCell : JCHBaseTableViewCell

@property (copy, nonatomic) dispatch_block_t bindingAction;

- (void)setCellData:(JCHTakeoutBindingTableViewCellData *)data;

@end
