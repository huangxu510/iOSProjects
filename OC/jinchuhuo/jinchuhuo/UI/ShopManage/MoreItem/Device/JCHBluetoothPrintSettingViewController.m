//
//  JCHBluetoothPrintSettingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBluetoothPrintSettingViewController.h"
#import "JCHAddProductMainViewController.h"
#import "JCHSwitchTableViewCell.h"
#import "CommonHeader.h"
#import "JCHBluetoothManager.h"
#import "JCHManifestMemoryStorage.h"

//#if !TARGET_OS_SIMULATOR
@interface JCHBluetoothPrintSettingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
}
@property (nonatomic, retain) NSMutableArray *productList;
@end

@implementation JCHBluetoothPrintSettingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.productList = [NSMutableArray array];
        {
            ManifestTransactionDetail *product = [[[ManifestTransactionDetail alloc] init] autorelease];
            product.productName = @"北京方便面";
            product.productPrice = @"2.0";
            product.productCount = @"30";
            product.productDiscount = @"1.0";
            [self.productList addObject:product];
        }
        {
            ManifestTransactionDetail *product = [[[ManifestTransactionDetail alloc] init] autorelease];
            product.productName = @"西凤六年";
            product.productPrice = @"168";
            product.productCount = @"10";
            product.productDiscount = @"1.0";
            [self.productList addObject:product];
        }
#if 0
        {
            ManifestTransactionDetail *product = [[[ManifestTransactionDetail alloc] init] autorelease];
            product.productName = @"森海塞尔mx500";
            product.productPrice = @"500.0";
            product.productCount = @"2";
            product.productDiscount = @"1.0";
            [self.productList addObject:product];
        }
        
        {
            ManifestTransactionDetail *product = [[[ManifestTransactionDetail alloc] init] autorelease];
            product.productName = @"iPhone6sPlus玫瑰金64g";
            product.productPrice = @"6888.0";
            product.productCount = @"1";
            product.productDiscount = @"1.0";
            [self.productList addObject:product];
        }
        
        {
            ManifestTransactionDetail *product = [[[ManifestTransactionDetail alloc] init] autorelease];
            product.productName = @"雷达电蚊香";
            product.productPrice = @"38.0";
            product.productCount = @"3";
            product.productDiscount = @"0.9";
            [self.productList addObject:product];
        }
#endif
    }

    return self;
}

- (void)dealloc
{
    [self.productList release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *testButton = [JCHUIFactory createButton:CGRectMake(0, 0, 80, 40)
                                               target:self
                                               action:@selector(printTest)
                                                title:@"测试打印"
                                           titleColor:nil
                                      backgroundColor:nil];
    testButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:testButton] autorelease];
    
    UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    flexSpacer.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[flexSpacer, editButtonItem];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    //_contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //_contentTableView.tintColor = JCHColorMainBody;
    _contentTableView.sectionIndexColor = JCHColorMainBody;
    _contentTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    _contentTableView.allowsMultipleSelection = YES;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)printTest
{
    JCHManifestMemoryStorage *manifestMemoryStorage = [JCHManifestMemoryStorage sharedInstance];
    manifestMemoryStorage.currentManifestDiscount = 1.0f;
    manifestMemoryStorage.currentManifestID = @"C160415182357-0001-21801";
    manifestMemoryStorage.currentManifestDate = @"2016-05-10 18:23:57";
    manifestMemoryStorage.currentManifestType = 1;
    manifestMemoryStorage.hasPayed = YES;
    
    JCHPrintInfoModel *printInfo = [[[JCHPrintInfoModel alloc] init] autorelease];
    printInfo.manifestType = 1;
    printInfo.manifestID = @"C160415182357-0001-21801";
    printInfo.manifestDate = @"2016-05-10 18:23:57";
    printInfo.manifestDiscount = 1.0;
    printInfo.hasPayed = YES;
    printInfo.transactionList = self.productList;
    
#if MMR_BASE_VERSION
    #if !TARGET_OS_SIMULATOR
        [[JCHBluetoothManager shareInstance] printManifest:printInfo showHud:YES];
    #endif
#else
    JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"模式" message:@"请选择测试打印模式" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"普通版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[JCHBluetoothManager shareInstance] printManifest:printInfo showHud:YES];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"外卖版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [bluetoothManager printTakeoutProductList:self.productList showHud:YES];
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"餐厅版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [bluetoothManager printRestaurantProductList:self.productList showHud:YES];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    
    [self presentViewController:alertController animated:YES completion:nil];
#endif
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[[JCHSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        [cell.statusSwitch addTarget:self
                              action:@selector(changeValue:)
                    forControlEvents:UIControlEventValueChanged];
        cell.statusSwitch.tag = indexPath.row;
    }
    
    NSArray *titles = @[@"出货开单即可打印", @"进货开单即可打印", @"允许在货单详情页打印"];
    cell.titleLabel.text = titles[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
    
    if (indexPath.row == 0) {
        cell.statusSwitch.on = bluetoothManager.canPrintInShipment;
    } else if (indexPath.row == 1) {
        cell.statusSwitch.on = bluetoothManager.canPrintInPurchase;
    } else if (indexPath.row == 2) {
        cell.statusSwitch.on = bluetoothManager.canPrintInManifestDetail;
    } else {
        //pass
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)changeValue:(UISwitch *)sender
{
    JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
    if (sender.tag == 0) {
        bluetoothManager.canPrintInShipment = sender.on;
    } else if (sender.tag == 1) {
        bluetoothManager.canPrintInPurchase = sender.on;
    } else if (sender.tag == 2) {
        bluetoothManager.canPrintInManifestDetail = sender.on;
    }
}

@end
//#endif
