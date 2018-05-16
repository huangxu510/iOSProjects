//
//  JCHShopAssistantInfoTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, JCHShopMarkType)
{
    kJCHShopMarkTypeShopkeeper,
    kJCHShopMarkTypeShopAssistant,
};

@interface JCHShopAssistantInfoTableViewCell : JCHBaseTableViewCell

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *detailLabel;

- (void)setMarkLabelType:(JCHShopMarkType)type hidden:(BOOL)hidden;

@end
