//
//  JCHSavingCardJournalCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHSavingCardJournalCellData : NSObject

@property (nonatomic, retain) NSString *headImageName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, assign) CGFloat totalAmount;

@end

@interface JCHSavingCardJournalCell : JCHBaseTableViewCell

- (void)setCellData:(JCHSavingCardJournalCellData *)data;

@end
