//
//  JCHSpecificationSelectTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "SKURecord4Cocoa.h"

@class JCHSpecificationSelectTableViewCell;
@protocol JCHSpecificationSelectTableViewCellDelegate <NSObject>

- (void)cellEndEditing:(JCHSpecificationSelectTableViewCell *)cell;
- (BOOL)unselectSKUValue:(JCHSpecificationSelectTableViewCell *)cell buttonTag:(NSInteger)tag;

@end

@interface JCHSpecificationSelectTableViewCell : UITableViewCell

@property (nonatomic, assign) id <JCHSpecificationSelectTableViewCellDelegate> delegate;
@property (nonatomic, assign) CGFloat buttonContainerViewHeight;
@property (nonatomic, retain) NSArray *selectedData;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, assign) NSInteger row;

- (void)setButtonData:(NSDictionary *)data;
@end
