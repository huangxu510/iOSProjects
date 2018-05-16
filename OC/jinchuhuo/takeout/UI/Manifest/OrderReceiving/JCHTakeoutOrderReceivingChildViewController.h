//
//  JCHTakeoutOrderReceivingChildViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHTakeoutOrderReceivingViewController.h"
#import "CommonHeader.h"

@class JCHTakeoutOrderReceivingChildViewController;
@protocol JCHTakeoutOrderReceivingChildViewControllerDelegate <NSObject>

- (void)pullDownRefreshData:(JCHTakeoutOrderReceivingChildViewController *)viewController;                                              // 下拉刷新
- (void)pullUpLoadMoreData:(JCHTakeoutOrderReceivingChildViewController *)viewController;                                               // 上拉加载
- (void)footerButtonAction:(JCHTakeoutOrderReceivingChildViewController *)viewController;                                               // 底部按钮事件

@end

@interface JCHTakeoutOrderReceivingChildViewController : JCHBaseViewController

@property (assign, nonatomic) id<JCHTakeoutOrderReceivingChildViewControllerDelegate> delegate;
@property (retain, nonatomic) NSArray *orderList;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) BOOL pullUpLoad;

- (instancetype)initWithFooter:(NSString *)footerTitle;

- (void)reloadData:(BOOL)noMoreData;

@end
