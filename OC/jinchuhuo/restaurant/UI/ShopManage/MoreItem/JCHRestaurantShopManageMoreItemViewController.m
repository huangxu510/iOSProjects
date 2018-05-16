//
//  JCHRestaurantShopManageMoreItemViewController.m
//  jinchuhuo
//
//  Created by apple on 2016/12/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantShopManageMoreItemViewController.h"
#import "JCHTakeoutBindingViewController.h"
#import "JCHPrinterViewController.h"
#import "JCHSavingCardSettingViewController.h"
#import "JCHBluetoothDeviceViewController.h"
#import "JCHSettlementViewContrller.h"
#import "JCHProductRecordListViewController.h"
#import "JCHCategoryListViewController.h"
#import "JCHUnitListViewController.h"
#import "JCHDeskListViewController.h"
#import "JCHDishesListViewController.h"
#import "JCHDeskModelListViewController.h"
#import "JCHDeskPositionListViewController.h"
#import "JCHMaterialListViewController.h"
#import "JCHCashRegisterListViewController.h"
#import "JCHRestaurantCategoryViewController.h"
#import "JCHSKUTypeListViewController.h"
#import "JCHSettingCollectionViewCell.h"
#import "JCHWarehouseViewController.h"
#import "JCHAddCategoryViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHSettlementManager.h"
#import "CommonHeader.h"
#import "JCHCollectionView.h"
#import <Masonry.h>

enum
{
    kDishesItem      = 0,            // 菜品
    kMaterialItem    = 1,            // 原料
    kDeskItem        = 2,            // 桌台
    kCashDeviceItem  = 3,            // 收银机
    kCategoryItem    = 4,            // 类型
    kSKUItem         = 5,            // 规格
    kSettlementItem  = 6,            // 结算
    kUnitItem        = 7,            // 单位
    kEquipmentItem   = 8,            // 设备
    kSavingCardItem  = 9,            // 储值卡
    kWarehouseItem   = 10,           // 仓库
    kPrinterItem            = 11,           // 打印机
    kTakeoutBindingItem     = 12,           // 外卖绑定
};

@interface JCHRestaurantShopManageMoreItemViewController ()  <UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout>
{
    JCHCollectionView *_contentCollectionView;
}

@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, retain) NSArray *iconArray;
@end


@implementation JCHRestaurantShopManageMoreItemViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        self.title = @"店铺管理";

#if MMR_RESTAURANT_VERSION

        self.titleArray = @[@"菜品", @"原料", @"桌台", @"收银机", @"类型", @"规格", @"结算", @"单位", @"设备", @"储值卡", @"仓库设置", @"", @"", @"", @"", @""];
        self.iconArray  = @[@"mystore_icon_dish", @"mystore_icon_material", @"mystore_icon_table", @"mystore_icon_pos", @"mystore_icon_type", @"mystore_icon_specifications", @"mystore_icon_checkout", @"mystore_icon_unit", @"mystore_icon_copy", @"mystore_icon_storedvaluecard", @"icon_takeout_mystore_whousesetting", @"", @"", @"", @"", @""];
#elif MMR_TAKEOUT_VERSION
        
        self.titleArray = @[@"菜品", @"原料", @"桌台", @"收银机", @"类型", @"规格", @"结算", @"单位", @"蓝牙", @"储值卡", @"仓库设置", @"打印", @"外卖绑定", @"", @"", @""];
        self.iconArray  = @[@"mystore_icon_dish", @"mystore_icon_material", @"mystore_icon_table", @"mystore_icon_pos", @"mystore_icon_type", @"mystore_icon_specifications", @"mystore_icon_checkout", @"mystore_icon_unit", @"icon_takeout_mystore_bluetooth", @"mystore_icon_storedvaluecard", @"icon_takeout_mystore_whousesetting", @"mystore_icon_copy", @"mystore_icon_takeout_bind", @"", @"", @""];
#endif

    }
    
    return self;
}

- (void)dealloc
{
    self.titleArray = nil;
    self.iconArray = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *selectedIndexPaths = [_contentCollectionView indexPathsForSelectedItems];
    
    if (selectedIndexPaths.count > 0) { //点击item后回来
        [_contentCollectionView deselectItemAtIndexPath:selectedIndexPaths[0] animated:YES];
    } else {
        [_contentCollectionView reloadData];
    }
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    //flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, [JCHSizeUtility calculateHeightWithNavigationBar:NO
    //TabBar:YES
    //sourceHeight:35
    //noStretchingIn6Plus:YES]);
    flowLayout.minimumInteritemSpacing = kSeparateLineWidth;
    flowLayout.minimumLineSpacing = kSeparateLineWidth;
    _contentCollectionView = [[[JCHCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    _contentCollectionView.dataSource = self;
    _contentCollectionView.delegate = self;
    _contentCollectionView.alwaysBounceVertical = YES;
    _contentCollectionView.clipsToBounds = NO;
    _contentCollectionView.backgroundColor = JCHColorGlobalBackground;
    
    [_contentCollectionView registerClass:[JCHSettingCollectionViewCell class] forCellWithReuseIdentifier:@"settingCell"];
    
    [self.view addSubview:_contentCollectionView];
    
    [_contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth / 4 - kSeparateLineWidth, kScreenWidth / 4);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSettingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"settingCell"forIndexPath:indexPath];
    cell.titleLabel.text = self.titleArray[indexPath.item];
    
    cell.headImageView.image = [UIImage imageNamed:self.iconArray[indexPath.item]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if ([self.titleArray[indexPath.item] isEmptyString]) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        return;
    }
    
    switch (indexPath.row) {
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
            
        case kUnitItem:
        {
            viewController = [[[JCHUnitListViewController alloc] initWithType:kJCHUnitListTypeNormal] autorelease];
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
            
        case kWarehouseItem:
        {
            viewController = [[[JCHWarehouseViewController alloc] init] autorelease];
        }
            break;
            
        case kCashDeviceItem:
        {
            viewController = [[[JCHCashRegisterListViewController alloc] init] autorelease];
        }
            break;
            
        case kDishesItem:
        {
            viewController = [[[JCHDishesListViewController alloc] init] autorelease];
        }
            break;
            
        case kMaterialItem:
        {
            viewController = [[[JCHMaterialListViewController alloc] init] autorelease];
        }
            break;
            
        case kDeskItem:
        {
            viewController = [[[JCHDeskListViewController alloc] init] autorelease];
        }
            break;
            
#if MMR_TAKEOUT_VERSION
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
#endif
        default:
        {
            // pass
        }
            break;
            
    }
    
    
    if (nil != viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


@end

