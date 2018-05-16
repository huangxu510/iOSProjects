//
//  JCHShopAssistantTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBaseTableViewCell.h"

@class JCHShopAssistantCollectionViewCell;

@protocol JCHShopAssistantTableViewCellDelegate <NSObject>

- (void)handleAddShopAssistant;
- (void)handleShowAssistantInfo:(NSInteger)index;

@end

@interface JCHShopAssistantCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) id <JCHShopAssistantTableViewCellDelegate> cellDelegate;
- (void)setData:(NSArray *)data;

@end
