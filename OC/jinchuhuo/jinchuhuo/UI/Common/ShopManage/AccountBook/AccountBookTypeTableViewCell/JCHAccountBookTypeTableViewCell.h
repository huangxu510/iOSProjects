//
//  JCHAccountBookTypeTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHAccountBookTypeTableViewCellData : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSString *imageName;

@end

@interface JCHAccountBookTypeTableViewCell : JCHBaseTableViewCell

- (void)setViewData:(JCHAccountBookTypeTableViewCellData *)data;

@end
