//
//  JCHSKUSelectTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/6/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "SKURecord4Cocoa.h"

@interface JCHSKUSelectTableViewCell : JCHBaseTableViewCell

@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, retain) NSArray *selectedSKUValueRecordArray;
@property (nonatomic, copy) void(^buttonSelectBlock)(SKUValueRecord4Cocoa *record);
@property (nonatomic, copy) BOOL(^buttonDeslectBlock)(SKUValueRecord4Cocoa *record, UIButton *button);
@property (nonatomic, copy) void(^addSKUValueBlock)(NSString *skuTypeName);

- (void)setCellData:(NSDictionary *)skuDict;
- (CGFloat)calculateHeightWithData:(NSDictionary *)skuDict;
@end
