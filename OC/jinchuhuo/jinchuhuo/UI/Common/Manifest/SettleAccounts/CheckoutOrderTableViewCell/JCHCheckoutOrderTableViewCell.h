//
//  JCHCheckoutOrderTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHCheckoutOrderTableViewCellData : NSObject

@property (nonatomic, retain) NSString *titleName;
@property (nonatomic, retain) NSString *centerContent;
@property (nonatomic, retain) NSString *value;

@end

@class JCHCheckoutOrderTableViewCell;
@protocol JCHCheckoutOrderTableViewCellDelegate <NSObject>

- (void)handleDeleteItem:(JCHCheckoutOrderTableViewCell *)cell;

@end

@interface JCHCheckoutOrderTableViewCell : JCHBaseTableViewCell

@property (nonatomic, assign) id <JCHCheckoutOrderTableViewCellDelegate> delegate;
- (void)setCellData:(JCHCheckoutOrderTableViewCellData *)data;
- (void)setDeleteButtonHidden:(BOOL)hidden;
@end
