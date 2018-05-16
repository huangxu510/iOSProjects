//
//  JCHJournalAccountTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "JCHManifestType.h"
#import "JCHMutipleSelectedTableViewCell.h"

@interface JCHJournalAccountTableViewCellData : NSObject

@property (nonatomic, assign) time_t manifestTimestamp;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) NSInteger manifestType;
@property (nonatomic, retain) NSString *manifestID;
@property (nonatomic, retain) NSString *manifestDescription;

@end

@interface JCHJournalAccountTableViewCell : JCHMutipleSelectedTableViewCell

- (void)setCellData:(JCHJournalAccountTableViewCellData *)data;

@end
