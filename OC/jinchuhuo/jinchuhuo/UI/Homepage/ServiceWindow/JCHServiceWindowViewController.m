//
//  JCHServiceWindowViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHServiceWindowViewController.h"
#import "JCHSettingCollectionViewCell.h"
#import "JCHHTMLViewController.h"
#import "CommonHeader.h"

@implementation JCHServiceWindowModel

- (void)dealloc
{
    self.name = nil;
    self.imageName = nil;
    self.urlString = nil;
    
    [super dealloc];
}

@end


@interface JCHServiceWindowViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    UICollectionView *_collectionView;
}
@property (nonatomic, retain) NSMutableArray *serviceWindowModelList;
@end

@implementation JCHServiceWindowViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"服务窗";
        [self registerResponseNotificationHandler];
        self.serviceWindowModelList = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.serviceWindowModelList = nil;
    [self unregisterResponseNotificationHandler];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:JCHColorHeaderBackground];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *selectedIndexPaths = [_collectionView indexPathsForSelectedItems];
    
    if (selectedIndexPaths.count > 0) { //点击item后回来
        [_collectionView deselectItemAtIndexPath:selectedIndexPaths[0] animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self doQueryServiceWindowInfo];
}

- (void)createUI
{
    UIImageView *banner = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"serviceWindow_banner"]] autorelease];
    [self.view addSubview:banner];
    
    CGFloat bannerHeight = [JCHSizeUtility calculateWidthWithSourceWidth:140];
    [banner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(bannerHeight);
    }];
    
    JCHCollectionViewFlowLayout *flowLayout = [[[JCHCollectionViewFlowLayout alloc] init] autorelease];
    //item 间距
    flowLayout.minimumInteritemSpacing = kSeparateLineWidth;
    flowLayout.maxInteritemSpacing = kSeparateLineWidth;
    
    //行间距
    flowLayout.minimumLineSpacing = kSeparateLineWidth;
    //item 大小
    flowLayout.itemSize = CGSizeMake((kScreenWidth - 2 * kSeparateLineWidth) / 3, (kScreenWidth - 2 * kSeparateLineWidth) / 3);
    
    _collectionView = [[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = JCHColorGlobalBackground;
    [self.view addSubview:_collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(banner.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [_collectionView registerClass:[JCHSettingCollectionViewCell class] forCellWithReuseIdentifier:@"JCHSettingCollectionViewCell"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.serviceWindowModelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSettingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JCHSettingCollectionViewCell" forIndexPath:indexPath];
    JCHServiceWindowModel *model = self.serviceWindowModelList[indexPath.row];
    cell.titleLabel.text = model.name;
    cell.headImageView.image = [UIImage imageNamed:model.imageName];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHServiceWindowModel *model = self.serviceWindowModelList[indexPath.row];
    
    if (model.urlString && ![model.urlString isEmptyString]) {
        JCHHTMLViewController *viewController = [[[JCHHTMLViewController alloc] initWithURL:model.urlString postRequest:NO] autorelease];
        viewController.homeViewController = self;
        if ([model.name isEqualToString:@"钱橙贷"]) {
            viewController.navigationBarColor = UIColorFromRGB(0xfe7600);
        }
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - 查询服务窗内容
- (void)doQueryServiceWindowInfo
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    QueryServiceStatusListRequest *request = [[[QueryServiceStatusListRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.serviceURL = kServiceWindowServiceIP;
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    [dataSyncService queryServiceStatusList:request responseNotification:kJCHQueryServiceWindowInfoNotification];
}

- (void)queryServiceWindowInfo:(NSNotification *)notify
{
    NSDictionary *userData = notify.userInfo;
    NSLog(@"userData = %@", userData);
    
    if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
        
        NSDictionary *responseData = userData[@"data"];
        NSInteger responseCode = [responseData[@"code"] integerValue];
        NSString *responseDescription = responseData[@"desc"];
        NSString *responseStatus = responseData[@"status"];
        
        NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
        
        const NSInteger kTokenInvalidCode = 20200;
        
        if (responseCode == kTokenInvalidCode) {
            //登录失效
            [MBProgressHUD showHUDWithTitle:@""
                                     detail:@"该账号已在其它设备登录，请重新登陆！"
                                   duration:kJCHDefaultShowHudTime
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        } else {
            
            NSArray *list = userData[@"data"][@"data"][@"list"];
            
            for (NSDictionary *dict in list) {
                JCHServiceWindowModel *model = [[[JCHServiceWindowModel alloc] init] autorelease];
                model.name = dict[@"name"];
                model.imageName = dict[@"imgUrl"];
                model.urlString = dict[@"serverHref"];
                model.order = [dict[@"serverOrder"] integerValue];
                [self.serviceWindowModelList addObject:model];
            }
            
            //按照order升序排序
            [self.serviceWindowModelList sortUsingComparator:^NSComparisonResult(JCHServiceWindowModel *obj1, JCHServiceWindowModel *obj2) {
                return obj1.order > obj2.order;
            }];
            
            
            while (self.serviceWindowModelList.count % 3 != 0) {
                JCHServiceWindowModel *model = [[[JCHServiceWindowModel alloc] init] autorelease];
                model.name = @"";
                model.imageName = @"";
                model.urlString = @"";
                [self.serviceWindowModelList addObject:model];
            }
            [_collectionView reloadData];
        }
    }
}

- (void)registerResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(queryServiceWindowInfo:)
                               name:kJCHQueryServiceWindowInfoNotification
                             object:[UIApplication sharedApplication]];
}

- (void)unregisterResponseNotificationHandler
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:kJCHQueryServiceWindowInfoNotification
                                object:[UIApplication sharedApplication]];
}
@end
