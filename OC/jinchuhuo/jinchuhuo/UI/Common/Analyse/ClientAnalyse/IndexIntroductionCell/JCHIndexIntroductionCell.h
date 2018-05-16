//
//  JCHIndexIntroductionCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHIndexIntroductionCellData : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, assign) CGFloat maxCellHeight;
@property (nonatomic, assign, getter=isShow) BOOL show;

@end

@interface JCHIndexIntroductionCell : JCHBaseTableViewCell

- (void)setViewData:(JCHIndexIntroductionCellData *)data;
- (void)setDetailLabelHidden:(BOOL)hidden;

@end
