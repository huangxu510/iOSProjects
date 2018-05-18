//
//  BKBaseViewController.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "BKTableView.h"

@interface BKBaseViewController : UIViewController

@property (nonatomic, strong) BKTableView *tableView;

/**
 *  是否显示返回按钮,默认情况是YES
 */
@property (nonatomic, assign) BOOL isShowBackButton;

- (void)loadData;

- (void)headerRefreshing;

- (void)footerRefreshing;

@end
