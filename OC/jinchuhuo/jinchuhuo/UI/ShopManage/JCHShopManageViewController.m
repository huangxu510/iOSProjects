//
//  JCHSettingsViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHShopManageViewController.h"
#import "JCHServiceWindowViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHAddedServiceViewController.h"
#import "JCHSettlementViewContrller.h"
#import "JCHShopManageMoreItemViewController.h"
#import "JCHAccountBookViewController.h"
#import "JCHAllContactsViewController.h"
#import "JCHShopSettingViewController.h"
#import "JCHSettingCollectionViewCell.h"
#import "JCHSettingSectionView.h"
#import "JCHShopAssistantInfoViewController.h"
#import "JCHShopBarCodeViewController.h"
#import "JCHShopInfoEditViewController.h"
#import "JCHProductRecordListViewController.h"
#import "JCHCategoryListViewController.h"
#import "JCHUnitListViewController.h"
#import "JCHSKUTypeListViewController.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHWarehouseViewController.h"
#import "JCHSettlementManager.h"
#import "JCHMyTableViewCell.h"
#import "JCHShopAssistantCollectionViewCell.h"
#import "JCHCollectionView.h"
#import "CommonHeader.h"
#import "JCHSyncStatusManager.h"
#import "AppDelegate.h"
#import "JCHShopUtility.h"
#import "ServiceFactory.h"
#import "JCHDisplayNameUtility.h"
#import "JCHRestaurantShopManageMoreItemViewController.h"
#import <Masonry.h>

enum
{
    kProductItem        = 0,// 商品
    kCategoryItem       = 1,// 类型
    kSKUItem            = 2,// 单位
    kSettlementItem     = 3,// 规格
    kAccountBookItem    = 4,// 账户
    kContactsItem       = 5,// 通讯录
};

@interface JCHShopManageViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JCHShopAssistantTableViewCellDelegate, UIScrollViewDelegate, UITabBarControllerDelegate>
{
    UILabel *_titleLabel;
    UIButton *_settingButton;
    UIImageView *_topImageView;
    UILabel *_addressLabel;
    
    JCHCollectionView *_contentCollectionView;

    UIView *_addedServiceContentView;
    UIImageView *_addedServiceLevelIcon;
    UILabel *_addedServiceInfoLabel;
    UIButton *_openAddedServiceButton;
    
    CGFloat _topImageViewHeight;
    BOOL _appearFromPop;
}
@property (nonatomic, retain) NSArray *bookMemberArray;
@end

@implementation JCHShopManageViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        _appearFromPop = NO;
        [self registerResponseNotificationHandler];
        _topImageViewHeight = kScreenWidth * 460 / 750;
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterResponseNotificationHandler];
    [self.bookMemberArray release];
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
    self.navigationController.tabBarController.delegate = self;
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_appearFromPop) { //pop回来
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    [self loadData];
    
    //钱橙贷会改变导航栏的颜色，这里还原回来
    [self.navigationController.navigationBar setBarTintColor:JCHColorHeaderBackground];
    
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    if (manager.isLogin && !manager.isShopManager) {
        _settingButton.hidden = YES;
    } else {
        _settingButton.hidden = NO;
    }
    
    //更新封面
    if ([manager.shopCoverImageName isEmptyString]) {
        _topImageView.image = [UIImage imageNamed:@"bg_manage_1"];
    } else {
        _topImageView.image = [UIImage imageNamed:manager.shopCoverImageName];
    }
    
    [self changeAddedServiceInfo];
    [self updateAddedServiceStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _appearFromPop = NO;
    NSArray *selectedIndexPaths = [_contentCollectionView indexPathsForSelectedItems];
    
    if (selectedIndexPaths.count > 0) { //点击item后回来
        [_contentCollectionView deselectItemAtIndexPath:selectedIndexPaths[0] animated:YES];
    } else {
        //[_contentCollectionView reloadData];
    }
    
    //获取位置
    JCHLocationManager *locationManager = [JCHLocationManager shareInstance];
    [locationManager getLocationResult:^(NSString *location, NSString *city, NSString *subLocality, NSString *street) {
        if (city) {
            _addressLabel.text = city;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)createUI
{
    self.navigationItem.leftBarButtonItem = nil;

    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:NO
                                                                                                        TabBar:YES
                                                                                                  sourceHeight:35
                                                                                           noStretchingIn6Plus:YES]);
    flowLayout.minimumInteritemSpacing = kSeparateLineWidth;
    _contentCollectionView = [[[JCHCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    _contentCollectionView.dataSource = self;
    _contentCollectionView.delegate = self;
    _contentCollectionView.alwaysBounceVertical = YES;
    _contentCollectionView.clipsToBounds = NO;
    _contentCollectionView.backgroundColor = JCHColorGlobalBackground;
    _contentCollectionView.contentInset = UIEdgeInsetsMake(_topImageViewHeight, 0, 0, 0);
    
    [_contentCollectionView registerClass:[JCHShopAssistantCollectionViewCell class] forCellWithReuseIdentifier:@"shopAssistantCell"];
    [_contentCollectionView registerClass:[JCHSettingCollectionViewCell class] forCellWithReuseIdentifier:@"settingCell"];
    [_contentCollectionView registerClass:[JCHSettingSectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    [self.view addSubview:_contentCollectionView];
    
    [_contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    //[self.view bringSubviewToFront:_topImageView];
    
    _topImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_manage_1"]] autorelease];
    _topImageView.contentMode = UIViewContentModeScaleAspectFill;
    _topImageView.userInteractionEnabled = YES;
    _topImageView.frame = CGRectMake(0, -_topImageViewHeight, kScreenWidth, _topImageViewHeight);
    _topImageView.clipsToBounds = YES;
    [_contentCollectionView addSubview:_topImageView];
    

    //个人增值服务入口
    {
        _addedServiceContentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        _addedServiceContentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _addedServiceContentView.clipsToBounds = YES;
        [_topImageView addSubview:_addedServiceContentView];
        
        [_addedServiceContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_topImageView);
            make.height.mas_equalTo(35);
        }];
        
        [_addedServiceContentView addSeparateLineWithFrameTop:NO bottom:YES];
        
        _addedServiceLevelIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_common_level_normal"]] autorelease];
        [_addedServiceContentView addSubview:_addedServiceLevelIcon];
        
        [_addedServiceLevelIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_addedServiceContentView).with.offset(kStandardLeftMargin);
            make.height.and.width.mas_equalTo(27);
            make.centerY.equalTo(_addedServiceContentView);
        }];
        
        _openAddedServiceButton = [JCHUIFactory createButton:CGRectZero
                                                      target:self
                                                      action:@selector(handleOpenAddedService)
                                                       title:@"开通"
                                                  titleColor:[UIColor whiteColor]
                                             backgroundColor:UIColorFromRGB(0xff6400)];
        _openAddedServiceButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
        [_addedServiceContentView addSubview:_openAddedServiceButton];
        
        [_openAddedServiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_addedServiceContentView).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(56.0f);
            make.height.mas_equalTo(28.0f);
            make.centerY.equalTo(_addedServiceContentView);
        }];
        
        _addedServiceInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"注册会员，开通银麦享更多特权!"
                                                      font:[UIFont jchSystemFontOfSize:13.0f]
                                                 textColor:[UIColor whiteColor]
                                                    aligin:NSTextAlignmentLeft];
        _addedServiceInfoLabel.numberOfLines = 1;
        _addedServiceInfoLabel.adjustsFontSizeToFitWidth = YES;
        [_addedServiceContentView addSubview:_addedServiceInfoLabel];
        
        [_addedServiceInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_addedServiceLevelIcon.mas_right).with.offset(kStandardLeftMargin / 2);
            make.right.equalTo(_openAddedServiceButton.mas_left).with.offset(-kStandardLeftMargin / 2);
            make.top.and.bottom.equalTo(_addedServiceContentView);
        }];
    }

    
    
    UIButton *barCodeButton = [JCHUIFactory createButton:CGRectZero
                                                  target:self
                                                  action:@selector(myBarCode)
                                                   title:nil
                                              titleColor:nil
                                         backgroundColor:nil];
    [barCodeButton setImage:[UIImage imageNamed:@"mystore_icon_QR Code"] forState:UIControlStateNormal];
    [self.view addSubview:barCodeButton];
    
    [barCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.width.mas_equalTo(kNavigatorBarHeight);
        make.top.equalTo(self.view).with.offset(kStatusBarHeight);
        make.height.mas_equalTo(kNavigatorBarHeight);
    }];
    
    _settingButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(handleSetShop)
                                          title:nil
                                     titleColor:nil
                                backgroundColor:nil];
    [_settingButton setImage:[UIImage imageNamed:@"mystore_iconsetting"] forState:UIControlStateNormal];
    [self.view addSubview:_settingButton];
    
    [_settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(barCodeButton.mas_left);
        make.width.mas_equalTo(kNavigatorBarHeight);
        make.top.equalTo(barCodeButton);
        make.height.equalTo(barCodeButton);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"管店"
                                       font:[UIFont boldSystemFontOfSize:18.0f]
                                  textColor:[UIColor whiteColor]
                                     aligin:NSTextAlignmentCenter];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(kStatusBarHeight);
        make.height.mas_equalTo(kNavigatorBarHeight);
        make.centerX.equalTo(self.view);
        make.right.equalTo(_settingButton.mas_left).with.offset(-kStandardLeftMargin);
    }];
    
    _addressLabel = [JCHUIFactory createLabel:CGRectZero title:@"" font:JCHFont(15) textColor:[UIColor whiteColor] aligin:NSTextAlignmentLeft];
    [self.view addSubview:_addressLabel];
    _addressLabel.adjustsFontSizeToFitWidth = YES;
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.top.height.equalTo(_titleLabel);
        make.right.equalTo(_titleLabel.mas_left).with.offset(-kStandardLeftMargin);
    }];
}

- (void)handleOpenAddedService
{
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];

    switch (addedServiceManager.level) {
            
        case kJCHAddedServiceNormalLevel:   //普通会员
        case kJCHAddedServiceCopperLevel:   //铜麦会员
        {
            JCHAddedServiceViewController *addedServiceViewController = [[[JCHAddedServiceViewController alloc] init] autorelease];
            addedServiceViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addedServiceViewController animated:YES];
            _appearFromPop = YES;
        }
            break;
            
        case kJCHAddedServiceSiverLevel:    //银麦会员
        {
            if (addedServiceManager.remainingDays >= 15) {
                //拨打电话
                NSString * str = [NSString stringWithFormat:@"telprompt://400-869-0055"];
                
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                }
            } else {
                JCHAddedServiceViewController *addedServiceViewController = [[[JCHAddedServiceViewController alloc] init] autorelease];
                addedServiceViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addedServiceViewController animated:YES];
                _appearFromPop = YES;
            }
        }
            break;
            
        case kJCHAddedServiceGoldLevel:     //金麦会员
        {
            //TODO: 4.0版本暂时拦截金麦会员进入服务购买页面，4.1版本取消
            if (addedServiceManager.remainingDays >= 15) {
                //拨打电话
                NSString * str = [NSString stringWithFormat:@"telprompt://400-869-0055"];
                
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                }
            } else {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                     message:@"您当前为金麦会员，如需续费，请升级app到最新版本"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"我知道了"
                                                           otherButtonTitles:nil] autorelease];
                [alertView show];
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)handleSetShop
{
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    
    if (manager.isLogin) {
        if (manager.isShopManager) {
            AppDelegate *theDelegate = [AppDelegate sharedAppDelegate];
            theDelegate.switchToTargetController = self;
            UIViewController *viewController = [[[JCHShopSettingViewController alloc] init] autorelease];
            
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            _appearFromPop = YES;
        }
    }
}

- (void)myBarCode
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        UIViewController *viewController = [[[JCHShopBarCodeViewController alloc] initWithShopBarCodeType:kJCHShopBarCodeMyShopBarCode] autorelease];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        _appearFromPop = YES;
    }
}

- (void)updateAddedServiceStatus
{
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                          fromDate:date];
    
    if (addedServiceManager.lastQueryInfoDate) {
        NSDateComponents *lastQueryInfoDateComponents = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                           fromDate:addedServiceManager.lastQueryInfoDate];
        
        
        if (!(dateComponents.year == lastQueryInfoDateComponents.year &&
              dateComponents.month == lastQueryInfoDateComponents.month &&
              dateComponents.day == lastQueryInfoDateComponents.day)) {
            
            [self doQueryAddedServiceInfo];
        }
    } else {
        [self doQueryAddedServiceInfo];
    }
}

//根据addedServiceManager改变会员的提示信息 和UI布局
- (void)changeAddedServiceInfo
{
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];

    switch (addedServiceManager.level) {
            
        case kJCHAddedServiceNormalLevel:   //普通会员
        {
            _addedServiceLevelIcon.image = [UIImage imageNamed:@"icon_common_level_normal"];
            _addedServiceInfoLabel.text = @"开通银麦会员尊享开店特权！";
            [_openAddedServiceButton setTitle:@"开通" forState:UIControlStateNormal];
            [_openAddedServiceButton setImage:nil forState:UIControlStateNormal];
        }
            break;
        case kJCHAddedServiceCopperLevel:   //铜麦会员
        {
            _addedServiceLevelIcon.image = [UIImage imageNamed:@"icon_common_level_copper"];
            _addedServiceInfoLabel.text = @"开通银麦会员尊享开店特权！";
            [_openAddedServiceButton setTitle:@"开通" forState:UIControlStateNormal];
            [_openAddedServiceButton setImage:nil forState:UIControlStateNormal];
        }
            break;
            
        case kJCHAddedServiceSiverLevel:    //银麦会员
        {
            _addedServiceLevelIcon.image = [UIImage imageNamed:@"icon_common_level_silver"];
            _addedServiceInfoLabel.text = @"您的银麦会员服务专线：400-869-0055";
            
            if (addedServiceManager.remainingDays >= 15) {
                [_openAddedServiceButton setTitle:nil forState:UIControlStateNormal];
                [_openAddedServiceButton setImage:[UIImage imageNamed:@"ic_mystore_call"] forState:UIControlStateNormal];
            } else {
                [_openAddedServiceButton setTitle:@"续费" forState:UIControlStateNormal];
                [_openAddedServiceButton setImage:nil forState:UIControlStateNormal];
            }
        }
            break;
            
        case kJCHAddedServiceGoldLevel:     //金麦会员
        {
            _addedServiceLevelIcon.image = [UIImage imageNamed:@"icon_common_level_golden"];
            _addedServiceInfoLabel.text = @"您的金麦会员服务专线：400-869-0055";
            
            if (addedServiceManager.remainingDays >= 15) {
                [_openAddedServiceButton setTitle:nil forState:UIControlStateNormal];
                [_openAddedServiceButton setImage:[UIImage imageNamed:@"ic_mystore_call"] forState:UIControlStateNormal];
            } else {
                [_openAddedServiceButton setTitle:@"续费" forState:UIControlStateNormal];
                [_openAddedServiceButton setImage:nil forState:UIControlStateNormal];
            }
        }
            break;
            
        default:
            break;
    }
    
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    if (manager.isLogin && manager.isShopManager) {
        _addedServiceContentView.hidden = NO;
    } else {
        _addedServiceContentView.hidden = YES;
    }
}

#pragma mark - ClearData

- (void)clearData
{
    NSLog(@"ClearShopManageData");
    self.bookMemberArray = nil;
    [_contentCollectionView reloadData];
}

#pragma mark - LoadData

- (void)loadData
{
    NSLog(@"LoadShopManageData");
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        
        id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
        id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            self.bookMemberArray = [bookMemberService queryBookMember];
            BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //店名
                _titleLabel.text = [JCHDisplayNameUtility getdisplayShopName:bookInfoRecord];
                [_contentCollectionView reloadData];
            });
        });
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:NO TabBar:YES sourceHeight:100 noStretchingIn6Plus:YES]);
    } else {
        return CGSizeMake(kScreenWidth / 4 - kSeparateLineWidth, kScreenWidth / 4);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isShopManager || statusManager.isLogin == NO) {
        return 3;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    if (section == 1) return 4;
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *titleArray = @[@"",
                            @[@"商品", @"类型", @"规格", @"结算"],
                            @[@"账本", @"通讯录", @"", @""]];//@[@"账本", @"通讯录", @"仓库", loanText, @""]
    
    NSArray *iconArray  = @[@"",
                            @[@"mystore_icon_goods",@"mystore_icon_type", @"mystore_icon_specifications", @"mystore_icon_checkout"],//@"mystore_icon_specifications"]
                            @[@"mystore_icon_book", @"mystore_icon_maillist", @"", @""]];//@[@"mystore_icon_book", @"mystore_icon_maillist", @"mystore_icon_specifications", loanIcon, @""]
    
    
    
    if (indexPath.section == 0){
        JCHShopAssistantCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shopAssistantCell" forIndexPath:indexPath];
        cell.cellDelegate = self;
        [cell setData:self.bookMemberArray];
        return cell;
    } else {
        JCHSettingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"settingCell"forIndexPath:indexPath];
        cell.titleLabel.text = titleArray[indexPath.section][indexPath.item];
        
        cell.headImageView.image = [UIImage imageNamed:iconArray[indexPath.section][indexPath.item]];
                
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JCHSettingSectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.moreButton.hidden = YES;
        [headerView.moreButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [headerView.moreButton removeTarget:self action:@selector(showMoreItem) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.section == 0) {
            headerView.titleLabel.text = @"店铺成员";
        } else if (indexPath.section == 1){
            headerView.titleLabel.text = @"基础设置";
            headerView.moreButton.hidden = NO;
            [headerView.moreButton setImage:[UIImage imageNamed:@"mystore_icon_more"] forState:UIControlStateNormal];
            [headerView.moreButton addTarget:self action:@selector(showMoreItem) forControlEvents:UIControlEventTouchUpInside];
        } else {
            headerView.titleLabel.text = @"店铺运营";
        }
        return headerView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
    NSUInteger itemIndex = ((indexPath.section - 1) * 4) + indexPath.row;
    UIViewController *viewController = nil;
    
    switch (itemIndex) {
        case kProductItem:
        {
            viewController = [[[JCHProductRecordListViewController alloc] init] autorelease];
        }
            break;
            
        case kCategoryItem:
        {
            viewController = [[[JCHCategoryListViewController alloc] initWithType:kJCHCategoryListTypeNormal] autorelease];
        }
            break;
            
        case kSKUItem:
        {
            viewController = [[[JCHSKUTypeListViewController alloc] init] autorelease];
        }
            break;
            
        case kSettlementItem:
        {
            BOOL accountStatus = [[JCHSettlementManager sharedInstance] getOpenAccountStatus];
            NSString *bindID = [[JCHSettlementManager sharedInstance] getBindID];
            if (nil == bindID) {
                bindID = @"";
            }
            
            if (accountStatus == YES) {
                viewController = [[[JCHSettlementViewContrller alloc] init] autorelease];
            } else {
                NSString *urlStr = [NSString stringWithFormat:@"%@?bindId=%@&UA=iOS&status=0",
                                    kCMBCOpenAccountServiceURL,
                                    bindID];
                
                viewController = [[[JCHHTMLViewController alloc] initWithURL:urlStr postRequest:NO] autorelease];
            }
        }
            break;
        case kAccountBookItem:
        {
            viewController = [[[JCHAccountBookViewController alloc] init] autorelease];
        }
            break;
        case kContactsItem:
        {
            viewController = [[[JCHAllContactsViewController alloc] init] autorelease];
        }
            break;
            
        default:
        {
            // pass
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
            break;
    }
    
    if (nil != viewController) {
        
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        _appearFromPop = YES;
    }
}

#pragma mark - 金融
- (void)handleFinanceBusiness
{
    //@"http://192.168.1.12:8080/mmr-credit/login/simpleLogin.html"     http://192.168.1.9:8088/mmr-credit/
    
    JCHHTMLViewController *finace = [[[JCHHTMLViewController alloc] initWithURL:kJCHQianChengDaiEntranceIP postRequest:YES] autorelease];
    finace.navigationBarColor = UIColorFromRGB(0xfe7600);
    finace.hidesBottomBarWhenPushed = YES;
    _appearFromPop = YES;
    [self.navigationController pushViewController:finace animated:YES];
}


- (void)showMoreItem
{
#if MMR_RESTAURANT_VERSION || MMR_TAKEOUT_VERSION
    // 餐饮版
    JCHRestaurantShopManageMoreItemViewController *viewController = [[[JCHRestaurantShopManageMoreItemViewController alloc] init] autorelease];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    _appearFromPop = YES;
    
#else
    // 通用版
    JCHShopManageMoreItemViewController *viewController = [[[JCHShopManageMoreItemViewController alloc] init] autorelease];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    _appearFromPop = YES;
#endif
}

#pragma mark - JCHShopAssistantTableViewCellDelegate
- (void)handleAddShopAssistant
{
    JCHShopBarCodeViewController *barCodeVC = [[[JCHShopBarCodeViewController alloc] initWithShopBarCodeType:kJCHShopBarCodeFindShopAssistant] autorelease];
    barCodeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:barCodeVC animated:YES];
    _appearFromPop = YES;
}

- (void)handleShowAssistantInfo:(NSInteger)index
{
    JCHShopAssistantInfoViewController *assistantInfoVC = [[[JCHShopAssistantInfoViewController alloc] init] autorelease];
    BookMemberRecord4Cocoa *bookMemberRecord = self.bookMemberArray[index];
    assistantInfoVC.userID = bookMemberRecord.userId;
    assistantInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:assistantInfoVC animated:YES];
    _appearFromPop = YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat offsetY = offset.y + _contentCollectionView.contentInset.top;
    
    if (offsetY < 0) {
        
        CGRect headerRect = CGRectMake(0, -_contentCollectionView.contentInset.top, kScreenWidth, _topImageViewHeight);//_topImageView.frame;
        headerRect.size.height = headerRect.size.height * (fabs(offsetY) / _topImageViewHeight + 1);
        headerRect.origin.y = headerRect.origin.y - (headerRect.size.height - _topImageViewHeight);
        
        _topImageView.frame = headerRect;
    }
}


- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(queryAddedServiceInfo:)
                               name:kJCHQueryAddedServiceInfoNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self
                                  name:kJCHQueryAddedServiceInfoNotification
                                object:[UIApplication sharedApplication]];
}


#pragma mark - 查询购买信息
- (void)doQueryAddedServiceInfo
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    QueryPurchaseInfoRequest *request = [[[QueryPurchaseInfoRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.serviceURL = [NSString stringWithFormat:@"%@/terminal/member", kJCHUserManagerServerIP];
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryPurchaseInfo:request responseNotification:kJCHQueryAddedServiceInfoNotification];
}

- (void)queryAddedServiceInfo:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
            //! @todo
            NSLog(@"queryAddedServiceInfo Fail.");
            [MBProgressHUD hideAllHudsForWindow];
            return;
        } else {
            //! @todo
            NSDictionary *serviceResponse = responseData[@"data"];
            NSInteger level = [[NSString stringWithFormat:@"%@", serviceResponse[@"level"]] integerValue];
            NSString *endTime = [NSString stringWithFormat:@"%@", serviceResponse[@"endTime"]];
            //NSTimeInterval endTimeInterval = [[NSString stringWithFormat:@"%@", serviceResponse[@"endTimestamp"]] integerValue];
            
            JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
            addedServiceManager.level = level;
            addedServiceManager.endTime = endTime;
            
            //查询信息成功后更新  上次查询服务状态的日期
            addedServiceManager.lastQueryInfoDate = [NSDate date];
            
            [self changeAddedServiceInfo];
        }
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
    } else {
        NSLog(@"request fail: %@", userData[@"data"]);
    }
}


@end
