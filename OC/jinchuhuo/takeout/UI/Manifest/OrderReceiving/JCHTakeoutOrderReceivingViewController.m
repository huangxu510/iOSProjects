//
//  JCHTakeoutOrderReceivingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingViewController.h"
#import "JCHTakeoutOrderReceivingChildViewController.h"
#import "JCHTakeoutOrderCancelViewController.h"
#import "JCHTakeoutOrderReceivingTableViewCell.h"
#import "JCHSwitchLabelView.h"
#import "CommonHeader.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "JCHTakeoutOrderInfoModel.h"
#import <NSObject+YYModel.h>
#import "JCHBadgeButton.h"


#define kLoadMoreDataLimit 10

@interface JCHTakeoutOrderReceivingViewController () <UIScrollViewDelegate, JCHTakeoutOrderReceivingChildViewControllerDelegate>
{
    UIView *_indexView;
    UIScrollView *_orderListContainerScrollView;
}
@property (retain, nonatomic) JCHBadgeButton *selectedButton;
@property (retain, nonatomic) NSArray *orderCategoryButtons;
@property (assign, nonatomic) CGFloat indexViewOriginalX;
@property (retain, nonatomic) NSArray *orderSubfieldTypeList;
@property (retain, nonatomic) JCHTakeoutOrderReceivingChildViewController *currentChildViewController;
@end

@implementation JCHTakeoutOrderReceivingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"外卖接单";
        self.orderSubfieldTypeList = @[@(kJCHTakeoutOrderSubfieldTypeNew),
                                       @(kJCHTakeoutOrderSubfieldTypeToBeDelivery),
                                       @(kJCHTakeoutOrderSubfieldTypeDelivering),
                                       @(kJCHTakeoutOrderSubfieldTypeRefunding),
                                       @(kJCHTakeoutOrderSubfieldTypeRefunded)];
        
        [self registerResponseNotificationHandler];
    }
    return self;
}

- (void)dealloc
{
    self.selectedButton = nil;
    self.orderCategoryButtons = nil;
    self.orderSubfieldTypeList = nil;
    self.currentChildViewController = nil;
    [self unregisterResponseNotificationHandler];
    
    
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSInteger index = [self.orderCategoryButtons indexOfObject:self.selectedButton];
//    self.currentChildViewController = self.childViewControllers[index];;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    CGFloat topViewHeight = 70;
    
    UIView *topContainerView = [[[UIView alloc] init] autorelease];
    topContainerView.backgroundColor = JCHColorHeaderBackground;
    [self.view addSubview:topContainerView];
    
    [topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(topViewHeight);
    }];
    
    _orderListContainerScrollView = [[[UIScrollView alloc] init] autorelease];
    _orderListContainerScrollView.pagingEnabled = YES;
    _orderListContainerScrollView.delegate = self;
    _orderListContainerScrollView.showsHorizontalScrollIndicator = NO;
    _orderListContainerScrollView.bounces = NO;
    [self.view addSubview:_orderListContainerScrollView];
    
    [_orderListContainerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContainerView.mas_bottom);
        make.left.width.bottom.equalTo(self.view);
    }];
    
    NSArray *titleArray = @[@"新订单", @"待配送", @"配送中", @"退款"];
    NSArray *imageArray = @[@"icon_takeout_new_normal", @"icon_takeout_waiting_normal", @"icon_takeout_transit_normal", @"icon_takeout_refund_normal"];
    NSArray *imageSelectedArray = @[@"icon_takeout_new_selected", @"icon_takeout_waiting_selected", @"icon_takeout_transit_selected", @"icon_takeout_refund_selected"];
    
    CGFloat buttonWidth = kScreenWidth / 4;
    
    NSMutableArray *orderCategoryButtons = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        JCHBadgeButton *button = [JCHBadgeButton buttonWithType:UIButtonTypeCustom];
        button.badgeTextColor = JCHColorHeaderBackground;
        button.badgeBackgroundColor = [UIColor whiteColor];
        button.badgeTextFont = JCHFont(11);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imageSelectedArray[i]] forState:UIControlStateSelected];
        [topContainerView addSubview:button];
        button.tag = i;
        [button addTarget:self action:@selector(handleSelectOrderType:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect frame = CGRectMake(buttonWidth * i, 0, buttonWidth, topViewHeight);
        button.frame = frame;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.imageView.contentMode = UIViewContentModeCenter;
        button.titleLabel.font = JCHFont(10);
        button.imageViewVerticalOffset = -5;
        button.labelVerticalOffset = -7;
        button.adjustsImageWhenHighlighted = NO;
        [orderCategoryButtons addObject:button];
        
        
        NSString *footerTitle = nil;
        if (i == 3) {
            footerTitle = @"已处理退款";
        }
        JCHTakeoutOrderReceivingChildViewController *childVC = [[[JCHTakeoutOrderReceivingChildViewController alloc] initWithFooter:footerTitle] autorelease];
        childVC.delegate = self;
        childVC.index = i;
        [self addChildViewController:childVC];
        
        CGRect viewframe = _orderListContainerScrollView.bounds;
        viewframe.origin.x = kScreenWidth * i;
        childVC.view.frame = viewframe;
        
        [_orderListContainerScrollView addSubview:childVC.view];
        
        [self queryOrderList:[self.orderSubfieldTypeList[i] integerValue] viewController:childVC];
        
        if (i == 0) {
            button.selected = YES;
            self.selectedButton = button;
            self.currentChildViewController = [self.childViewControllers firstObject];
            CGFloat indexViewWidth = 30;
            CGFloat indexViewHeight = 3;
            _indexView = [[[UIView alloc] init] autorelease];
            _indexView.backgroundColor = [UIColor whiteColor];
            _indexView.layer.cornerRadius = 2;
            _indexView.frame = CGRectMake(kScreenWidth / 4 / 2 - indexViewWidth / 2, topViewHeight - indexViewHeight, indexViewWidth, indexViewHeight);
            [topContainerView addSubview:_indexView];
            
            self.indexViewOriginalX = _indexView.frame.origin.x;
        }
    }
    
    self.orderCategoryButtons = orderCategoryButtons;
    
    _orderListContainerScrollView.contentSize = CGSizeMake(kScreenWidth * 4, 0);
}

#pragma mark - LoadData
- (void)queryOrderList:(JCHTakeoutOrderSubfieldType)subfieldType
        viewController:(JCHTakeoutOrderReceivingChildViewController *)viewController
{
    [self queryOrderList:subfieldType offset:0 limit:0 viewController:viewController];
}

- (void)queryOrderList:(JCHTakeoutOrderSubfieldType)subfieldType
                offset:(NSInteger)offset
                 limit:(NSInteger)limit
        viewController:(JCHTakeoutOrderReceivingChildViewController *)viewController
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutOrderService = [[ServiceFactory sharedInstance] takeoutService];
    TakeOutQueryOrderRequest *request = [[[TakeOutQueryOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/query", kTakeoutServerIP];
    request.status = subfieldType;
    request.limit = limit;
    request.offset = offset;
    
    if (subfieldType == kJCHTakeoutOrderSubfieldTypeRefunded) {
        [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:viewController.view completion:nil];
    }
    
    [takeoutOrderService queryOrder:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:viewController.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:viewController.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
                
                NSArray *orders = responseData[@"data"][@"orders"];
                NSMutableArray *orderList = [NSMutableArray array];

                for (NSInteger i = 0; i < orders.count; i++) {
                    NSDictionary *orderInfoDict = orders[i];
                    JCHTakeoutOrderInfoModel *model = [JCHTakeoutOrderInfoModel modelWithDictionary:orderInfoDict];
                    [orderList addObject:model];
                }
                
                if (offset == 0) {
                    viewController.orderList = orderList;
                    [viewController reloadData:NO];
                    
                    if (viewController != self.currentChildViewController && viewController.index < 4) {
                        JCHBadgeButton *button = self.orderCategoryButtons[viewController.index];
                        button.badgeValue = orderList.count;
                    }
                } else {
                    NSMutableArray *totalOrderList = [NSMutableArray arrayWithArray:viewController.orderList];
                    [totalOrderList addObjectsFromArray:orderList];
                    viewController.orderList = totalOrderList;
                    
                    if (orderList.count == 0) {
                        [viewController reloadData:YES];
                    } else {
                        [viewController reloadData:NO];
                    }
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:viewController.view];
        }
    }];
}


#pragma mark - 顶部按钮事件
- (void)handleSelectOrderType:(JCHBadgeButton *)sender
{
    if (sender == self.selectedButton) {
        return;
    }
    
    sender.selected = !sender.selected;
    self.selectedButton.selected = !self.selectedButton.selected;
    self.selectedButton = sender;
    
    self.currentChildViewController = self.childViewControllers[sender.tag];
    
    CGFloat offsetX = sender.tag * kScreenWidth;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_orderListContainerScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    });
    
    
    CGRect indexViewFrame = _indexView.frame;
    indexViewFrame.origin.x = self.indexViewOriginalX + _orderListContainerScrollView.contentOffset.x / 3;
    _indexView.frame = indexViewFrame;
}

#pragma mark - UIScrollViewDelegate
// 滚动结束（手势导致)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / kScreenWidth);
    JCHTakeoutOrderReceivingChildViewController *childVC = self.childViewControllers[index];
    
    self.selectedButton.selected = NO;
    self.selectedButton = self.orderCategoryButtons[index];
    self.selectedButton.selected = YES;
    
    self.currentChildViewController = self.childViewControllers[index];
    
    // 按钮角标清零
    JCHBadgeButton *button = self.orderCategoryButtons[index];
    button.badgeValue = 0;
    
    if (![_orderListContainerScrollView.subviews containsObject:childVC.view]) {
        childVC.view.frame = scrollView.bounds;
        [_orderListContainerScrollView addSubview:childVC.view];
        JCHTakeoutOrderSubfieldType orderStatus = [self.orderSubfieldTypeList[index] integerValue];
        [self queryOrderList:orderStatus viewController:self.currentChildViewController];
    }
}

// 滚动结束（代码导致)
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / kScreenWidth);
    JCHTakeoutOrderReceivingChildViewController *childVC = self.childViewControllers[index];
    
    // 按钮角标清零
    JCHBadgeButton *button = self.orderCategoryButtons[index];
    button.badgeValue = 0;
    
    if (![_orderListContainerScrollView.subviews containsObject:childVC.view]) {
        childVC.view.frame = scrollView.bounds;
        [_orderListContainerScrollView addSubview:childVC.view];
        JCHTakeoutOrderSubfieldType orderStatus = [self.orderSubfieldTypeList[index] integerValue];
        [self queryOrderList:orderStatus viewController:self.currentChildViewController];
    }
}

//正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 取出绝对值 避免最左边往右拉时形变超过1
//    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    CGRect frame = _indexView.frame;
    frame.origin.x = self.indexViewOriginalX + scrollView.contentOffset.x / 4;
    _indexView.frame = frame;
}

#pragma mark - JCHTakeoutOrderReceivingChildViewControllerDelegate

// 下拉刷新
- (void)pullDownRefreshData:(JCHTakeoutOrderReceivingChildViewController *)viewController
{
    [self refreshCurrentViewController];
}

// 上拉加载
- (void)pullUpLoadMoreData:(JCHTakeoutOrderReceivingChildViewController *)viewController
{
    NSInteger currentIndex = self.currentChildViewController.index;
    JCHTakeoutOrderSubfieldType orderStatus = [self.orderSubfieldTypeList[currentIndex] integerValue];
    
    [self queryOrderList:orderStatus offset:viewController.orderList.count limit:kLoadMoreDataLimit viewController:viewController];
}


// 底部按钮事件
- (void)footerButtonAction:(JCHTakeoutOrderReceivingChildViewController *)viewController
{
    // 已处理退款
    if(viewController.index == 3) {
        JCHTakeoutOrderReceivingChildViewController *vc = [[[JCHTakeoutOrderReceivingChildViewController alloc] init] autorelease];
        vc.title = @"已处理退款";
        vc.index = 4;
        vc.delegate = self;
        vc.pullUpLoad = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.currentChildViewController = vc;
        JCHTakeoutOrderSubfieldType orderStatus = [self.orderSubfieldTypeList[vc.index] integerValue];
        [self queryOrderList:orderStatus offset:0 limit:kLoadMoreDataLimit viewController:vc];
    }
}


// 刷新当前页面
- (void)refreshCurrentViewController
{
    NSInteger currentIndex = self.currentChildViewController.index;
    JCHTakeoutOrderSubfieldType orderStatus = [self.orderSubfieldTypeList[currentIndex] integerValue];
    
    if (currentIndex == 4) {
        [self queryOrderList:orderStatus offset:0 limit:kLoadMoreDataLimit viewController:self.currentChildViewController];
    } else {
        [self queryOrderList:orderStatus viewController:self.currentChildViewController];
    }
}

// 刷新指定页面
- (void)refreshViewController:(NSInteger)index
{
    if (index >= self.childViewControllers.count) {
        return;
    }
    
    JCHTakeoutOrderReceivingChildViewController *childVC = self.childViewControllers[index];
    
    if (![_orderListContainerScrollView.subviews containsObject:childVC.view]) {
        return;
    }
    
    
    JCHTakeoutOrderSubfieldType orderStatus = [self.orderSubfieldTypeList[index] integerValue];
    
    JCHTakeoutOrderReceivingChildViewController *viewController = self.childViewControllers[index];
    if (index == 4) {
        [self queryOrderList:orderStatus offset:0 limit:kLoadMoreDataLimit viewController:viewController];
    } else {
        [self queryOrderList:orderStatus viewController:viewController];
    }
}


#pragma mark - 当前页面收到推送
- (void)handleReceivePush:(NSNotification *)notify
{
    NSDictionary *userInfo = notify.userInfo;
    NSLog(@"userInfo = %@", userInfo);
    NSString *method = userInfo[@"method"];
    
    if ([method isEqualToString:@"orderStatus"] || [method isEqualToString:@"orderShipping"]) {
        // 订单状态的推送
        JCHTakeoutOrderSubfieldType clientStatus = [userInfo[@"clientStatus"] integerValue];
        JCHTakeoutOrderSubfieldType oldClientStatus = [userInfo[@"oldClientStatus"] integerValue];
        
        if (clientStatus >= 0 && clientStatus <= 4) {
            [self refreshViewController:clientStatus];
        }
        if (clientStatus != oldClientStatus && oldClientStatus >= 0 && oldClientStatus <= 4) {
            [self refreshViewController:oldClientStatus];
        }
        
        // 当收到退单完成推送，要刷新已完成退单页面
        if (self.currentChildViewController.index == 4 && clientStatus == kJCHTakeoutOrderSubfieldTypeBacked) {
            [self refreshViewController:4];
        }
    }
}


- (void)registerResponseNotificationHandler
{
    [JCHNotificationCenter addObserver:self selector:@selector(handleReceivePush:) name:kTakeoutServerPushNotification object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self name:kTakeoutServerPushNotification object:[UIApplication sharedApplication]];
}

- (void)handleApplicationWillEnterForeground
{
    [super handleApplicationWillEnterForeground];
    
    [self refreshCurrentViewController];
}

@end
