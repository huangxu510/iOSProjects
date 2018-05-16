//
//  JCHShopSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/27.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopSelectViewController.h"
#import "JCHShopSelectTableViewCell.h"
#import "JCHBarCodeScannerViewController.h"
#import "CommonHeader.h"

@interface JCHShopSelectViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) NSArray *accountBookList;
@property (nonatomic, assign) BOOL showBackButton;
@end

@implementation JCHShopSelectViewController

- (instancetype)initWithBackButton:(BOOL)showBackButton
{
    self = [super init];
    if (self) {
        self.showBackButton = showBackButton;
        [JCHNotificationCenter addObserver:self selector:@selector(joinShopCompletion) name:kSwitchToShopAssistantHomepageNotification object:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择店铺";
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.enableAutoSync = NO;
    statusManager.isLogin = NO;
    [JCHSyncStatusManager writeToFile];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self createUI];
    [self loadData];
}

- (void)dealloc
{
    [JCHNotificationCenter removeObserver:self name:kSwitchToShopAssistantHomepageNotification object:nil];
    self.accountBookList = nil;
    [super dealloc];
}

- (void)createUI
{
    UIButton *scanButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                               target:self
                                               action:@selector(scanBarCode)
                                                title:nil
                                           titleColor:nil
                                      backgroundColor:nil];
    [scanButton setImage:[UIImage imageNamed:@"homepage_scan"] forState:UIControlStateNormal];
    UIBarButtonItem *scanItem = [[[UIBarButtonItem alloc] initWithCustomView:scanButton] autorelease];
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = -5;
    self.navigationItem.rightBarButtonItems = @[fixedSpace, scanItem];
    [self.tableView registerClass:[JCHShopSelectTableViewCell class] forCellReuseIdentifier:@"JCHShopSelectTableViewCell"];
    
    if (!self.showBackButton) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.hidesBackButton = YES;
    }
}

- (void)loadData
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSArray *allAccountBookList = [ServiceFactory getAllAccountBookList:statusManager.userID];
    NSMutableArray *accountBookList = [NSMutableArray array];
    for (BookInfoRecord4Cocoa *bookInfo in allAccountBookList) {
        if (![bookInfo.bookType isEqualToString:kJCHDefaultShopType]) {
            [accountBookList addObject:bookInfo];
        }
    }
    
    NSMutableArray *enableAccountBookList = [NSMutableArray array];
    NSMutableArray *disableAccountBookList = [NSMutableArray array];
    for (BookInfoRecord4Cocoa *bookInfo in accountBookList) {
        if (bookInfo.bookStatus == 0) {
            [enableAccountBookList addObject:bookInfo];
        } else {
            [disableAccountBookList addObject:bookInfo];
        }
    }
    
    NSMutableArray *accountBookListForSection = [NSMutableArray array];
    if (enableAccountBookList.count > 0) {
        [accountBookListForSection addObject:enableAccountBookList];
    }
    
    if (disableAccountBookList.count > 0) {
        [accountBookListForSection addObject:disableAccountBookList];
    }
    self.accountBookList = accountBookListForSection;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.accountBookList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.accountBookList[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHShopSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHShopSelectTableViewCell"];
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    BookInfoRecord4Cocoa *bookInfo = self.accountBookList[indexPath.section][indexPath.row];
  
    JCHShopSelectTableViewCellData *data = [[[JCHShopSelectTableViewCellData alloc] init] autorelease];
 
    if (indexPath.section == 0) {
        data.shopIconName = [NSString stringWithFormat:@"img_store_%ld", indexPath.row + 1];
        //有一种特殊情况，当只有一个店时，并且该店被禁用
        if (self.accountBookList.count == 1 && [self.accountBookList[0][0] bookStatus] == 1) {
            data.shopIconName = @"img_store_disabled";
        }
    } else if (indexPath.section == 1) {
        data.shopIconName = @"img_store_disabled";
    } else {
        //pass
    }
      //[UIImage jchAvatarImageNamed:bookInfo.shopImageName];
    data.shopName = bookInfo.bookName;
    data.shopManagerName = bookInfo.bookAddress;
    data.status = bookInfo.bookStatus;
    
    [cell setCellData:data];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHSeparateLineSectionView *sectionView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    sectionView.frame = CGRectMake(0, 0, kScreenWidth, 20);
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookInfoRecord4Cocoa *bookInfo = self.accountBookList[indexPath.section][indexPath.row];

    if (bookInfo.bookStatus == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }

    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [appDelegate switchToSelectedAccountBook:bookInfo.bookID currentViewController:self completion:nil];
}

- (void)scanBarCode
{
    JCHBarCodeScannerViewController *barCodeScanerVC = [[[JCHBarCodeScannerViewController alloc] init] autorelease];
    barCodeScanerVC.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    barCodeScanerVC.barCodeBlock = ^(NSString *code){
        [appDelegate.homePageController handleFinishScanQRCode:code
                                                   joinAccount:YES
                                                  authorizePad:NO
                                                      loginPad:NO];
    };
    [self presentViewController:barCodeScanerVC animated:YES completion:nil];
}

- (void)joinShopCompletion
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    statusManager.enableAutoSync = YES;
    statusManager.isShopManager = NO;
    statusManager.isLogin = YES;
    
    id<PermissionService> permissionService = [[ServiceFactory sharedInstance] permissionService];
    RoleRecord4Cocoa *roleRecord =  [permissionService queryRoleWithByUserID:statusManager.userID];
    statusManager.roleRecord = roleRecord;

    [JCHSyncStatusManager writeToFile];
    

    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    UINavigationController *rootNav = [AppDelegate sharedAppDelegate].rootNavigationController;
    UITabBarController *tabBarController = rootNav.viewControllers[0];
    [rootNav setViewControllers:@[tabBarController, [AppDelegate sharedAppDelegate].shopAssistantHomepageViewController] animated:NO];
}

@end
