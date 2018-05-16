//
//  JCHRestaurantOpenTableViewController.m
//  jinchuhuo
//
//  Created by apple on 2017/1/3.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantOpenTableViewController.h"
#import "JCHRestaurantOpenTableCollectionViewCell.h"
#import "JCHRestuarantReserveViewController.h"
#import "JCHRestaurantModifyDishViewController.h"
#import "JCHRestaurantChooseDishViewController.h"
#import "JCHRestaurantChangeTableViewController.h"
#import "JCHRestaurantDishDetailViewController.h"
#import "JCHCreateManifestViewController.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHCategoryListTableViewCell.h"
#import "JCHSettingCollectionViewCell.h"
#import "JCHRestaurantOpenTableTopView.h"
#import "JCHRestaurantPeopleCountInputView.h"
#import "JCHTableOperationView.h"
#import "JCHSizeUtility.h"
#import "JCHRestaurantManifestUtility.h"
#import "KLCPopup.h"
#import "CommonHeader.h"

enum {
    kAlertViewTagChangeTable = 10001,   // 换桌
    kAlertViewTagCancelTable = 10002,   // 撤台
};

@interface JCHRestaurantOpenTableViewController ()<JCHTableOperationViewDelegate,
                                                    UIAlertViewDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UICollectionViewDelegate,
                                                    UICollectionViewDataSource,
                                                    UICollectionViewDelegateFlowLayout,
                                                    JCHRestaurantPeopleCountInputViewDelegate>
{
    UITableView *leftTableView;
    UICollectionView *contentCollectionView;
    CGFloat leftTableViewWidth;
    NSInteger currentSelectRegionIndex;
    BOOL showAllTableList;
    long long changeFromTableID;
    long long changeToTableID;
    long long cancelTableID;
    JCHRestaurantPeopleCountInputView *countInputView;
    enum JCHRestaurantOpenTableOperationType enumCurrentOperationType;
}

@property (retain, nonatomic, readwrite) NSArray *allRegionList;
@property (retain, nonatomic, readwrite) NSMutableDictionary *allRegionTableMap;
@property (retain, nonatomic, readwrite) NSArray *allTableList;
@property (retain, nonatomic, readwrite) DiningTableRecord4Cocoa *sourceTableRecord;
@property (retain, nonatomic, readwrite) NSIndexPath *countInputCellIndexPath;
@property (retain, nonatomic, readwrite) NSArray *separateLineArray;

@end

@implementation JCHRestaurantOpenTableViewController

- (id)initWithOperationType:(enum JCHRestaurantOpenTableOperationType)enumType
                tableRecord:(DiningTableRecord4Cocoa *)tableRecord
{
    self = [super init];
    if (self) {
        currentSelectRegionIndex = 0;
        enumCurrentOperationType = enumType;
        leftTableViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:73.0f];
        self.sourceTableRecord = tableRecord;
        
        if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeOpenTable) {
            self.title = @"开台";
            showAllTableList = YES;
        } else if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeChangeTable) {
            self.title = @"换台";
            showAllTableList = NO;
        } else {
            // pass
        }
    
        [self loadTableData];
    }
    
    return self;
}

- (void)dealloc
{
    self.allTableList = nil;
    self.allRegionList = nil;
    self.allRegionTableMap = nil;
    self.sourceTableRecord = nil;
    self.countInputCellIndexPath = nil;
    self.separateLineArray = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self createUI];
    [leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    [self changeSeparateLineStatus:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [contentCollectionView reloadData];
}

- (void)loadData
{
    NSMutableArray *regionList = [[[NSMutableArray alloc] init] autorelease];
    for (DiningTableRecord4Cocoa *table in self.allTableList) {
        NSString *regionName = table.regionName;
        BOOL findSame = NO;
        for (NSString *name in regionList) {
            if ([regionName isEqualToString:name]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            [regionList addObject:regionName];
        }
    }
    
    [regionList sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    [regionList insertObject:@"全部" atIndex:0];
    self.allRegionList = regionList;
    
    // 将桌台按区域分类
    NSMutableDictionary *regionTableMap = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *region in regionList) {
        NSMutableArray *tableList = [[[NSMutableArray alloc] init] autorelease];
        for (DiningTableRecord4Cocoa *table in self.allTableList) {
            if ([table.regionName isEqualToString:region]) {
                
                if (YES == showAllTableList) {
                    [tableList addObject:table];
                } else {
                    if (table.tableStatus == kJCHRestaurantOpenTableCollectionViewCellAvaliable) {
                        [tableList addObject:table];
                    }
                }
            }
        }
        
        [tableList sortUsingComparator:^NSComparisonResult(DiningTableRecord4Cocoa *obj1, DiningTableRecord4Cocoa *obj2) {
            return [obj1.tableName compare:obj2.tableName];
        }];
        
        [regionTableMap setObject:tableList forKey:region];
    }
    
    if (showAllTableList) {
        NSMutableArray *tempAllTableList = [NSMutableArray arrayWithArray:self.allTableList];
        [tempAllTableList sortUsingComparator:^NSComparisonResult(DiningTableRecord4Cocoa* obj1, DiningTableRecord4Cocoa* obj2) {
            NSString *obj1FullName = [NSString stringWithFormat:@"%@%@", obj1.regionName, obj1.tableName];
            NSString *obj2FullName = [NSString stringWithFormat:@"%@%@", obj2.regionName, obj2.tableName];
            return [obj1FullName compare:obj2FullName];
        }];
        [regionTableMap setObject:tempAllTableList forKey:@"全部"];
    } else {
        NSMutableArray *allAvaliableTableArray = [[[NSMutableArray alloc] init] autorelease];
        for (DiningTableRecord4Cocoa *table in self.allTableList) {
            if (table.tableStatus == kJCHRestaurantOpenTableCollectionViewCellAvaliable) {
                [allAvaliableTableArray addObject:table];
            }
        }
        
        [allAvaliableTableArray sortUsingComparator:^NSComparisonResult(DiningTableRecord4Cocoa* obj1, DiningTableRecord4Cocoa* obj2) {
            NSString *obj1FullName = [NSString stringWithFormat:@"%@%@", obj1.regionName, obj1.tableName];
            NSString *obj2FullName = [NSString stringWithFormat:@"%@%@", obj2.regionName, obj2.tableName];
            return [obj1FullName compare:obj2FullName];
        }];
        
        [regionTableMap setObject:allAvaliableTableArray forKey:@"全部"];
    }
    
    self.allRegionTableMap = regionTableMap;
    
    [contentCollectionView reloadData];
}

- (void)createUI
{
    if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeOpenTable) {
        UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithTitle:@"只显示空台"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(handleShowOnlyEmptyTable:)] autorelease];
        self.navigationItem.rightBarButtonItem = rightButton;
        UIFont *barItemFont = [UIFont boldSystemFontOfSize:13.0];
        NSDictionary * attributes = @{NSFontAttributeName: barItemFont};
        [rightButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }

    UIView *topView = nil;
    
    if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeOpenTable) {
        topView = [[[JCHRestaurantOpenTableTopView alloc] initWithFrame:CGRectZero] autorelease];
    } else if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeChangeTable) {
        topView = [JCHUIFactory createLabel:CGRectZero
                                      title:[NSString stringWithFormat: @"   当前桌台: %@, 请选择以下桌台进行换台操作",
                                             self.sourceTableRecord.tableName]
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
        topView.backgroundColor = [UIColor whiteColor];
    }
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(35.0);
    }];
    
    if (enumCurrentOperationType  == kJCHRestaurantOpenTableOperationTypeChangeTable) {
        UIView *separateLine = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
        [self.view addSubview:separateLine];
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(topView);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        [self.view bringSubviewToFront:separateLine];
    }
    
    leftTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    leftTableView.dataSource = self;
    leftTableView.delegate = self;
    leftTableView.backgroundColor = JCHColorGlobalBackground;
    leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    leftTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:leftTableView];
    
    [leftTableView registerClass:[JCHCategoryListTableViewCell class] forCellReuseIdentifier:@"JCHCategoryListTableViewCell"];
    
    [leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(topView.mas_bottom);
        make.height.mas_equalTo(kScreenHeight - kTabBarHeight - 64);
        make.width.mas_equalTo(leftTableViewWidth);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    flowLayout.minimumInteritemSpacing = kStandardLeftMargin;
    flowLayout.minimumLineSpacing = kStandardLeftMargin;
    contentCollectionView = [[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    contentCollectionView.dataSource = self;
    contentCollectionView.delegate = self;
    contentCollectionView.alwaysBounceVertical = YES;
    contentCollectionView.clipsToBounds = YES;
    contentCollectionView.contentInset = UIEdgeInsetsMake(kStandardLeftMargin, kStandardLeftMargin, 0, kStandardLeftMargin);
    contentCollectionView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    
    [contentCollectionView registerClass:[JCHRestaurantOpenTableCollectionViewCell class] forCellWithReuseIdentifier:@"JCHRestaurantOpenTableCollectionViewCell"];
    
    [self.view addSubview:contentCollectionView];
    
    [contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom);
        make.bottom.equalTo(self.view);
        make.left.equalTo(leftTableView.mas_right);
        make.right.equalTo(self.view);
    }];
    
    [self createLeftTableViewSeparateLine];
}

#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allRegionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHCategoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHCategoryListTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = self.allRegionList[indexPath.row];
    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.font = JCHFont(15);
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    currentSelectRegionIndex = indexPath.row;
    [contentCollectionView reloadData];
    [self changeSeparateLineStatus: indexPath.row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    JCHCategoryListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

#pragma mark -
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemHeight = (kScreenWidth - leftTableViewWidth - 3 * kSeparateLineWidth - 5 * kStandardLeftMargin) / 4;
    return CGSizeMake(itemHeight, itemHeight);
}

#pragma mark -
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHRestaurantOpenTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JCHRestaurantOpenTableCollectionViewCell"forIndexPath:indexPath];
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][indexPath.item];
    JCHRestaurantOpenTableCollectionViewCellData *cellData = [[[JCHRestaurantOpenTableCollectionViewCellData alloc] init] autorelease];
    id<TableUsageService> usageService = [[ServiceFactory sharedInstance] tableUsageService];
    NSArray<TableUsageRecord4Cocoa *> *tableUsageList = [usageService queryCurrentTableUsage];
    for (TableUsageRecord4Cocoa *usage in tableUsageList) {
        if (usage.tableID == table.tableID) {
            cellData.peopleCount = usage.numOfCustomer;
            break;
        }
    }
    
    cellData.seatCount = table.seatCount;
    cellData.tableName = table.tableName;
    cellData.regionName = table.regionName;
    cellData.enumType = (enum JCHRestaurantOpenTableCollectionViewCellType)table.tableStatus;
    [cell setCellData:cellData];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeOpenTable) {
        DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][indexPath.item];
        if (table.tableStatus == kJCHRestaurantOpenTableCollectionViewCellLock) {
            [self showOpenTableOperationMenu:indexPath];
        } else if (table.tableStatus == kJCHRestaurantOpenTableCollectionViewCellInUse) {
            [self showOpenTableOperationMenu:indexPath];
        } else {
            [self showInputPeopleCount:indexPath];
        }
    } else if (enumCurrentOperationType == kJCHRestaurantOpenTableOperationTypeChangeTable) {
        [self confirmChangeTable:indexPath];
    } else {
        // pass
    }
}

#pragma mark -
#pragma mark 显示改台确认按钮
- (void)confirmChangeTable:(NSIndexPath *)indexPath
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][indexPath.item];
    NSString *alertMessage = [NSString stringWithFormat:@"是否将 %@ 开台信息转移到 %@ ?",
                              self.sourceTableRecord.tableName,
                              table.tableName];
    changeFromTableID = self.sourceTableRecord.tableID;
    changeToTableID = table.tableID;
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"确认换台信息"
                                                         message:alertMessage
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"好的", nil] autorelease];
    alertView.tag = kAlertViewTagChangeTable;
    [alertView show];
}

#pragma mark -
#pragma mark 显示撤台提示
- (void)comfirmCancelTable:(NSInteger )itemIndex
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][itemIndex];
    cancelTableID = table.tableID;
    NSString *alertMessage = [NSString stringWithFormat:@"确认撤台 %@ ?",
                              table.tableName];
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"确认撤台信息"
                                                         message:alertMessage
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"好的", nil] autorelease];
    alertView.tag = kAlertViewTagCancelTable;
    [alertView show];
}

#pragma mark -
#pragma mark 显示弹出菜单
- (void)showOpenTableOperationMenu:(NSIndexPath *)indexPath
{
    CGFloat itemHeight = [JCHSizeUtility calculateWidthWithSourceWidth:65.0];
    NSInteger rowNumber = indexPath.item / 4;
    CGFloat yPos = (rowNumber + 1) * itemHeight + 20 + 44 - contentCollectionView.contentOffset.y + 42;
    CGRect operationViewFrame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    JCHTableOperationView *operationView = [[[JCHTableOperationView alloc] initWithFrame:operationViewFrame
                                                                           contentOffset:yPos
                                                                               cellIndex:indexPath.item
                                                                              leftOffset:leftTableViewWidth] autorelease];
    operationView.delegate = self;
    
    KLCPopup *popup = [KLCPopup popupWithContentView:operationView
                                            showType:KLCPopupShowTypeFadeIn
                                         dismissType:KLCPopupDismissTypeFadeOut
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:YES
                               dismissOnContentTouch:YES];
    [popup show];

}

#pragma mark -
#pragma mark 显示输入就餐人数
- (void)showInputPeopleCount:(NSIndexPath *)indexPath
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][indexPath.item];
    countInputView = [[[JCHRestaurantPeopleCountInputView alloc] initWithFrame:self.view.bounds tableName:table.tableName] autorelease];
    countInputView.delegate = self;
    self.countInputCellIndexPath = indexPath;
    [self.view addSubview:countInputView];
    [self.view bringSubviewToFront:countInputView];
    JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
    memoryStorage.tableID = table.tableID;
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.view addSubview:countInputView];
                    }
                    completion:NULL];
    
}

#pragma mark -
#pragma mark 撤台
- (void)handleCancelTable:(NSInteger)cellIndex
{
    [self comfirmCancelTable:cellIndex];
}

#pragma mark -
#pragma mark 预订
- (void)handleReserveTable:(NSInteger)cellIndex
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][cellIndex];
    JCHRestuarantReserveViewController *viewController = [[[JCHRestuarantReserveViewController alloc] initWithTableRecord:table] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark 点菜
- (void)handleChooseDish:(NSInteger)cellIndex
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][cellIndex];
    if (table.tableStatus == kJCHRestaurantOpenTableCollectionViewCellInUse) {
        [self handleChangeManifest:cellIndex];
    } else if (table.tableStatus == kJCHRestaurantOpenTableCollectionViewCellLock) {
        [self handleChooseDishImplement:cellIndex];
    } else {
        [self handleChooseDishImplement:cellIndex];
    }
}

- (void)handleChooseDishImplement:(NSInteger)cellIndex
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][cellIndex];
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<DiningTableService> tableService = [[ServiceFactory sharedInstance] diningTableService];
    NSInteger numberOfPerson = manifestStorage.restaurantPeopleCount;
    [manifestStorage clearData];
    
    manifestStorage.currentManifestID = [manifestService createManifestID:kJCHOrderShipment];
    manifestStorage.currentManifestDate = [JCHManifestUtility getOrderDate];
    manifestStorage.currentManifestDiscount = 1.0f;
    manifestStorage.currentManifestType = kJCHOrderShipment;
    manifestStorage.tableID = table.tableID;
    manifestStorage.restaurantPeopleCount = numberOfPerson;
    manifestStorage.tableName = [[tableService qeryDiningTable:table.tableID] tableName];
    manifestStorage.enumRestaurantManifestType = kJCHRestaurantOpenTable;
    
    JCHAddProductMainViewController *addProductViewController = [[[JCHAddProductMainViewController alloc] init] autorelease];
    addProductViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addProductViewController animated:YES];
}

#pragma mark -
#pragma mark 换台
- (void)handleChangeTable:(NSInteger)cellIndex
{
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][cellIndex];
    JCHRestaurantOpenTableViewController *changeTableController = [[[JCHRestaurantOpenTableViewController alloc] initWithOperationType:kJCHRestaurantOpenTableOperationTypeChangeTable tableRecord:table] autorelease];
    [self.navigationController pushViewController:changeTableController animated:YES];
}

#pragma mark -
#pragma mark 改单
- (void)handleChangeManifest:(NSInteger)cellIndex
{
    id<TableUsageService> tableUsageService = [[ServiceFactory sharedInstance] tableUsageService];
    DiningTableRecord4Cocoa *table = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][cellIndex];
    BOOL isTableAvaliable = [tableUsageService isTableAvailable:table.tableID];
    if (YES == isTableAvaliable) {
        [self handleChooseDish:cellIndex];
    } else {
        [self handleChangeManifestImplement:cellIndex];
    }
}

- (void)handleChangeManifestImplement:(NSInteger)cellIndex
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<TableUsageService> tableUsageService = [[ServiceFactory sharedInstance] tableUsageService];
    DiningTableRecord4Cocoa *currentTable = self.allRegionTableMap[self.allRegionList[currentSelectRegionIndex]][cellIndex];
    NSArray *allOpenTableList = [tableUsageService queryCurrentTableUsage];
    NSString *manifestID = nil;
    NSInteger numOfCustomer = 0;
    for (TableUsageRecord4Cocoa *table in allOpenTableList) {
        if (table.tableID == currentTable.tableID) {
            manifestID = table.orderID;
            numOfCustomer = table.numOfCustomer;
            break;
        }
    }
    
    if (nil != manifestID && (NO == [manifestID isEqualToString:@""])) {
        ManifestRecord4Cocoa *manifestRecord = [manifestService queryPreInsertManifest:manifestID];
        [self makeSureEditManifest:manifestRecord
                       warehouseID:@"0"
                           tableID:currentTable.tableID
                       personCount:numOfCustomer];
    } else {
        [self handleChooseDish:cellIndex];
    }
}

#pragma mark -
#pragma mark 只显示空台
- (void)handleShowOnlyEmptyTable:(UIBarButtonItem *)sender
{
    if (showAllTableList) {
        showAllTableList = NO;
        sender.title = @"显示所有桌台";
        [self loadData];
    } else {
        showAllTableList = YES;
        sender.title = @"只显示空台";
        [self loadData];
    }
}

#pragma mark -
#pragma mark 加载桌台数据
- (void)loadTableData
{
    id<TableUsageService> usageService = [[ServiceFactory sharedInstance] tableUsageService];
    NSArray *tableUsageList = [usageService queryCurrentTableUsage];
    id<DiningTableService> tableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray<TableTypeRecord4Cocoa *> *tableTypeList = [tableService queryTableType];
    NSArray *tableList = [tableService queryDiningTable];
    for (DiningTableRecord4Cocoa *table in tableList) {
        for (TableTypeRecord4Cocoa *tableType in tableTypeList) {
            if (tableType.typeID == table.typeID) {
                NSString *typeString = tableType.typeName;
                typeString = [typeString stringByReplacingOccurrencesOfString:@"人" withString:@""];
                typeString = [typeString stringByReplacingOccurrencesOfString:@"以上" withString:@""];
                NSArray *tokens = [typeString componentsSeparatedByString:@"~"];
                table.seatCount = [tokens.lastObject integerValue];
                break;
            }
        }
        
        for (TableUsageRecord4Cocoa *usage in tableUsageList) {
            if (usage.tableID == table.tableID) {
                if (usage.orderID != nil &&
                    ![usage.orderID isEqualToString:@""]) {
                    table.tableStatus = kJCHRestaurantOpenTableCollectionViewCellInUse;
                } else {
                    table.tableStatus = kJCHRestaurantOpenTableCollectionViewCellLock;
                }
                
                break;
            }
        }
    }
    self.allTableList = tableList;
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTagChangeTable) {
        // 换桌
        switch (buttonIndex) {
            case 0:
            {
                // 取消
            }
                break;
                
            case 1:
            {
                // 确定
                JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
                id<RestaurantTableService> tableService = [[ServiceFactory sharedInstance] restaurantTableService];
                NSString *tableServiceHost = [bookInfoService queryLocalServerHost];
                
                if (nil == tableServiceHost ||
                    [tableServiceHost isEqualToString:@""]) {
                    [JCHRestaurantManifestUtility handleNoBindMachineError];
                    return;
                }
                
                RestaurantChangeTable *request = [[[RestaurantChangeTable alloc] init] autorelease];
                request.accountBookID = statusManager.accountBookID;
                request.tableID = [@(changeToTableID) stringValue];
                request.oldTableID = [@(changeFromTableID) stringValue];
                request.manifestID = [[JCHManifestMemoryStorage sharedInstance] currentManifestID];
                request.operatorID = [statusManager.userID integerValue];
                request.serviceURL = [NSString stringWithFormat:@"%@/book/table/change", tableServiceHost];
                
                [tableService changeTable:request callback:^(id response) {
                    NSLog(@"%@", response);
                }];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
                
            default:
                break;
        }
    } else if (alertView.tag == kAlertViewTagCancelTable) {
        // 撤台
        switch (buttonIndex) {
            case 0:
            {
                // 取消
            }
                break;
                
            case 1:
            {
                // 确定
                id<BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
                id<RestaurantTableService> tableService = [[ServiceFactory sharedInstance] restaurantTableService];
                NSString *tableServiceHost = [bookInfoService queryLocalServerHost];
                JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
                
                if (nil == tableServiceHost ||
                    [tableServiceHost isEqualToString:@""]) {
                    [JCHRestaurantManifestUtility handleNoBindMachineError];
                    return;
                }
                
                RestaurantReleaseTable *request = [[[RestaurantReleaseTable alloc] init] autorelease];
                request.accountBookID = statusManager.accountBookID;
                request.tableID = [@(cancelTableID) stringValue];
                request.operatorID = [statusManager.userID integerValue];
                request.serviceURL = [NSString stringWithFormat:@"%@/book/table/release", tableServiceHost];
                [tableService releaseTable:request callback:^(id response) {
                    NSLog(@"%@", response);
                }];
                
                [contentCollectionView reloadData];
            }
                break;
                
            default:
                break;
        }
    }

}

- (void)makeSureEditManifest:(ManifestRecord4Cocoa *)manifestRecord
                 warehouseID:(NSString *)warehouseID
                     tableID:(long long)tableID
                 personCount:(NSInteger)numOfCustomer
{
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    appDelegate.switchToTargetController = self;
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    id<DiningTableService> tableService = [[ServiceFactory sharedInstance] diningTableService];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    manifestStorage.manifestMemoryType = kJCHManifestMemoryTypeEdit;
    manifestStorage.currentManifestID = manifestRecord.manifestID;
    manifestStorage.currentManifestDate = [NSString stringFromSeconds:manifestRecord.manifestTimestamp dateStringType:kJCHDateStringType5];
    manifestStorage.currentManifestType = (enum JCHOrderType)manifestRecord.manifestType;
    manifestStorage.currentManifestRemark = manifestRecord.manifestRemark;
    manifestStorage.currentManifestDiscount = manifestRecord.manifestDiscount;
    manifestStorage.currentManifestEraseAmount = manifestRecord.eraseAmount;
    manifestStorage.isRejected = ![JCHFinanceCalculateUtility floatValueIsZero:manifestRecord.eraseAmount];
    manifestStorage.hasPayed = manifestRecord.hasPayed;
    manifestStorage.warehouseID = warehouseID;
    manifestStorage.tableID = tableID;
    manifestStorage.tableName = [[tableService qeryDiningTable:tableID] tableName];
    manifestStorage.restaurantPeopleCount = numOfCustomer;
    
    //联系人UUID
    NSString *defaultBuyerUUID = [manifestService getDefaultCustomUUID];
    NSString *defaultSellerUUID = [manifestService getDefaultSupplierUUID];
    NSString *contactUUID = nil;
    if (manifestRecord.manifestType == kJCHOrderPurchases && ![manifestRecord.sellerUUID isEqualToString:defaultSellerUUID]) {
        contactUUID = manifestRecord.sellerUUID;
    } else if (manifestRecord.manifestType == kJCHOrderShipment && ![manifestRecord.buyerUUID isEqualToString:defaultBuyerUUID  ]) {
        contactUUID = manifestRecord.buyerUUID;
    } else {
        //pass
    }
    
    if (contactUUID) {
        ContactsRecord4Cocoa *contactRecord = [contactsService queryContacts:contactUUID];
        manifestStorage.currentContactsRecord = contactRecord;
    } else {
        manifestStorage.currentContactsRecord = nil;
    }
    
    
    for (ManifestTransactionRecord4Cocoa *transactionRecord in manifestRecord.manifestTransactionArray) {
        ManifestTransactionDetail *transactionDetail = [[[ManifestTransactionDetail alloc] init] autorelease];
        transactionDetail.productCategory    = transactionRecord.productCategory;
        transactionDetail.productName        = transactionRecord.productName;
        transactionDetail.productImageName   = transactionRecord.productImageName;
        transactionDetail.productUnit        = transactionRecord.productUnit;
        transactionDetail.productCount       = [NSString stringFromCount:transactionRecord.productCount unitDigital:transactionRecord.unitDigits];;
        transactionDetail.productPrice       = [NSString stringWithFormat:@"%.2f", transactionRecord.productPrice];
        transactionDetail.productDiscount    = [NSString stringWithFormat:@"%.2f", transactionRecord.productDiscount];
        transactionDetail.productUnit_digits = transactionRecord.unitDigits;
        transactionDetail.warehouseUUID      = transactionRecord.warehouseUUID;
        transactionDetail.transactionUUID    = transactionRecord.transactionUUID;
        transactionDetail.unitUUID           = transactionRecord.unitUUID;
        transactionDetail.goodsNameUUID      = transactionRecord.goodsNameUUID;
        transactionDetail.goodsCategoryUUID  = transactionRecord.goodsCategoryUUID;
        
        //transactionDetail.productInventoryCount
        
        
        GoodsSKURecord4Cocoa *skuRecord = nil;
        [skuService queryGoodsSKU:transactionRecord.goodsSKUUUID skuArray:&skuRecord];
        
        NSMutableArray *skuValueRecordArray = [NSMutableArray array];
        for (NSDictionary *dict in skuRecord.skuArray) {
            [skuValueRecordArray addObject:[dict allValues][0]];
        }
        NSDictionary *skuDict = [JCHTransactionUtility getTransactionsWithData:skuValueRecordArray];
        transactionDetail.skuValueUUIDs = [skuDict allKeys][0][0];
        
        if (skuRecord.skuArray.count == 0) {
            transactionDetail.skuValueCombine = @"";
        } else {
            transactionDetail.skuValueCombine = [skuDict allValues][0][0];
        }
        
        id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
        ProductRecord4Cocoa *productRecord = [productService queryProductByUUID:transactionRecord.goodsNameUUID];
        transactionDetail.skuHidenFlag = productRecord.sku_hiden_flag;
        
        [manifestStorage addManifestRecord:transactionDetail];
    }
    
    manifestStorage.restaurantPreInsertManifestArray = [manifestStorage getAllManifestRecord];
    if (nil == manifestStorage.restaurantPreInsertManifestArray) {
        manifestStorage.restaurantPreInsertManifestArray = @[];
    }
    
    JCHCreateManifestViewController *manifestViewController = [[[JCHCreateManifestViewController alloc] init] autorelease];
    manifestViewController.hidesBottomBarWhenPushed = YES;
    
    // JCHManifestListTableViewCell *cell = [contentTableView cellForRowAtIndexPath:currentIndexPath];
    [self.navigationController pushViewController:manifestViewController animated:YES completion:^{
        // [cell hideUtilityButtonsAnimated:NO];
    }];
}

#pragma mark -
#pragma mark JCHRestaurantPeopleCountInputViewDelegate
- (void)countInputViewDidHide:(JCHRestaurantPeopleCountInputView *)keyboardView
{
    [UIView animateWithDuration:0.5 animations:^ {
        keyboardView.alpha = 0.0;
    } completion:^(BOOL finished) {
        NSString *inputText = [keyboardView getInputString];
        [keyboardView removeFromSuperview];
        
        if (inputText.integerValue > 0) {
            JCHManifestMemoryStorage *memoryStorage = [JCHManifestMemoryStorage sharedInstance];
            memoryStorage.restaurantPeopleCount = inputText.integerValue;
            
            [JCHRestaurantManifestUtility restaurantLockTable:memoryStorage.tableID successHandler:^{
//                [MBProgressHUD showHUDWithTitle:@"温馨提示"
//                                         detail:@"锁定桌台成功，请进行数据同步操作"
//                                       duration:3
//                                           mode:MBProgressHUDModeIndeterminate
//                                     completion:nil];
                [MBProgressHUD hideAllHudsForWindow];
                [self showOpenTableOperationMenu:self.countInputCellIndexPath];
            } failureHandler:^(NSString *errorMessage){
                [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                         detail:[NSString stringWithFormat:@"锁定桌台失败: %@，请重试", errorMessage]
                                       duration:3
                                           mode:MBProgressHUDModeIndeterminate
                                     completion:nil];
            }];
        }
    }];

}

- (void)createLeftTableViewSeparateLine
{
    UIView *verticalSeparateLine = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self.view addSubview:verticalSeparateLine];
    [verticalSeparateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(leftTableView);
        make.right.equalTo(leftTableView);
        make.width.mas_equalTo(kSeparateLineWidth);
    }];
    
    NSMutableArray *lineArray = [[[NSMutableArray alloc] init] autorelease];
    NSInteger lineCount = self.allRegionTableMap.count;
    for (NSInteger i = 0; i < lineCount; ++i) {
        UIView *lineView = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
        [verticalSeparateLine addSubview:lineView];
        lineView.backgroundColor = UIColorFromRGB(0XF8F8F8);
        [lineArray addObject:lineView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.width.equalTo(verticalSeparateLine);
            make.height.mas_equalTo(40);
            make.top.equalTo(verticalSeparateLine).offset(i * 40);
        }];
    }
    
    self.separateLineArray = lineArray;
}

- (void)changeSeparateLineStatus:(NSInteger)cellIndex
{
    for (NSInteger i = 0; i < self.separateLineArray.count; ++i) {
        UIView *line = self.separateLineArray[i];
        if (i != cellIndex) {
            line.backgroundColor = JCHColorSeparateLine;
        } else {
            line.backgroundColor = UIColorFromRGB(0XF8F8F8);
        }
    }
}

@end
