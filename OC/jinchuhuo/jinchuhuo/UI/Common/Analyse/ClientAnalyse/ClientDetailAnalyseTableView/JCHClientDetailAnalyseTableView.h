//
//  JCHClientDetailAnalyseTableView.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"

@protocol JCHClientDetailAnalyseTableViewDelegate <NSObject>

- (void)handlePushToManifestDetail:(ManifestRecord4Cocoa *)manifestRecord;

@end

@interface JCHClientDetailAnalyseTableView : UIView


@property (nonatomic, assign) id<JCHClientDetailAnalyseTableViewDelegate> delegate;
@property (nonatomic, retain) NSArray *manifestDataSource;
@property (nonatomic, retain) NSArray *productCategoryDataSource;
@property (nonatomic, retain) NSArray *productNameDataSource;

//! @brief isReturned表示是否时退货单
- (instancetype)initWithFrame:(CGRect)frame isReturned:(BOOL)isReturned;

- (void)reloadData;

@end
