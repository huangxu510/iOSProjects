 //
//  JCHTakeoutBindingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutBindingViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHTakeoutBindingTableViewCell.h"
#import "CommonHeader.h"
#import "TakeOutService.h"
#import "ImageFileSynchronizer.h"
#import "JCHWKWebViewController.h"

/**
 *  同步逻辑：1.每次进入该页面查询绑定状态和是否同步过，如果已绑定但未同步，则自动触发一次同步
 *          2.用户绑定成功后，会收到服务器的推送，触发一次同步
 */

@interface JCHTakeoutBindingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSMutableDictionary *bindStatusForResource;

@end

@implementation JCHTakeoutBindingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bindStatusForResource = [NSMutableDictionary dictionary];
        [self.bindStatusForResource setObject:@(0) forKey:@(kJCHTakeoutResourceMeituan)];
        [self.bindStatusForResource setObject:@(0) forKey:@(kJCHTakeoutResourceEleme)];
    }
    return self;
}

- (void)dealloc
{
    self.bindStatusForResource = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"外卖绑定";
    
    [self.tableView registerClass:[JCHTakeoutBindingTableViewCell class] forCellReuseIdentifier:@"JCHTakeoutBindingTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self queryBindStatus];
}

- (void)queryBindStatus
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    QueryBindStatusRequest *request = [[[QueryBindStatusRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/binds", kTakeoutServerIP];
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    [takeoutService queryBindStatus:request callback:^(id response) {
        
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
                
                // bindStatus 为返回的数组，数组中一个元素对应一个平台，返回的都是绑定过的平台
                NSArray *bindStatus = responseData[@"data"][@"binds"];
                
                BOOL hasSyncOneTime = NO;
                for (NSDictionary *bindInfo in bindStatus) {
                    
                    JCHTakeoutResource takeoutResource = [bindInfo[@"type"] integerValue];
                    [self.bindStatusForResource setObject:@(1) forKey:@(takeoutResource)];
                    NSInteger syncStatus = [bindInfo[@"syncTimes"] integerValue];

                    if (syncStatus == 0 && hasSyncOneTime == NO) {
                        JCHTakeoutManager *takeoutManager = [JCHTakeoutManager sharedInstance];
                        
                        [takeoutManager syncTakeoutData:takeoutResource];
                        hasSyncOneTime = YES;
                    }
                }
                
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *iconNameArr = @[@"icon_takeout_bind_meituan", @"icon_takeout_bind_eleme"];
    NSArray *titleTextArr = @[@"美团外卖", @"饿了么"];
    
    JCHTakeoutBindingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHTakeoutBindingTableViewCell" forIndexPath:indexPath];
    WeakSelf;
    cell.bindingAction = ^{
        [weakSelf bindingTakeout:indexPath];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell moveBottomLineLeft:YES];
    JCHTakeoutBindingTableViewCellData *data = [[[JCHTakeoutBindingTableViewCellData alloc] init] autorelease];
    data.imageName = iconNameArr[indexPath.row];
    data.title = titleTextArr[indexPath.row];
    
    data.bindingStatus = [[self.bindStatusForResource objectForKey:@(indexPath.row + 1)] integerValue];
    

    [cell setCellData:data];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Binding

- (void)bindingTakeout:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self handleBindMeituanTakeout];
    } else {
        [self handleBindElemeTakeout];
    }
}

#pragma mark - 绑定美团外卖
- (void)handleBindMeituanTakeout
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    TakeOutMeiTuanBindShopRequest *request = [[[TakeOutMeiTuanBindShopRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.bindName = statusManager.accountBookID;//bookInfo.bookName;
    request.serviceURL = [NSString stringWithFormat:@"%@/bind/mtBind", kTakeoutServerIP];
    
    [takeoutService meituanBindShop:request callback:^(id response) {
        
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
                
                NSString *urlString = responseData[@"data"][@"url"];
                
                //                    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                JCHHTMLViewController *meituanBinding = [[[JCHHTMLViewController alloc] initWithURL:urlString postRequest:NO] autorelease];
                __block typeof(meituanBinding) weakMeituanBinding = meituanBinding;
                meituanBinding.popActionCallBack = ^ {
                    [weakMeituanBinding.navigationController popToViewController:self animated:YES];
                };
                meituanBinding.title = @"美团外卖";
                [self.navigationController pushViewController:meituanBinding animated:YES];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

#pragma mark - 绑定饿了么外卖
- (void)handleBindElemeTakeout
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    TakeOutElemeBindShopRequest *request = [[[TakeOutElemeBindShopRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.shopID = @"";
    request.serviceURL = [NSString stringWithFormat:@"%@/bind/elmBind", kTakeoutServerIP];
    
    [takeoutService elemeBindShop:request callback:^(id response) {
        
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
                
                NSString *urlString = responseData[@"data"][@"url"];

                JCHWKWebViewController *elemeBinding = [[[JCHWKWebViewController alloc] initWithURL:urlString] autorelease];
                elemeBinding.title = @"饿了么外卖";
                [self.navigationController pushViewController:elemeBinding animated:YES];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

@end
