//
//  JCHTakeoutShopStatusSetViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutShopStatusSetViewController.h"
#import "JCHShopSettingViewController.h"
#import "CommonHeader.h"

@interface JCHTakeoutShopStatusSetViewController ()
{
    UILabel *_statusLabel;
    UILabel *_middleInfoLabel;
    UIButton *_shopStatusChangeButton;
}
@property (retain, nonatomic) NSArray *shopOpenTimeList;
@property (assign, nonatomic) BOOL shopStatus;
@end

@implementation JCHTakeoutShopStatusSetViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"营业状态";
    }
    return self;
}

- (void)dealloc
{
    self.shopOpenTimeList = nil;
    self.shopStatusChangeBlock = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self queryShopStatus];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    _statusLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@"营业中"
                                        font:JCHFont(25.0)
                                   textColor:UIColorFromRGB(0xFF6400)
                                      aligin:NSTextAlignmentCenter];
    _statusLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_statusLabel];
    
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    _middleInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"当前餐厅处于设置的营业时间内，正常接受新订单"
                                            font:JCHFont(14.0)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    _middleInfoLabel.numberOfLines = 0;
    [self.view addSubview:_middleInfoLabel];
    
    [_middleInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_statusLabel.mas_bottom);
        make.left.equalTo(self.view).offset(kStandardLeftMargin);
        make.right.equalTo(self.view).offset(-kStandardLeftMargin);
        make.height.mas_equalTo(50);
    }];

    _shopStatusChangeButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(handleChangeShopStatus)
                                                   title:@"停止营业"
                                              titleColor:[UIColor whiteColor]
                                         backgroundColor:JCHColorHeaderBackground];
    _shopStatusChangeButton.titleLabel.font = JCHFont(15);
    [self.view addSubview:_shopStatusChangeButton];
    
    [_shopStatusChangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_middleInfoLabel);
        make.top.equalTo(_middleInfoLabel.mas_bottom).offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(kStandardButtonHeight);
    }];
    
    [self updateUI];
}

- (void)updateUI
{
    if (!self.shopStatus) {
        _statusLabel.text = @"已停止营业";
        _statusLabel.textColor = JCHColorHeaderBackground;
        _middleInfoLabel.text = @"当前餐厅停止提供服务，不接受任何订单，手动恢复营业后可正常接受新订单";
        [_shopStatusChangeButton setTitle:@"恢复营业" forState:UIControlStateNormal];
    } else {
        _statusLabel.text = @"营业中";
        _statusLabel.textColor = JCHColorMainBody;
        [_shopStatusChangeButton setTitle:@"停止营业" forState:UIControlStateNormal];
        
        // 正在营业需要判断当前时间在没在营业时间内
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *currentTime = [dateFormatter stringFromDate:date];
        
        
        BOOL isInTimeRange = NO;
        for (NSString *timeRange in self.shopOpenTimeList) {
            NSArray *timeList = [timeRange componentsSeparatedByString:@"-"];
            if (timeList.count == 2) {
                NSString *beginTime = [timeList firstObject];
                NSString *endTime = [timeList lastObject];
                
                if ([currentTime compare:beginTime] == NSOrderedDescending && [currentTime compare:endTime] == NSOrderedAscending) {
                    isInTimeRange = YES;
                    break;
                }
            } else {
                NSLog(@"时间信息有误");
            }
        }
        
        if (isInTimeRange) {
            _middleInfoLabel.text = @"当前餐厅处于设置的营业时间内，正常接受新订单";
        } else {
            _middleInfoLabel.text = @"当前餐厅处于设置的营业时间外，不接受新订单";
        }
    }
}

- (void)queryShopStatus
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    QueryShopInfoRequest *request = [[[QueryShopInfoRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/queryBook", kTakeoutServerIP];
    
    [takeoutService queryShopInfo:request callback:^(id response) {
        
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
                
                NSDictionary *bookInfo = responseData[@"data"][@"bookInfo"];
                self.shopStatus = [bookInfo[@"openStatus"] boolValue];
                NSString *openTime = bookInfo[@"openTime"];
                self.shopOpenTimeList = [openTime componentsSeparatedByString:@","];
                [self createUI];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}

- (void)handleChangeShopStatus
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    OpencloseShopRequest *request = [[[OpencloseShopRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/book/operate", kTakeoutServerIP];
    request.operate = [NSString stringWithFormat:@"%@", @(!self.shopStatus)];
    
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    [takeoutService opencloseShop:request callback:^(id response) {
        
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
                
                self.shopStatus = !self.shopStatus;
                [self updateUI];
                
                BOOL status = self.shopStatus;
                if (self.shopStatusChangeBlock) {
                    self.shopStatusChangeBlock(status);
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
