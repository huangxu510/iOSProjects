//
//  JCHClientDetailAnalyseCategoryCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHClientDetailAnalyseCategoryCellData : NSObject

@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *categoryCount;
@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, assign) CGFloat profitAmount;
@property (nonatomic, assign) CGFloat profitRate;

@end

@interface JCHClientDetailAnalyseCategoryCell : JCHBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                   isReturned:(BOOL)isReturned;

- (void)setViewData:(JCHClientDetailAnalyseCategoryCellData *)data;

@end
