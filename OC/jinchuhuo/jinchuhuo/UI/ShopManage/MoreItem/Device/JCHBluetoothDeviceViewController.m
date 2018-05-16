//
//  JCHBluetoothSettingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#include <TargetConditionals.h>

//#if !TARGET_OS_SIMULATOR

#import "JCHBluetoothDeviceViewController.h"
#import "JCHCompatibleDeviceViewController.h"
#import "JCHBluetoothPrintSettingViewController.h"
#import "JCHBluetoothDeviceTableViewCell.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "MBProgressHUD+JCHHud.h"
#import "NSString+JCHString.h"
#import "JCHBluetoothManager.h"
#import "JCHUserInfoHelper.h"
#import "JCHAddProductMainViewController.h"
#import "JCHBaseTableViewCell.h"
#import "CommonHeader.h"
#import "SEPrinterManager.h"
#import <MJRefresh.h>
#import <Masonry.h>
#import <MSWeakTimer.h>
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *bluttoothDeviceTableViewCellID = @"bluttoothDeviceTableViewCellID";
static NSString *baseTableViewCellID = @"baseTableViewCellID";

@interface JCHBluetoothDeviceViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
}

@property (nonatomic, retain) NSArray *deviceArray;

@end

@implementation JCHBluetoothDeviceViewController

- (void)dealloc
{
    [[SEPrinterManager sharedInstance] setDisconnect:nil];
    [self stopScan];
    self.deviceArray = nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_contentTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"蓝牙设备";
    
    UIBarButtonItem *settingButton = [[[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(setting)] autorelease];
    self.navigationItem.rightBarButtonItem = settingButton;
    
    UIView *topInfoView = [[[UIView alloc] init] autorelease];
    topInfoView.backgroundColor = UIColorFromRGB(0xFFFCF4);
    [self.view addSubview:topInfoView];
    
    [topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [topInfoView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    UIButton *showCompatibleDevicesButton = [JCHUIFactory createButton:CGRectZero
                                                                target:self
                                                                action:@selector(showCompatibleDevices)
                                                                 title:@"查看"
                                                            titleColor:[UIColor whiteColor]
                                                       backgroundColor:UIColorFromRGB(0xFF6400)];
    showCompatibleDevicesButton.titleLabel.font = JCHFont(15.0);
    [topInfoView addSubview:showCompatibleDevicesButton];
    
    [showCompatibleDevicesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topInfoView).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(56.0f);
        make.height.mas_equalTo(28.0f);
        make.centerY.equalTo(topInfoView);
    }];
    
    UILabel *infoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"公告：已为您测试好可正常连接使用的打印机"
                                              font:JCHFont(15.0f)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [topInfoView addSubview:infoLabel];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topInfoView).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(topInfoView);
        make.right.equalTo(showCompatibleDevicesButton.mas_left).with.offset(-kStandardLeftMargin);
    }];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [_contentTableView registerClass:[JCHBluetoothDeviceTableViewCell class] forCellReuseIdentifier:bluttoothDeviceTableViewCellID];
    [_contentTableView registerClass:[JCHBaseTableViewCell class] forCellReuseIdentifier:baseTableViewCellID];
    
    WeakSelf;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshDevice:nil];
    }];
    [header setTitle:@"刷新设备中..." forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    _contentTableView.mj_header = header;
    
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topInfoView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    [printerManager setDisconnect:^(CBPeripheral *perpheral, NSError *error) {
        [weakSelf handleDisconnect:perpheral];
    }];
    
    [self startScan];

#if MMR_TAKEOUT_VERSION
    self.navigationItem.rightBarButtonItem = nil;
#endif
}

- (void)handleDisconnect:(CBPeripheral *)peripheral
{
    NSLog(@"handleDisconnect, %@", [NSThread currentThread]);
    
    BOOL isExit = NO;
    for (CBPeripheral *thePeripheral in self.deviceArray) {
        if ([thePeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            isExit = YES;
            break;
        }
    }
    
    if (!isExit) {
        self.deviceArray = [self.deviceArray arrayByAddingObject:peripheral];
    }
    
    [self -> _contentTableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self stopScan];
}


- (void)refreshDevice:(id)sender
{
    [self stopScan];
    [self startScan];
}

- (void)startScan
{
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    WeakSelf;
    [printerManager startScanPerpheralTimeout:10 Success:^(NSArray<CBPeripheral *> *perpherals, BOOL isTimeout) {
        weakSelf.deviceArray = perpherals;
        [weakSelf -> _contentTableView reloadData];
        [weakSelf -> _contentTableView.mj_header endRefreshing];
    } failure:^(SEScanError error) {
        NSLog(@"error:%ld", (long)error);
    }];
}

- (void)stopScan
{
    [[SEPrinterManager sharedInstance] stopScan];
}


- (void)showCompatibleDevices
{
    JCHCompatibleDeviceViewController *viewController = [[[JCHCompatibleDeviceViewController alloc] init] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - UITableViewDateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray *connectedPerpherals = [[SEPrinterManager sharedInstance] connectedPerpherals];
        if (connectedPerpherals.count == 0) {
            return 1;
        } else {
            return connectedPerpherals.count;
        }
    } else {
        return self.deviceArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
//    CBPeripheral *connectedPerpheral = printerManager.connectedPerpheral;
    NSArray *connectedPerpherals = printerManager.connectedPerpherals;
    if ( indexPath.section == 0) {
        //已连接设备
        if (connectedPerpherals.count != 0 ) {
            JCHBluetoothDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bluttoothDeviceTableViewCellID forIndexPath:indexPath];
            CBPeripheral *connectedPerpheral = connectedPerpherals[indexPath.row];
            [cell setDisconnectBlock:^{
                [printerManager cancelPeripheral:connectedPerpheral];
            }];
            [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
            NSString *peripheralName = @"";
            if (connectedPerpheral.name && ![connectedPerpheral.name isEmptyString]) {
                peripheralName = connectedPerpheral.name;
            } else {
                peripheralName = @"未知设备";
            }
            [cell setTitle:peripheralName];
            [cell setDisconnectButtonHidden:NO];
            
            return cell;
        } else { //未连接设备
            JCHBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:baseTableViewCellID forIndexPath:indexPath];
            cell.textLabel.font = JCHFont(15);
            cell.textLabel.textColor = JCHColorMainBody;
            cell.textLabel.text = @"暂无设备连接";;
            cell.backgroundColor = JCHColorGlobalBackground;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else {
        JCHBluetoothDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bluttoothDeviceTableViewCellID forIndexPath:indexPath];
        
        [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        
        if (indexPath.row < self.deviceArray.count) {
            CBPeripheral *peripheral = self.deviceArray[indexPath.row];
            
            if (peripheral.name && ![peripheral.name isEmptyString]) {
                [cell setTitle:peripheral.name];
            } else {
                [cell setTitle:@"未知设备"];
            }
        }
        
        [cell setDisconnectButtonHidden:YES];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 28)] autorelease];
    UILabel *label = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth - 2 * kStandardLeftMargin, 28) title:@"已经连接的设备" font:[UIFont systemFontOfSize:14.0] textColor:JCHColorAuxiliary aligin:NSTextAlignmentLeft];
    [sectionView addSubview:label];
    if (section == 0) {
        label.text = @"已经连接的设备";
    } else {
        label.text = @"搜索到的设备";
    }
    if (section == 0) {
        SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
        if (printerManager.connectedPerpherals.count != 0) {
            [sectionView addSeparateLineWithFrameTop:YES bottom:YES];
        }
    } else {
        if (self.deviceArray.count > 0) {
            [sectionView addSeparateLineWithFrameTop:NO bottom:YES];
        }
    }
    
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    if (indexPath.section == 0) {
        return;
    }
    
    [MBProgressHUD showHUDWithTitle:@"正在连接..."
                             detail:nil
                           duration:10
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    
    if (indexPath.row < self.deviceArray.count) {
        CBPeripheral *peripheral = self.deviceArray[indexPath.row];
        
        WeakSelf;
        [printerManager connectPeripheral:peripheral completion:^(CBPeripheral *perpheral, NSError *error) {
            if (error) {
                [MBProgressHUD showHUDWithTitle:@"连接失败"
                                         detail:nil
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:^{
                                         [weakSelf -> _contentTableView reloadData];
                                     }];
            } else {
                [MBProgressHUD showHUDWithTitle:@"连接成功"
                                         detail:nil
                                       duration:1.5
                                           mode:MBProgressHUDModeCustomView
                                     completion:^{
                                         
                                         [weakSelf -> _contentTableView reloadData];
                                         JCHUserInfoHelper *userInfoHelper = [JCHUserInfoHelper shareHelper];
                                         NSMutableArray *equipmentInfo = [NSMutableArray arrayWithArray:[userInfoHelper getEquipmentInfo]];
                                         for (NSString *uuid in equipmentInfo) {
                                             if ([uuid isEqualToString:peripheral.identifier.UUIDString]) {
                                                 return;
                                             }
                                         }
                                         
                                         [equipmentInfo addObject:peripheral.identifier.UUIDString];
                                         [[JCHUserInfoHelper shareHelper] setEquipmenInfo:equipmentInfo];
                                     }];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardItemHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

#pragma mark - UIScrollViewDelegate         (sectionView不悬浮)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 28;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


- (void)setting
{
    JCHBluetoothPrintSettingViewController *settingViewController = [[[JCHBluetoothPrintSettingViewController alloc] init] autorelease];
    [self.navigationController pushViewController:settingViewController animated:YES];
}


@end
//#endif
