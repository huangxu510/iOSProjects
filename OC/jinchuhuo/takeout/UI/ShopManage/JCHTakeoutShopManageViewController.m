//
//  JCHTakeoutShopManageViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/4.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutShopManageViewController.h"
#import "JCHTakeoutBindingViewController.h"
#import "JCHPrinterViewController.h"
#import "JCHBluetoothDeviceViewController.h"
#import "JCHSavingCardSettingViewController.h"
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
#import "JCHMyTableViewCell.h"
#import "JCHShopAssistantCollectionViewCell.h"
#import "JCHCollectionView.h"
#import "CommonHeader.h"
#import "JCHSyncStatusManager.h"
#import "AppDelegate.h"
#import "JCHShopUtility.h"
#import "ServiceFactory.h"
#import "JCHDisplayNameUtility.h"
#import "JCHDeskListViewController.h"
#import "JCHDishesListViewController.h"
#import "JCHMaterialListViewController.h"
#import "JCHInventoryViewController.h"
#import "JCHCashRegisterListViewController.h"
#import "JCHRestaurantShopManageMoreItemViewController.h"
#import "JCHTakeoutShopStatusSetViewController.h"

enum
{
    kDishesItem             = 0,            // 菜品
    kCategoryItem           = 1,            // 分类
    kUnitItem               = 2,            // 单位
    kSKUItem                = 3,            // 规格
    kSettlementItem         = 4,            // 结算
    kContactsItem           = 5,            // 通讯录
    kSavingCardItem         = 6,            // 储值卡
    kEquipmentItem          = 7,            // 设备
    kPrinterItem            = 8,            // 打印机
    kTakeoutBindingItem     = 9,            // 外卖绑定
};

@interface JCHTakeoutShopManageViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITabBarControllerDelegate>
{
    UILabel *_titleLabel;
    UIButton *_settingButton;
    UIImageView *_topImageView;
    UILabel *_addressLabel;
    
    JCHCollectionView *_contentCollectionView;
    
    UIView *_addedServiceContentView;
    UILabel *_addedServiceInfoLabel;
    UIButton *_openAddedServiceButton;
    
    CGFloat _topImageViewHeight;
    BOOL _appearFromPop;
}
@property (nonatomic, retain) NSArray *dateSource;
@end

@implementation JCHTakeoutShopManageViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        _appearFromPop = NO;
        _topImageViewHeight = kScreenWidth * 460 / 750;
        

        NSArray *titleArray = @[@"菜品", @"类型", @"单位", @"规格", @"结算", @"通讯录", @"储值卡", @"蓝牙", @"打印", @"外卖绑定", @"", @""];
        NSArray *iconArray  = @[@"mystore_icon_dish", @"mystore_icon_type", @"mystore_icon_unit", @"mystore_icon_specifications", @"mystore_icon_checkout", @"mystore_icon_maillist", @"mystore_icon_storedvaluecard", @"icon_takeout_mystore_bluetooth", @"mystore_icon_copy", @"mystore_icon_takeout_bind", @"", @""];
        
        NSMutableArray *dataSource = [NSMutableArray array];
        for (NSInteger i = 0; i < 12; i++) {
            JCHTableViewItemModel *model = [[[JCHTableViewItemModel alloc] init] autorelease];
            model.title = titleArray[i];
            model.iconName = iconArray[i];
            [dataSource addObject:model];
        }
        self.dateSource = dataSource;
        
        [self registerResponseNotificationHandler];
    }
    
    return self;
}

- (void)dealloc
{
    self.dateSource = nil;
    [self unregisterResponseNotificationHandler];
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
    
    [self queryShopInfo];
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
//    flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:NO
//                                                                                                        TabBar:YES
//                                                                                                  sourceHeight:35
//                                                                                           noStretchingIn6Plus:YES]);
    flowLayout.minimumInteritemSpacing = kSeparateLineWidth;
    flowLayout.minimumLineSpacing = kSeparateLineWidth;
    _contentCollectionView = [[[JCHCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    _contentCollectionView.dataSource = self;
    _contentCollectionView.delegate = self;
    _contentCollectionView.alwaysBounceVertical = YES;
    _contentCollectionView.clipsToBounds = NO;
    _contentCollectionView.backgroundColor = JCHColorGlobalBackground;
    _contentCollectionView.contentInset = UIEdgeInsetsMake(_topImageViewHeight, 0, 0, 0);
    
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
        
        
        _openAddedServiceButton = [JCHUIFactory createButton:CGRectZero
                                                      target:self
                                                      action:@selector(handleSetShopStatus)
                                                       title:@"营业中"
                                                  titleColor:[UIColor whiteColor]
                                             backgroundColor:UIColorFromRGB(0xff6400)];
        _openAddedServiceButton.titleLabel.font = [UIFont jchSystemFontOfSize:15.0f];
        [_addedServiceContentView addSubview:_openAddedServiceButton];
        
        [_openAddedServiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_addedServiceContentView).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(70.0f);
            make.height.mas_equalTo(28.0f);
            make.centerY.equalTo(_addedServiceContentView);
        }];
        
        _addedServiceInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"营业时间"
                                                      font:[UIFont jchSystemFontOfSize:13.0f]
                                                 textColor:[UIColor whiteColor]
                                                    aligin:NSTextAlignmentLeft];
        _addedServiceInfoLabel.numberOfLines = 0;
        [_addedServiceContentView addSubview:_addedServiceInfoLabel];
        
        [_addedServiceInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_addedServiceContentView).with.offset(kStandardLeftMargin / 2);
            make.right.equalTo(_openAddedServiceButton.mas_left).with.offset(-kStandardLeftMargin / 2);
            make.top.and.bottom.equalTo(_addedServiceContentView);
        }];
    }
    
    
    _settingButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(handleSetShop)
                                          title:nil
                                     titleColor:nil
                                backgroundColor:nil];
    [_settingButton setImage:[UIImage imageNamed:@"mystore_iconsetting"] forState:UIControlStateNormal];
    [self.view addSubview:_settingButton];
    
    [_settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.width.mas_equalTo(kNavigatorBarHeight);
        make.top.equalTo(self.view).with.offset(kStatusBarHeight);
        make.height.mas_equalTo(kNavigatorBarHeight);
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
        make.right.equalTo(_settingButton.mas_left).with.offset(-kStandardLeftMargin * 3);
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

- (void)queryShopInfo
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
            } else {
                NSLog(@"responseData = %@", responseData);
                
                
                NSDictionary *bookInfo = responseData[@"data"][@"bookInfo"];
                BOOL shopStatus = [bookInfo[@"openStatus"] boolValue];
                NSString *openTime = bookInfo[@"openTime"];
                
                if (shopStatus) {
                    [_openAddedServiceButton setTitle:@"营业中" forState:UIControlStateNormal];
                } else {
                    [_openAddedServiceButton setTitle:@"未营业" forState:UIControlStateNormal];
                }
                
                openTime = [openTime stringByReplacingOccurrencesOfString:@"-" withString:@"至"];
                _addedServiceInfoLabel.text = [NSString stringWithFormat:@"营业时间%@", openTime];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
        }
    }];
}

#pragma mark - 设置店铺营业状态
- (void)handleSetShopStatus
{
    JCHTakeoutShopStatusSetViewController *viewController = [[[JCHTakeoutShopStatusSetViewController alloc] init] autorelease];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    _appearFromPop = YES;
}


- (void)handleSetShop
{
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    
    if (manager.isLogin) {
        if (manager.isShopManager) {
            AppDelegate *theDelegate = [AppDelegate sharedAppDelegate];
            theDelegate.switchToTargetController = self;
            JCHShopSettingViewController *viewController = [[[JCHShopSettingViewController alloc] init] autorelease];
            viewController.shopStatusDetailText = _openAddedServiceButton.currentTitle;
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            _appearFromPop = YES;
        }
    }
}


#pragma mark - ClearData

- (void)clearData
{
    NSLog(@"ClearShopManageData");
    
    [_contentCollectionView reloadData];
}

#pragma mark - LoadData

- (void)loadData
{
    NSLog(@"LoadShopManageData");
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (statusManager.isLogin) {
        
        id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            

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
    return CGSizeMake(kScreenWidth / 4 - kSeparateLineWidth, kScreenWidth / 4);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dateSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHTableViewItemModel *model = self.dateSource[indexPath.row];
    JCHSettingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"settingCell"forIndexPath:indexPath];
    cell.titleLabel.text = model.title;
    
    cell.headImageView.image = [UIImage imageNamed:model.iconName];
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        JCHSettingSectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
//        headerView.moreButton.hidden = YES;
//        [headerView.moreButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
//        [headerView.moreButton removeTarget:self action:@selector(showMoreItem) forControlEvents:UIControlEventTouchUpInside];
//        if (indexPath.section == 0) {
//            headerView.titleLabel.text = @"基础设置";
//        } else {
//            // pass
//        }
//        return headerView;
//    }
//    return nil;
//}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    switch (indexPath.row) {
            
        case kDishesItem:
        {
            viewController = [[[JCHDishesListViewController alloc] init] autorelease];
        }
            break;
            
        case kCategoryItem:
        {
            viewController = [[[JCHCategoryListViewController alloc] initWithType:kJCHCategoryListTypeNormal] autorelease];
        }
            break;
            
        case kUnitItem:
        {
            viewController = [[[JCHUnitListViewController alloc] initWithType:kJCHUnitListTypeNormal] autorelease];
        }
            break;
            
        case kSKUItem:
        {
            viewController = [[[JCHSKUTypeListViewController alloc] init] autorelease];
        }
            break;
            
        case kSettlementItem:
        {
            viewController = [[[JCHSettlementViewContrller alloc] init] autorelease];
        }
            break;
            
        case kContactsItem:
        {
            viewController = [[[JCHAllContactsViewController alloc] init] autorelease];
        }
            break;
            
#if !TARGET_OS_SIMULATOR
        case kEquipmentItem:
        {
            viewController = [[[JCHBluetoothDeviceViewController alloc] init] autorelease];
        }
            break;
#endif
            
        case kSavingCardItem:
        {
            viewController = [[[JCHSavingCardSettingViewController alloc] init] autorelease];
        }
            break;
    
            
        case kPrinterItem:
        {
            viewController = [[[JCHPrinterViewController alloc] init] autorelease];
        }
            break;
            
        case kTakeoutBindingItem:
        {
            viewController = [[[JCHTakeoutBindingViewController alloc] init] autorelease];
        }
            break;
            
        default:
        {
            // pass
        }
            break;
    }
    
    if (nil != viewController) {
        
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        _appearFromPop = YES;
    }
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
    [JCHNotificationCenter addObserver:self selector:@selector(handleShopStatusChanged) name:kTakeoutShopStatusChangedNotification object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    [JCHNotificationCenter removeObserver:self];
}


// 店铺状态改变的通知
- (void)handleShopStatusChanged
{
    if (self.navigationController.tabBarController.selectedIndex == self.navigationController.tabBarController.viewControllers.count - 1 || self.navigationController.viewControllers.count == 1) {
        [self queryShopInfo];
    }
}


@end
