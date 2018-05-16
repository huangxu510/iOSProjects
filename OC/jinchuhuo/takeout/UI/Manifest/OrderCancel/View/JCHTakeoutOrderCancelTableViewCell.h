//
//  JCHTakeoutOrderCancelTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHTakeoutOrderCancelTableViewCellData : NSObject

@property (retain, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger reasonCode;
@property (assign, nonatomic) BOOL selected;

@end

@interface JCHTakeoutOrderCancelTableViewCell : JCHBaseTableViewCell

- (void)setTitle:(NSString *)title;
- (void)setCellData:(JCHTakeoutOrderCancelTableViewCellData *)data;

@end
