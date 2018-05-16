//
//  JCHGuideThirdViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/2/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHGuideThirdViewController.h"
#import "JCHLocationManager.h"
#import "CommonHeader.h"
#import "MBProgressHUD+JCHHud.h"
#import "ServiceFactory.h"
#import "JCHSyncStatusManager.h"
#import "JCHStatisticsManager.h"
#import "CommonHeader.h"

@interface JCHGuideThirdViewController ()

@property (nonatomic, retain) NSString *bookType;

@end

@implementation JCHGuideThirdViewController
{
    UIView *_bottomContainerView;
    UITextField *_shopNameTextField;
    UITextField *_shopAddressTextField;
    UIButton *_nextPageButton;
    CGFloat _defauleKeyboardDistanceFromTextField;
}

- (instancetype)initWithBookType:(NSString *)bookType
{
    self = [super init];
    if (self) {
        self.bookType = bookType;
    }
    return self;
}

- (void)dealloc
{
    self.bookType = nil;
    [super dealloc];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self createUI];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    _defauleKeyboardDistanceFromTextField = keyboardManager.keyboardDistanceFromTextField;
    keyboardManager.keyboardDistanceFromTextField = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getLocation:_nextPageButton];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setEnableHandlingAutoRegisterResponse:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = _defauleKeyboardDistanceFromTextField;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setEnableHandlingAutoRegisterResponse:NO];
}

- (void)createUI
{
    self.view.backgroundColor = UIColorFromRGB(0xfffefa);

    CGFloat titleLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:77.0f];
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"打理您的小店"
                                               font:[UIFont jchSystemFontOfSize:17.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    CGSize fitSize = [titleLabel sizeThatFits:CGSizeZero];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(titleLabelTopOffset);
        make.height.mas_equalTo(fitSize.height + 5);
        make.width.mas_equalTo(fitSize.width + 5);
        make.centerX.equalTo(self.view);
    }];
    
    UIImageView *centerImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_get_storeaddress"]] autorelease];
    [self.view addSubview:centerImageView];
    
    CGFloat centerImageViewWidth = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:242.0f];
    CGFloat centerImageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:242.0f];
    CGFloat centerImageViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:30.0f];
    
    [centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).with.offset(centerImageViewTopOffset);
        make.height.mas_equalTo(centerImageViewHeight);
        make.width.mas_equalTo(centerImageViewWidth);
        make.centerX.equalTo(self.view);
    }];

    _bottomContainerView = [[[UIView alloc] init] autorelease];
    _bottomContainerView.backgroundColor = [UIColor whiteColor];
    _bottomContainerView.layer.borderColor = JCHColorSeparateLine.CGColor;
    _bottomContainerView.layer.borderWidth = 1;
    _bottomContainerView.layer.cornerRadius = 5;
    _bottomContainerView.clipsToBounds = YES;
    [self.view addSubview:_bottomContainerView];
    
    CGFloat bottomContainerViewTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:46.0f];
    CGFloat bottomContainerViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:342.0f];
    CGFloat bottomContainerViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:100.0f];
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerImageView.mas_bottom).with.offset(bottomContainerViewTopOffset);
        make.height.mas_equalTo(bottomContainerViewHeight);
        make.width.mas_equalTo(bottomContainerViewWidth);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *shopNameTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"店名"
                                              font:[UIFont jchSystemFontOfSize:15.0f]
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentCenter];
    [_bottomContainerView addSubview:shopNameTitleLabel];
    
    CGFloat shopNameTitleLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:55.0f];
    CGFloat rightButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:45.0f];
    [shopNameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContainerView);
        make.width.mas_equalTo(shopNameTitleLabelWidth);
        make.top.equalTo(_bottomContainerView);
        make.bottom.equalTo(_bottomContainerView.mas_centerY);
    }];
    
    _shopNameTextField = [JCHUIFactory createTextField:CGRectZero
                                           placeHolder:@"给您的小店取个名字吧~"
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
    _shopNameTextField.font = [UIFont jchSystemFontOfSize:15.0f];
    _shopNameTextField.delegate = self;
    _shopNameTextField.keyboardType = UIKeyboardTypeDefault;
    _shopNameTextField.returnKeyType = UIReturnKeyDone;
    //_shopNameTextField.inputAccessoryView = nil;
    [_bottomContainerView addSubview:_shopNameTextField];
    
    CGFloat textFieldLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    [_shopNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(shopNameTitleLabel.mas_right).with.offset(textFieldLeftOffset);
        make.right.equalTo(_bottomContainerView.mas_right);
        make.top.equalTo(_bottomContainerView);
        make.bottom.equalTo(_bottomContainerView.mas_centerY);
    }];
    
    UIView *separateLine = [[[UIView alloc] init] autorelease];
    separateLine.backgroundColor = JCHColorSeparateLine;
    [_bottomContainerView addSubview:separateLine];
    
    [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomContainerView);
        make.right.equalTo(_bottomContainerView);
        make.bottom.equalTo(_bottomContainerView.mas_centerY);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    UILabel *shopAddressTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                         title:@"地址"
                                                          font:[UIFont jchSystemFontOfSize:15.0f]
                                                     textColor:JCHColorMainBody
                                                        aligin:NSTextAlignmentCenter];
    [_bottomContainerView addSubview:shopAddressTitleLabel];
    
    [shopAddressTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(shopNameTitleLabel);
        make.top.equalTo(shopNameTitleLabel.mas_bottom);
    }];
    
    _shopAddressTextField = [JCHUIFactory createTextField:CGRectZero
                                           placeHolder:@"输入您的店铺地址"
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
    _shopAddressTextField.font = [UIFont jchSystemFontOfSize:15.0f];
    _shopAddressTextField.delegate = self;
    _shopAddressTextField.returnKeyType = UIReturnKeyDone;
    //_shopAddressTextField.inputAccessoryView = nil;
    [_bottomContainerView addSubview:_shopAddressTextField];
    
    [_shopAddressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_shopNameTextField);
        make.right.equalTo(_bottomContainerView.mas_right).with.offset(-rightButtonWidth);
        make.top.equalTo(_shopNameTextField.mas_bottom);
        make.bottom.equalTo(_bottomContainerView);
    }];
    
    UIButton *getLocationButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                      action:@selector(getLocation:)
                                                    title:nil
                                               titleColor:nil
                                          backgroundColor:[UIColor whiteColor]];
    [getLocationButton setImage:[UIImage imageNamed:@"guide_address"] forState:UIControlStateNormal];
    [_bottomContainerView addSubview:getLocationButton];
    
    [getLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_shopAddressTextField.mas_right);
        make.right.equalTo(_bottomContainerView);
        make.top.and.bottom.equalTo(_shopAddressTextField);
    }];
    
    _nextPageButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(nextPage)
                                           title:@"开始打理我的小店"
                                      titleColor:[UIColor whiteColor]
                                 backgroundColor:JCHColorHeaderBackground];
    [_nextPageButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
    [_nextPageButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
    _nextPageButton.layer.cornerRadius = 4;
    _nextPageButton.enabled = NO;
    [self.view addSubview:_nextPageButton];
    
    CGFloat nextPageButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:312.0f];
    CGFloat nextPageButtonHeight = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:50.0f];
    CGFloat nextPageButtonBottomOffset = [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:NO sourceHeight:55.0f];
    
    [_nextPageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-nextPageButtonBottomOffset);
        make.height.mas_equalTo(nextPageButtonHeight);
        make.width.mas_equalTo(nextPageButtonWidth);
        make.centerX.equalTo(self.view);
    }];
}

- (void)nextPage
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSArray *bookInfoList = [ServiceFactory getAllAccountBookList:statusManager.userID];
    if (bookInfoList.count == 0) {
        [self createAccountFirst];
    } else {
#if MMR_TAKEOUT_VERSION
        // 外卖版注册
        [self registerForTakeout];
#else
        [self updateBookInfo];
        [self handleSwitchViewController];
#endif
    }
}

- (void)createAccountFirst
{
    JCHAccountBookManager *accountBookManager = [JCHAccountBookManager sharedManager];
    [accountBookManager newAccountBook:^(BOOL success) {
        if (success) {
            // 新建店铺成功，发送统计信息
            [[JCHStatisticsManager sharedInstance] createShopStatistics];
#if !MMR_BASE_VERSION
            
    #if MMR_TAKEOUT_VERSION
                [self registerForTakeout];
    #else
            [self updateBookInfo];
            [self handleSwitchViewController];
    #endif 
#else
            [self updateBookInfo];
            [self handleSwitchViewController];
#endif
            
        }
    }];
}

- (void)registerForTakeout
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHLocationManager *locationManager = [JCHLocationManager shareInstance];
    [locationManager getCoordinate2dResult:^(CLLocationCoordinate2D coordinate2D) {
        
        id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
        RegisterAccountBookRequest *request = [[[RegisterAccountBookRequest alloc] init] autorelease];
        request.token = statusManager.syncToken;
        request.bookID = statusManager.accountBookID;
        request.name = _shopNameTextField.text;
        request.address = _shopAddressTextField.text;
        request.phone = statusManager.phoneNumber;
        request.serviceURL = [NSString stringWithFormat:@"%@/book/register", kTakeoutServerIP];
        
        if (CLLocationCoordinate2DIsValid(coordinate2D)) {
            request.latitude = [NSString stringWithFormat:@"%g", coordinate2D.latitude];
            request.longitude = [NSString stringWithFormat:@"%g", coordinate2D.longitude];
        } else {
            request.latitude = @"0";
            request.longitude = @"0";
        }
        
        [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
        [takeoutService registerAccountBook:request callback:^(id response) {
            
            NSDictionary *data = response;
            
            if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
                NSDictionary *responseData = data[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    //! @todo
                    [MBProgressHUD showHUDWithTitle:@"加载失败，请重试!"
                                             detail:@""
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                } else {
                    NSLog(@"responseData = %@", responseData);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                    // 注册成功
                    [self updateBookInfo];
                    [self handleSwitchViewController];
                }
            } else {
                NSLog(@"request fail: %@", data[@"data"]);
                [MBProgressHUD showNetWorkFailedHud:@""
                                          superView:self.view];
            }
        }];
    }];
}

- (void)updateBookInfo
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
    
    //NSArray *bookInfoList = [ServiceFactory getAllAccountBookList:statusManager.userID];
    //bookInfoRecord = bookInfoList[0];
    
    bookInfoRecord.bookName = _shopNameTextField.text;
    bookInfoRecord.bookAddress = _shopAddressTextField.text;
    bookInfoRecord.bookType = self.bookType;
    
#if MMR_TAKEOUT_VERSION
    bookInfoRecord.bookType = @"外卖店";
#elif MMR_RESTAURANT_VERSION
    bookInfoRecord.bookType = @"餐饮店";
#endif
    
    [bookInfoService updateBookInfo:bookInfoRecord];
}

- (void)handleSwitchViewController
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //[self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // 选择店长角色完成后自动同步
    AppDelegate *theApp = [AppDelegate sharedAppDelegate];
    [theApp.homePageController.navigationController popToRootViewControllerAnimated:NO];
    [theApp.homePageController doManualDataSync];
    
    //允许自动同步
    statusManager.enableAutoSync = YES;
    statusManager.isShopManager = YES;
    statusManager.isLogin = YES;
    [JCHSyncStatusManager writeToFile];
}

- (void)getLocation:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDWithTitle:@"正在获取位置..."
                                                  detail:nil
                                                duration:1000
                                                    mode:MBProgressHUDModeIndeterminate
                                              completion:nil];
    JCHLocationManager *locationManager = [JCHLocationManager shareInstance];
    [locationManager getLocationResult:^(NSString *location, NSString *city, NSString *subLocality, NSString *street) {
        if (location) {
            [hud hide:YES];
            _shopAddressTextField.text = location;
            
            if (![_shopAddressTextField.text isEqualToString:@""] && ![_shopNameTextField.text isEqualToString:@""]) {
                _nextPageButton.enabled = YES;
            } else {
                _nextPageButton.enabled = NO;
            }
        } else {
            [MBProgressHUD showHUDWithTitle:@"获取位置信息失败"
                                     detail:nil
                                   duration:1.5
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![_shopAddressTextField.text isEqualToString:@""] && ![_shopNameTextField.text isEqualToString:@""]) {
        _nextPageButton.enabled = YES;
    } else {
        _nextPageButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
