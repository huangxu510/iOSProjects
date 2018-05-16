//
//  JCHSoldOutTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "JCHAddProductTableViewCell.h"

typedef void(^HandleClickDishSoldOut)(BOOL, NSInteger);

@interface JCHSoldOutTableViewCell : JCHBaseTableViewCell

@property (copy, nonatomic, readwrite) HandleClickDishSoldOut handleClickEvent;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setCellData:(JCHAddProductTableViewCellData *)cellData cellIndex:(NSInteger)cellIndex;

@end
