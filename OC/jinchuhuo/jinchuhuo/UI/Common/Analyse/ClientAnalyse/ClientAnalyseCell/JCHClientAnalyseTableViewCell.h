//
//  JCHClientAnalyseTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, JCHClientAnalyseTableViewCellDataNumberType)
{
    kJCHClientAnalyseTableViewCellDataNumberTypeAmount,
    kJCHClientAnalyseTableViewCellDataNumberTypeCount,
    kJCHClientAnalyseTableViewCellDataNumberTypeRatio,
};

@interface JCHClientAnalyseTableViewCellData : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *customUUID;
@property (nonatomic, assign) CGFloat rightAmount;
@property (nonatomic, assign) CGFloat percentage;

//! @brief 数字类型
@property (nonatomic, assign) JCHClientAnalyseTableViewCellDataNumberType numberType;

//! @brief 退货类指标
@property (nonatomic, assign) BOOL isReturnedIndex;

@end

@interface JCHClientAnalyseTableViewCell : JCHBaseTableViewCell

- (void)setViewData:(JCHClientAnalyseTableViewCellData *)data;
- (void)startAnimation;

@end
