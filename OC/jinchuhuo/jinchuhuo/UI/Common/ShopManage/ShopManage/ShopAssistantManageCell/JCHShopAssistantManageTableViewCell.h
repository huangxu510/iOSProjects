//
//  JCHShopAssistantManageTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHShopAssistantManageTableViewCellData : NSObject

@property (nonatomic, retain) NSString *headImageName;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, assign) BOOL status;

@end

@class JCHShopAssistantManageTableViewCell;
@protocol JCHShopAssistantManageTableViewCellDelegate <NSObject>

- (void)handleSwitchAction:(UISwitch *)statusSwitch inCell:(JCHShopAssistantManageTableViewCell *)cell;

@end

@interface JCHShopAssistantManageTableViewCell : JCHBaseTableViewCell

@property (nonatomic, assign) id<JCHShopAssistantManageTableViewCellDelegate> delegate;
- (void)setCellData:(JCHShopAssistantManageTableViewCellData *)data;

@end
