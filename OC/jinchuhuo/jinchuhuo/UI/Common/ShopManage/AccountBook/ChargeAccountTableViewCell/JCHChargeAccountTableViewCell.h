//
//  JCHChargeAccountTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHChargeAccountTableViewCellData : NSObject

@property (nonatomic, assign) CGFloat debtAmount;
@property (nonatomic, retain) NSString *memberName;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, assign) NSInteger count;

@end

@interface JCHChargeAccountTableViewCell : JCHBaseTableViewCell

- (void)setCellData:(JCHChargeAccountTableViewCellData *)data;

@end
