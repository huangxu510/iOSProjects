//
//  JCHTakeoutOrderReceivingChildViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingChildViewController.h"
#import "JCHTakeoutOrderCancelViewController.h"
#import "JCHTakeoutOrderReceivingTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "CommonHeader.h"
#import <MJRefresh.h>

@interface JCHTakeoutOrderReceivingChildViewController () <UITableViewDataSource, UITableViewDelegate>
{
    JCHPlaceholderView *_placeholderView;
    UIButton *_footerButton;
}
@property (retain, nonatomic) NSMutableDictionary *detailDishExpandStatusForOrderID;
@property (retain, nonatomic) NSMutableDictionary *refundInfoExpandStatusForOrderID;
@property (retain, nonatomic) NSString *footerTitle;

@end

@implementation JCHTakeoutOrderReceivingChildViewController

- (instancetype)initWithFooter:(NSString *)footerTitle
{
    self.footerTitle = footerTitle;
    return [self init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.detailDishExpandStatusForOrderID = [NSMutableDictionary dictionary];
        self.refundInfoExpandStatusForOrderID = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.orderList = nil;
    self.detailDishExpandStatusForOrderID = nil;
    self.refundInfoExpandStatusForOrderID = nil;
    self.footerTitle = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.footerTitle) {
        _footerButton = [JCHUIFactory createButton:CGRectZero
                                            target:self
                                            action:@selector(handleFooterButtonAction)
                                             title:self.footerTitle
                                        titleColor:JCHColorAuxiliary
                                   backgroundColor:[UIColor whiteColor]];
        _footerButton.titleLabel.font = JCHFont(16);
        [self.view addSubview:_footerButton];
    }
    
    [self.tableView registerClass:[JCHTakeoutOrderReceivingTableViewCell class]
           forCellReuseIdentifier:@"JCHTakeoutOrderReceivingTableViewCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    WeakSelf;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(pullDownRefreshData:)]) {
            [weakSelf.delegate pullDownRefreshData:weakSelf];
        }
    }];
    [header setTitle:@"" forState:MJRefreshStateIdle];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_bill_placeholder"];
    _placeholderView.label.text = @"暂无订单";
    [self.tableView addSubview:_placeholderView];
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.tableView);
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (self.footerTitle) {
        [_footerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kStandardLeftMargin);
            make.right.equalTo(self.view).offset(-kStandardLeftMargin);
            make.bottom.equalTo(self.view).offset(-kStandardLeftMargin);
            make.height.mas_equalTo(40);
        }];
        
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.width.equalTo(self.view);
            make.bottom.equalTo(_footerButton.mas_top).offset(-kStandardLeftMargin);
        }];
    }
}

- (void)reloadData:(BOOL)noMoreData
{
    for (NSInteger i = 0; i < self.orderList.count; i++) {
        JCHTakeoutOrderInfoModel *model = self.orderList[i];
        [self.refundInfoExpandStatusForOrderID setObject:@(YES) forKey:model.orderId];
    }
    
    [self.tableView reloadData];
    
    if (self.tableView.mj_footer) {
        if (noMoreData) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    }
    
    [self.tableView.mj_header endRefreshing];
    if (self.orderList.count == 0) {
        _placeholderView.hidden = NO;
    } else {
        _placeholderView.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderReceivingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHTakeoutOrderReceivingTableViewCell" forIndexPath:indexPath];

    cell -> _bottomLine.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureCellData:cell indexPath:indexPath];
    
    return cell;
}

- (void)configureCellData:(JCHTakeoutOrderReceivingTableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    model.dishInfoExpanded = [self.detailDishExpandStatusForOrderID[model.orderId] boolValue];
    model.refundInfoExpanded = [self.refundInfoExpandStatusForOrderID[model.orderId] boolValue];
    
    [cell setCellData:model];
    
    WeakSelf;
    [cell setDetailDishExpandBlock:^(BOOL expanded) {
        [weakSelf handleExpandDishDetail:expanded indexPath:indexPath];
    }];
    
    [cell setRefundInfoExpandBlock:^(BOOL expanded) {
        [weakSelf handleExpandRefundInfo:expanded indexPath:indexPath];
    }];
    
    [cell setCallUpBlock:^{
        [weakSelf handleCallUp:indexPath];
    }];
    
    [cell setLeftButtonBlock:^{
        [weakSelf handleCancelOrder:indexPath];
    }];
    
    [cell setAgreeRefundBlock:^{
        [weakSelf handleAgreeRefund:indexPath];
    }];
    
    [cell setRejectRefundBlock:^{
        [weakSelf handleRejectRefund:indexPath];
    }];
    
    if (model.orderStatus == kJCHTakeoutOrderStatusNew) {
        // 未接单
        [cell setRightButtonBlock:^{
            [weakSelf handleReceiveOrder:indexPath];
        }];
    } else if (model.orderStatus == kJCHTakeoutOrderStatusToBeDelivery) {
        // 待配送
        [cell setRightButtonBlock:^{
            [weakSelf handleDelivery:indexPath];
        }];
    } else if (model.orderStatus == kJCHTakeoutOrderStatusDidStartDelivery) {
        // 配送中
        
        if (model.deliveryWay == 1001 || model.deliveryWay == 1002 || model.deliveryWay == 1004) {
            // 美团配送
            [cell setRightButtonBlock:^{
                [weakSelf handleCancelDelivery:indexPath];
            }];
        } else if (model.deliveryWay == 1003) {
            // 众包配送
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"暂不支持众包配送的订单" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        } else {
            // 自配送
            [cell setRightButtonBlock:^{
                [weakSelf handleCompleteDelivery:indexPath];
            }];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"JCHTakeoutOrderReceivingTableViewCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCellData:cell indexPath:indexPath];
    }];
}

- (void)handleExpandDishDetail:(BOOL)expanded indexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    [self.detailDishExpandStatusForOrderID setObject:@(expanded) forKey:model.orderId];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)handleExpandRefundInfo:(BOOL)expanded indexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    [self.refundInfoExpandStatusForOrderID setObject:@(expanded) forKey:model.orderId];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - 拨打电话
- (void)handleCallUp:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    NSString * str = [NSString stringWithFormat:@"telprompt://%@", model.recipientPhone];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}


#pragma mark -  取消订单
- (void)handleCancelOrder:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    JCHTakeoutOrderCancelViewController *viewController = [[[JCHTakeoutOrderCancelViewController alloc] initWithOrderID:model.orderId resource:[NSString stringWithFormat:@"%ld", model.resource]] autorelease];

    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 接单
- (void)handleReceiveOrder:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    id<TakeOutService> takeoutOrderService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    TakeOutConfirmOrderRequest *request = [[[TakeOutConfirmOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/confirm", kTakeoutServerIP];
    request.resource = [NSString stringWithFormat:@"%ld", model.resource];
    request.orderId = model.orderId;

    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    [takeoutOrderService confirmOrder:request callback:^(id response) {
        
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
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
    
    
}

#pragma mark - 配送
- (void)handleDelivery:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    DeliveryRequest *request = [[[DeliveryRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.resource = [NSString stringWithFormat:@"%ld", model.resource];
    request.orderId = model.orderId;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/delivering", kTakeoutServerIP];
    request.type = [NSString stringWithFormat:@"%ld", model.deliveryWay];
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService delivery:request callback:^(id response) {
        
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
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

#pragma mark - 取消配送
- (void)handleCancelDelivery:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    DeliveryCancelRequest *request = [[[DeliveryCancelRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.resource = [NSString stringWithFormat:@"%ld", model.resource];
    request.orderId = model.orderId;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/deliveringCancel", kTakeoutServerIP];
    request.type = [NSString stringWithFormat:@"%ld", model.deliveryWay];
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService deliveryCancel:request callback:^(id response) {
        
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
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

#pragma mark - 配送完成
- (void)handleCompleteDelivery:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    DeliveryCompleteRequest *request = [[[DeliveryCompleteRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.resource = [NSString stringWithFormat:@"%ld", model.resource];
    request.orderId = model.orderId;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/deliveringFinish", kTakeoutServerIP];
    request.type = [NSString stringWithFormat:@"%ld", model.deliveryWay];
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService deliveryComplete:request callback:^(id response) {
        
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
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

#pragma mark - 同意退款
- (void)handleAgreeRefund:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    AcceptRefundRequest *request = [[[AcceptRefundRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.resource = [NSString stringWithFormat:@"%ld", model.resource];
    request.orderId = model.orderId;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/agreeRefund", kTakeoutServerIP];

    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService acceptRefund:request callback:^(id response) {
        
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
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

#pragma mark - 拒绝退款
- (void)handleRejectRefund:(NSIndexPath *)indexPath
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"建议您优先联系用户协商处理，拒绝后若用户申诉通过，可能会影响您的排名" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"继续拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"拒绝原因" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"已和用户电话沟通" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleRejectRefundWithReason:@"已和用户电话沟通" indexPath:indexPath];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"菜已做正在配送中" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleRejectRefundWithReason:@"菜已做正在配送中" indexPath:indexPath];
        }];
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"质量服务没有问题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleRejectRefundWithReason:@"质量服务没有问题" indexPath:indexPath];
        }];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"用户已收餐" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleRejectRefundWithReason:@"用户已收餐" indexPath:indexPath];
        }];
        UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"其它" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController *reasonEditController = [UIAlertController alertControllerWithTitle:@"请输入原因" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [reasonEditController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
            }];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *textField = reasonEditController.textFields.firstObject;
                [self handleRejectRefundWithReason:textField.text indexPath:indexPath];
            }];
            [reasonEditController addAction:cancleAction];
            [reasonEditController addAction:confirmAction];
            
            [self presentViewController:reasonEditController animated:YES completion:nil];
        }];
        
        [actionSheetController addAction:action1];
        [actionSheetController addAction:action2];
        [actionSheetController addAction:action3];
        [actionSheetController addAction:action4];
        [actionSheetController addAction:action5];
        
        [self presentViewController:actionSheetController animated:YES completion:nil];
    }];
    
    [alertController addAction:cancleAction];
    [alertController addAction:rejectAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleRejectRefundWithReason:(NSString *)reason indexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderInfoModel *model = self.orderList[indexPath.row];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    RefuseRefundRequest *request = [[[RefuseRefundRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.resource = [NSString stringWithFormat:@"%ld", model.resource];
    request.orderId = model.orderId;
    request.reason = reason;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/rejectRefund", kTakeoutServerIP];
    
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    [takeoutService refuseRefund:request callback:^(id response) {
        
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
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];

}

#pragma mark - 底部按钮事件
- (void)handleFooterButtonAction
{
    if ([self.delegate respondsToSelector:@selector(footerButtonAction:)]) {
        [self.delegate footerButtonAction:self];
    }
}

- (void)setPullUpLoad:(BOOL)pullUpLoad
{
    _pullUpLoad = pullUpLoad;
    if (pullUpLoad) {
        WeakSelf;
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if ([weakSelf.delegate respondsToSelector:@selector(pullUpLoadMoreData:)]) {
                [weakSelf.delegate pullUpLoadMoreData:weakSelf];
            }
        }];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        footer.automaticallyHidden = YES;
        self.tableView.mj_footer = footer;
    }
}

@end
