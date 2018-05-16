//
//  JCHClientDetailAnalyseManifestCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHClientDetailAnalyseManifestCellData : NSObject

@property (nonatomic, assign) NSInteger manifestType;
@property (nonatomic, retain) NSString *manifestID;
@property (nonatomic, retain) NSString *manifestOperator;
@property (nonatomic, assign) NSInteger manifestTimeInterval;
@property (nonatomic, retain) NSString *manifestRemark;
@property (nonatomic, assign) CGFloat amount;
@property (nonatomic, assign) CGFloat profitAmount;
@property (nonatomic, assign) CGFloat profitRate;
@property (nonatomic, assign) BOOL isManifestReturned;
@property (nonatomic, assign) BOOL hasPayed;

@end

@interface JCHClientDetailAnalyseManifestCell : JCHBaseTableViewCell

- (void)setViewData:(JCHClientDetailAnalyseManifestCellData *)data;

@end
