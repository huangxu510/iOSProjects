//
//  JCHAccountBookStatisticsView.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAccountBookStatisticsViewData : NSObject

@property (nonatomic, assign) CGFloat netAsset;  //净资产
@property (nonatomic, assign) CGFloat asset;    //资产
@property (nonatomic, assign) CGFloat debt;     //负债

@end

@protocol JCHAccountBookStatisticsViewDelegate <NSObject>

@optional
- (void)handleEditData;

@end

@interface JCHAccountBookStatisticsView : UIView

@property (nonatomic, retain) NSString *topTitle;
@property (nonatomic, retain) NSString *leftTitle;
@property (nonatomic, retain) NSString *rightTitle;
@property (nonatomic, assign) id <JCHAccountBookStatisticsViewDelegate> delegate;

- (void)setViewData:(JCHAccountBookStatisticsViewData *)data;
- (void)setEditDataButtonHiddeh:(BOOL)hidden;

@end
