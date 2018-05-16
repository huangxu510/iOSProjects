//
//  JCHCompatibleDeviceViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCompatibleDeviceViewController.h"
#import "JCHBluetoothDeviceTableViewCell.h"
#import "CommonHeader.h"

static NSString *kBluetoothDeviceTableViewCellID = @"bluetoothDeviceTableViewCellID";

@interface JCHCompatibleDeviceViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *compatibleDevices;

@end

@implementation JCHCompatibleDeviceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"打印机型号";
        self.compatibleDevices = @[@"逊镭（NTEUMM)NT-5802", @"群索 QS-5803", @"佳博 PT-200"];
    }
    return self;
}

- (void)dealloc
{
    self.compatibleDevices = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
}

- (void)createUI
{
    [self.tableView registerClass:[JCHBluetoothDeviceTableViewCell class] forCellReuseIdentifier:kBluetoothDeviceTableViewCellID];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.compatibleDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHBluetoothDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBluetoothDeviceTableViewCellID
                                                                            forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    [cell setTitle:self.compatibleDevices[indexPath.row]];
    [cell setDisconnectButtonHidden:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardItemHeight;
}

@end
