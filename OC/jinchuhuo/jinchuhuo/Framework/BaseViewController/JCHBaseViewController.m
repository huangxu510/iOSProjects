//
//  JCHBaseViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHBaseViewController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>


@end


@implementation JCHBaseViewController 


- (id)init
{
    self = [super init];
    if (self) {
        // pass
        self.refreshUIAfterAutoSync = NO;
        self.isNeedReloadAllData = YES;
        
        [self registerBaseResponseNotificationHandler];
    }

    return self;
}

- (void)dealloc
{
    [self unregisterBaseResponseNotificationHandler];
    [_backgroundScrollView removeObserver:self forKeyPath:@"contentSize"];
    
    self.backgroundScrollView = nil;
    self.tableView = nil;

    [super dealloc];
    return;
}

#if 0
- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    viewFrame.origin = CGPointMake(0.0f, 0.0f);
    self.view = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    
    return;
}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ( systemVersion >= 7.0 && systemVersion <8.0){
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    _backBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(handlePopAction)] autorelease];
    self.navigationItem.leftBarButtonItem = _backBtn;
    
    //屏幕左边缘右滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(handleAutoSyncRefreshData:)
                          name:kAutoSyncCompleteNotification
                        object:[UIApplication sharedApplication]];
    
    
    return;
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:kAutoSyncCompleteNotification
                           object:[UIApplication sharedApplication]];
    
    [super viewDidDisappear:animated];
    
    return;
}

- (void)handleAutoSyncRefreshData:(NSNotification *)notify
{
    if ([self respondsToSelector:@selector(loadData)]) {
        if (YES == self.refreshUIAfterAutoSync) {
            [self performSelector:@selector(loadData)];
        }
    }
}

- (void)loadData
{
    return;
}

- (void)handlePopAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = JCHColorGlobalBackground;
        [self.view addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _tableView;
}

- (UIScrollView *)backgroundScrollView
{
    if (_backgroundScrollView == nil) {
        
        _backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        
        [_backgroundScrollView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        [self.view addSubview:_backgroundScrollView];
        
        [_backgroundScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
    }
    return _backgroundScrollView;
}

//- (void)setBackgroundScrollView:(UIScrollView *)backgroundScrollView
//{
//    UIScrollView *tempView = [backgroundScrollView retain];
//    [_backgroundScrollView release];
//    _backgroundScrollView = tempView;
//    
//    return;
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _backgroundScrollView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            
            NSValue *contentSizeValue = change[NSKeyValueChangeNewKey];
            NSValue *oldContentSizeValue = change[NSKeyValueChangeOldKey];
            
            CGSize contentSize;
            CGSize oldContentSize;
            [contentSizeValue getValue:&contentSize];
            [oldContentSizeValue getValue:&oldContentSize];
            
            if (contentSize.height < self.view.frame.size.height) {
                
                [_backgroundScrollView removeObserver:self forKeyPath:@"contentSize"];
                _backgroundScrollView.contentSize = CGSizeMake(0, kScreenHeight - 64 + 1);
                [_backgroundScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            }
        }
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    }
    return cell;
}

- (void)registerBaseResponseNotificationHandler
{
    //! @brief 应用回到前台的通知
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleApplicationWillEnterForeground)
                                  name:kJCHApplicationWillEnterForeground
                                object:[UIApplication sharedApplication]];
    
    //! @brief 编辑货单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshPartDataMark:)
                                  name:kManifestUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 添加进出货单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestInsertNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 退单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestReturnNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 删单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestDeleteNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 货单应收应付
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestARAPNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 储值卡充值
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestCardRechargeNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 储值卡退卡
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestCardReturnNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 盘点单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestCountingNotification
                                object:[UIApplication sharedApplication]];

    //! @brief 移库单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kManifestTransferNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 拼装单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kAddAssemblingManifestNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 拆装单
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kAddDismountingManifestNotification
                                object:[UIApplication sharedApplication]];
    
    
    //! @brief 添加商品
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kProductInsertNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 编辑商品
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kProductUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 删除商品
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kProductDeleteNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 添加分类
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kCategoryInsertNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 编辑分类
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kCategoryUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 删除分类
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kCategoryDeleteNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 添加单位
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kUnitInsertNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 编辑单位
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kUnitUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 删除单位
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kUnitDeleteNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 添加规格
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kSKUInsertNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 编辑规格
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kSKUUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 删除规格
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kSKUDeleteNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 同步完成拉到数据
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kChangeRefreshMarkAfterPullData
                                object:[UIApplication sharedApplication]];
    
    //! @brief 添加仓库
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kWarehouseAddNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 更新仓库
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kWarehouseUpdateNotification
                                object:[UIApplication sharedApplication]];
    
    //! @brief 删除仓库
    [JCHNotificationCenter addObserver:self
                              selector:@selector(handleChangeRefreshAllDataMark:)
                                  name:kWarehouseDeleteNotification
                                object:[UIApplication sharedApplication]];
}

- (void)unregisterBaseResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self];
}

- (void)handleChangeRefreshAllDataMark:(NSNotification *)notify
{
    [self handleNeedReloadAllData];
}


- (void)handleChangeRefreshPartDataMark:(NSNotification *)notifu
{
    [self handleNeedReloadPartData];
}


- (void)handleNeedReloadAllData
{
    self.isNeedReloadAllData = YES;
}

- (void)handleNeedReloadPartData
{
    
}

- (void)handleApplicationWillEnterForeground
{
    
}

@end
