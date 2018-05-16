//
//  JCHPrinterViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPrinterViewController.h"
#import "JCHPrinterTemplateViewController.h"
#import "JCHPrinterSettingViewController.h"
#import "JCHPrinterTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHPrinterItemModel

- (void)dealloc
{
    self.title = nil;
    self.detail = nil;
    self.imageName = nil;
    
    [super dealloc];
}

@end

@interface JCHPrinterViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSArray *dataSource;

@end

@implementation JCHPrinterViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"打印";
        [self initDataSource];
    }
    return self;
}

- (void)initDataSource
{
    NSArray *titleArray = @[@"小票打印", @"标签打印", @"出入库销货单打印", @"条码打印", @"快递面单打印"];
    NSArray *detailArray = @[@"轻餐、奶茶店等自动打印小票", @"奶茶标签、饭盒标签", @"批发商、工厂、总部配送货适用", @"标准化商品条码管理需求适用", @"商品走物流的出货单适用"];
    NSArray *imageNameArray = @[@"", @"", @"", @"", @""];
    
    NSMutableArray *dataSource = [NSMutableArray array];
    for (NSInteger i = 0; i < 1; i++) {
        JCHPrinterItemModel *model = [[[JCHPrinterItemModel alloc] init] autorelease];
        model.title = titleArray[i];
        model.detail = detailArray[i];
        model.imageName = imageNameArray[i];
        [dataSource addObject:model];
    }
    
    self.dataSource = dataSource;
}

- (void)dealloc
{
    self.dataSource = nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *settingButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                  target:self
                                                  action:@selector(handlerPrinterSetting)
                                                   title:nil
                                              titleColor:nil
                                         backgroundColor:nil];
    [settingButton setImage:[UIImage imageNamed:@"mystore_iconsetting"] forState:UIControlStateNormal];
    
    UIBarButtonItem *settingBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingButton] autorelease];
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = -5;
    
    self.navigationItem.rightBarButtonItems = @[fixedSpace, settingBarButtonItem];
    
    [self.tableView reloadData];
}


- (void)handlerPrinterSetting
{
    JCHPrinterSettingViewController *printerSettingVC = [[[JCHPrinterSettingViewController alloc] init] autorelease];
    [self.navigationController pushViewController:printerSettingVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHPrinterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHPrinterTableViewCell"];
    if (cell == nil) {
        cell = [[[JCHPrinterTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"JCHPrinterTableViewCell"] autorelease];
        cell.arrowImageView.hidden = NO;
    }
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    JCHPrinterItemModel *model = self.dataSource[indexPath.row];
    
    cell.titleLabel.text = model.title;
    cell.detailLabel.text = model.detail;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    switch (indexPath.row) {
        case 0:
        {
            viewController = [[[JCHPrinterTemplateViewController alloc] init] autorelease];
        }
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
