//
//  JCHSavingCardTransactionDetailsTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHSavingCardTransactionDetailsTableViewCellData : NSObject

@property (nonatomic, assign) NSInteger transactionType;
@property (nonatomic, assign) time_t transactionTimestamp;
@property (nonatomic, assign) CGFloat amount;

@end

@interface JCHSavingCardTransactionDetailsTableViewCell : JCHBaseTableViewCell

- (void)setCellData:(JCHSavingCardTransactionDetailsTableViewCellData *)data;

@end
