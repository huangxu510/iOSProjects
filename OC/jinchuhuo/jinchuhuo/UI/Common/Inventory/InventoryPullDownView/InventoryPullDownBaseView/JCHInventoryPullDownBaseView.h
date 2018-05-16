//
//  JCHInventoryPullDownBaseView.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHInventoryTableViewSectionView.h"

@class JCHInventoryPullDownBaseView;
@protocol JCHInventoryPullDownBaseViewDelegate <NSObject>

@optional

- (void)filteredSKUValueUUIDArray:(NSArray *)filteredSKUValueUUIDArray;
- (void)pullDownView:(JCHInventoryPullDownBaseView *)view buttonSelected:(NSInteger)buttonTag;
- (void)selectedRow:(NSInteger)row buttonTag:(NSInteger)tag;

@end

@interface JCHInventoryPullDownBaseView : UIView

@property (nonatomic, assign) id <JCHInventoryPullDownBaseViewDelegate> delegate;
@property (nonatomic, assign) CGFloat maxHeight;
- (void)setData:(NSArray *)data;
- (void)clearOption;

@end
