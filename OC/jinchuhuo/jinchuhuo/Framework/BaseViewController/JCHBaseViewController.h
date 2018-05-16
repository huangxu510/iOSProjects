//
//  JCHBaseViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JCHBaseViewController : UIViewController
{
    UIBarButtonItem *_backBtn;
//    UIScrollView *_backgroundScrollView;
}

@property (nonatomic, retain) UIScrollView *backgroundScrollView;
@property (nonatomic, retain) UITableView *tableView;
@property (assign, nonatomic, readwrite) BOOL refreshUIAfterAutoSync;

//! @brief 是否在viewWillAppear里面重新加载数据的标记
@property (nonatomic, assign) BOOL isNeedReloadAllData;

- (void)handleApplicationWillEnterForeground;

@end
