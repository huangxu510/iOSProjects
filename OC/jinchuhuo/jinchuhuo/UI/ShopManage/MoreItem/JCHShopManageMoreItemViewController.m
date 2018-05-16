//
//  JCHShopManageMoreItemViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopManageMoreItemViewController.h"
#import "JCHPrinterViewController.h"
#import "JCHSavingCardSettingViewController.h"
#import "JCHBluetoothDeviceViewController.h"
#import "JCHSettlementViewContrller.h"
#import "JCHProductRecordListViewController.h"
#import "JCHCategoryListViewController.h"
#import "JCHUnitListViewController.h"
#import "JCHCashRegisterListViewController.h"
#import "JCHSKUTypeListViewController.h"
#import "JCHSettingCollectionViewCell.h"
#import "JCHWarehouseViewController.h"
#import "JCHHTMLViewController.h"
#import "JCHSettlementManager.h"
#import "CommonHeader.h"
#import "JCHCollectionView.h"
#import <Masonry.h>

enum
{
    kProductItem            = 0,            // 商品
    kCategoryItem           = 1,            // 类型
    kSKUItem                = 2,            // 规格
    kSettlementItem         = 3,            // 结算
    kUnitItem               = 4,            // 单位
    kBluetoothDeviceItem    = 5,            // 设备
    kSavingCardItem         = 6,            // 储值卡
    kWarehouseItem          = 7,            // 仓库
    kCashDeviceItem         = 8,            // 收银机
};

@interface JCHShopManageMoreItemViewController ()  <UICollectionViewDataSource,
                                                    UICollectionViewDelegate,
                                                    UICollectionViewDelegateFlowLayout>
{
    JCHCollectionView *_contentCollectionView;
}
@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, retain) NSArray *iconArray;
@end
@implementation JCHShopManageMoreItemViewController

- (id)init
{
    self = [super init];
    if (self) {
        // pass
        self.title = @"商品设置";
        self.titleArray = @[@"商品", @"类型", @"规格", @"结算", @"单位", @"蓝牙", @"储值卡", @"仓库", @"收银机", @"", @"", @""];
        self.iconArray  = @[@"mystore_icon_goods",@"mystore_icon_type", @"mystore_icon_specifications", @"mystore_icon_checkout", @"mystore_icon_unit", @"mystore_icon_copy", @"mystore_icon_storedvaluecard", @"mystore_icon_warehouse", @"mystore_icon_pos", @"", @"", @""];
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
    return 12;
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
            
        case kUnitItem:
        {
            viewController = [[[JCHUnitListViewController alloc] initWithType:kJCHUnitListTypeNormal] autorelease];
        }
            break;

//#if !TARGET_OS_SIMULATOR
        case kBluetoothDeviceItem:
        {
            viewController = [[[JCHBluetoothDeviceViewController alloc] init] autorelease];
        }
            break;
//#endif

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
