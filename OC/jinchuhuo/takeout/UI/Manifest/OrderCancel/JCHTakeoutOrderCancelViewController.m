//
//  JCHTakeoutOrderCancelViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderCancelViewController.h"
#import "JCHTakeoutOrderCancelTableViewCell.h"
#import "CommonHeader.h"

@interface JCHTakeoutOrderCancelViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSArray *dataSource;
@property (retain, nonatomic) NSString *orderID;
@property (retain, nonatomic) NSString *resource;

@end

@implementation JCHTakeoutOrderCancelViewController

- (void)dealloc
{
    self.dataSource = nil;
    self.orderID = nil;
    self.resource = nil;
    self.orderCancelSuccess = nil;
    
    [super dealloc];
}

- (instancetype)initWithOrderID:(NSString *)orderID resource:(NSString *)resource
{
    self = [super init];
    if (self) {
        self.title = @"请选择取消原因";

        NSArray *reasonArray = @[@{@"reasonCode" : @(31), @"reason" : @"用户信息不符"},
                                 @{@"reasonCode" : @(32), @"reason" : @"联系不上用户"},
                                 @{@"reasonCode" : @(33), @"reason" : @"商品已售完"},
                                 @{@"reasonCode" : @(34), @"reason" : @"打烊"},
                                 @{@"reasonCode" : @(35), @"reason" : @"商家现在太忙"},
                                 @{@"reasonCode" : @(36), @"reason" : @"配送问题"},
                                 @{@"reasonCode" : @(9), @"reason" : @"其他原因"}, ];
        self.orderID = orderID;
        self.resource = resource;
        
        NSMutableArray *dataSource = [NSMutableArray array];
        for (NSInteger i = 0; i < reasonArray.count; i++) {
            NSDictionary *dict = reasonArray[i];
            NSString *reason = dict[@"reason"];
            NSInteger reasonCode = [dict[@"reasonCode"] integerValue];
            
            JCHTakeoutOrderCancelTableViewCellData *data = [[[JCHTakeoutOrderCancelTableViewCellData alloc] init] autorelease];
            data.title = reason;
            data.reasonCode = reasonCode;
            data.selected = NO;
            [dataSource addObject:data];
        }
        self.dataSource = dataSource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)createUI
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(handleSaveReason)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.tableView registerClass:[JCHTakeoutOrderCancelTableViewCell class]
           forCellReuseIdentifier:@"JCHTakeoutOrderCancelTableViewCell"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutOrderCancelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHTakeoutOrderCancelTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    JCHTakeoutOrderCancelTableViewCellData *data = self.dataSource[indexPath.row];
    [cell setCellData:data];

    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        JCHTakeoutOrderCancelTableViewCellData *data = self.dataSource[i];
        if (data.selected) {
            if (i == indexPath.row) {
                return;
            }
            data.selected = NO;
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }

    JCHTakeoutOrderCancelTableViewCellData *data = self.dataSource[indexPath.row];
    data.selected = YES;
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)handleSaveReason
{
    JCHTakeoutOrderCancelTableViewCellData *selectedData = nil;
    for (JCHTakeoutOrderCancelTableViewCellData *data in self.dataSource) {
        if (data.selected) {
            selectedData = data;
            break;
        }
    }
    if (selectedData == nil) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请选择取消原因" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    
    NSString *cancelReason = selectedData.title;
    NSString *reasonCode = [NSString stringWithFormat:@"%ld", selectedData.reasonCode];

    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    TakeOutCancelOrderRequest *request = [[[TakeOutCancelOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/cancel", kTakeoutServerIP];
    request.resource = self.resource;
    request.orderId = self.orderID;
    request.reason = cancelReason;
    request.reasonCode = reasonCode;
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    [takeoutService cancelOrder:request callback:^(id response) {
        
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
                
                [self.navigationController popViewControllerAnimated:YES];
                if (self.orderCancelSuccess) {
                    self.orderCancelSuccess();
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

@end
