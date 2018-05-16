//
//  JCHSetInitialInventoryViewController.m
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSetInitialInventoryViewController.h"
#import "JCHUnitSpecificationInventorySectionView.h"
#import "JCHUnitSpecificationInventoryTableViewCell.h"
#import "JCHScrollMenu.h"
#import "CommonHeader.h"


@interface JCHSetInitialInventoryViewController ()<JCHScrollMenuDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UITextFieldDelegate>
{
    JCHScrollMenu *topMenuView;
    UITableView *contentTableView;
    enum SetInitialInventoryType currentInventoryType;
    NSInteger currentWarehouseIndex;
    enum SetInitialInventoryOperation currentInventoryOperation;
}

@property (retain, nonatomic, readwrite) NSArray<JCHBeginInventoryForSKUViewData *> *currentInventoryList;
@property (retain, nonatomic, readwrite) NSArray<ProductUnitRecord *> *currentUnitList;
@property (retain, nonatomic, readwrite) UnitRecord4Cocoa *currentMainUnit;
@property (retain, nonatomic, readwrite) NSArray<NSString *> *warehouseNameList;

@end


@implementation JCHSetInitialInventoryViewController

- (id)initWithType:(enum SetInitialInventoryType)enumInventoryType
          mainUnit:(UnitRecord4Cocoa *)mainUnit
     inventoryList:(NSArray<JCHBeginInventoryForSKUViewData *> *)inventoryList
          unitList:(NSArray<ProductUnitRecord *> *)unitList
     operationType:(enum SetInitialInventoryOperation)operationType
{
    self = [super init];
    if (self) {
        self.title = @"期初库存";
        currentWarehouseIndex = 0;
        currentInventoryType = enumInventoryType;
        self.currentInventoryList = inventoryList;
        self.currentUnitList = unitList;
        self.currentMainUnit = mainUnit;
        currentInventoryOperation = operationType;
        
        for (JCHBeginInventoryForSKUViewData *record in self.currentInventoryList) {
            record.copyPrice = record.price;
            record.copyCount = record.count;
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.warehouseNameList = nil;
    [self.currentInventoryList release];
    [self.currentUnitList release];
    [self.currentMainUnit release];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    NSArray<WarehouseRecord4Cocoa *> *warehouseList = [warehouseService queryAllWarehouse];
    
    NSMutableArray *nameList = [[[NSMutableArray alloc] init] autorelease];
    for (JCHBeginInventoryForSKUViewData *data in self.currentInventoryList) {
        BOOL findSame = NO;
        for (NSString *name in nameList) {
            if ([name isEqualToString:data.warehouseName]) {
                findSame = YES;
                break;
            }
        }
        
        if (NO == findSame) {
            BOOL enableWarehouseStatus = YES;
            for (WarehouseRecord4Cocoa *warehouse in warehouseList) {
                if ([warehouse.warehouseName isEqualToString:data.warehouseName]) {
                    enableWarehouseStatus = (warehouse.warehouseStatus == 0);
                    break;
                }
            }
            
            if (enableWarehouseStatus) {
                [nameList addObject:data.warehouseName];
            }
        }
    }
    
    self.warehouseNameList = nameList;
    
    [self createUI];
    
    // 如果是修改商品，同不允许修改期初库存
    if (currentInventoryOperation == kInitialInventoryModify) {
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"期初库存不支持修改操作"
                               duration:3
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }
    
    
    return;
}

- (void)createUI
{
    if (currentInventoryOperation == kInitialInventoryCreate) {
        UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(handleSaveInventory:)] autorelease];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    topMenuView = [[[JCHScrollMenu alloc] initWithFrame:CGRectZero menuTitles:self.warehouseNameList] autorelease];
    [self.view addSubview:topMenuView];
    topMenuView.delegate = self;
    
    CGFloat topMenuHeight = 0.0;
    if (0 != self.currentInventoryList.count) {
        topMenuHeight = kStandardItemHeight;
    }
    
    [topMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(topMenuHeight);
    }];
    
    UIView *seperateView = [JCHUIFactory createSeperatorLine:kStandardSeparateViewHeight];
    [self.view addSubview:seperateView];
    seperateView.backgroundColor = JCHColorGlobalBackground;
    [seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topMenuView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(kStandardSeparateViewHeight);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.allowsSelection = NO;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(seperateView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.and.right.equalTo(self.view);
        
    }];
    
    return;
}

#pragma mark -
#pragma mark 顶部按钮选中事件
- (void)handleClickScrollMenu:(NSNumber *)menuIndex
{
    currentWarehouseIndex = menuIndex.integerValue;
    [contentTableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == self.warehouseNameList.count) {
        return 0;
    }
    
    NSInteger inventoryCount = 0;
    NSString *warehouseName = self.warehouseNameList[currentWarehouseIndex];
    for (JCHBeginInventoryForSKUViewData *data in self.currentInventoryList) {
        if ([data.warehouseName isEqualToString:warehouseName]) {
            inventoryCount = inventoryCount +1;
        }
    }
    
    return inventoryCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardItemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kReuseIdentifier = @"kReuseIdentifier";
    JCHUnitSpecificationInventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (nil == cell) {
        cell = [[[JCHUnitSpecificationInventoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier] autorelease];
    }
    
    NSInteger inventoryIndex = -1;
    JCHBeginInventoryForSKUViewData *record = nil;
    NSString *warehouseName = self.warehouseNameList[currentWarehouseIndex];
    for (JCHBeginInventoryForSKUViewData *data in self.currentInventoryList) {
        if ([data.warehouseName isEqualToString:warehouseName]) {
            inventoryIndex = inventoryIndex +1;
            if (inventoryIndex == indexPath.row) {
                record = data;
                break;
            }
        }
    }
    
    NSString *cellTitle = record.skuCombine;
    NSString *unitName = self.currentMainUnit.unitName;
    if (kInitialInventoryForMainUnit == currentInventoryType) {
        unitName = record.skuCombine;
        
        if ([self.currentMainUnit.unitName isEqualToString:record.skuCombine]) {
            cellTitle = [NSString stringWithFormat:@"%@(主单位)", record.skuCombine];
        } else {
            for (ProductUnitRecord *unit in self.currentUnitList) {
                if ([unit.unitRecord.unitName isEqualToString:record.skuCombine]) {
                    cellTitle = [NSString stringWithFormat:@"%@(%@%@)",
                                 unit.unitRecord.unitName,
                                 [NSString stringFromCount:unit.convertRatio
                                               unitDigital:unit.unitRecord.unitDecimalDigits],
                                 self.currentMainUnit.unitName];
                    break;
                }
            }
        }
    }

    JCHUnitSpecificationInventoryTableViewCellData *cellData = [[JCHUnitSpecificationInventoryTableViewCellData new] autorelease];
    cellData.cellTitle = cellTitle;
    cellData.pricePlaceholderText = @"¥0.00";
    cellData.priceText = [NSString stringWithFormat:@"%.2f", record.copyPrice];
    cellData.countPlaceholderText = [NSString stringWithFormat:@"%@%@",
                                     [NSString stringFromCount:0 unitDigital:record.unitDigital],
                                     unitName];
    cellData.countText = [NSString stringFromCount:record.copyCount unitDigital:record.unitDigital];
    cellData.cellTag = record;
    
    [cell setCellData:cellData
    textfieldDelegate:self
     isLastCell:indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)];
    
    if (currentInventoryOperation == kInitialInventoryModify) {
        [cell enableEditCellContent:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect viewFrame = CGRectMake(0, 0, kScreenWidth, 30.0);
    NSArray *titles = nil;
    if (currentInventoryType == kInitialInventoryForWithSKU ||
        currentInventoryType == kInitialInventoryForMainUnit) {
        titles = @[@"单品", @"期初库存", @"期初单价"];
    } else {
        titles = @[@"商品", @"期初库存", @"期初单价"];
    }
    
    UIView *headerView = [[[JCHUnitSpecificationInventorySectionView alloc] initWithFrame:viewFrame titles:titles] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}


#pragma mark -
#pragma mark 完成
- (void)handleSaveInventory:(id)sender
{
    [self.view endEditing:NO];
    
    for (JCHBeginInventoryForSKUViewData *record in self.currentInventoryList) {
        record.price = record.copyPrice;
        record.count = record.copyCount;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    JCHTagTextField *theTextfield = (JCHTagTextField *)textField;
    JCHBeginInventoryForSKUViewData *cellData = (JCHBeginInventoryForSKUViewData *)theTextfield.textfieldTag;
    switch (theTextfield.textfieldType) {
        case kInventoryTextFieldCount:
        {
            if (textField.text.doubleValue == 0) {
                textField.text = @"";
            }
            cellData.copyCount = theTextfield.text.doubleValue;
        }
            break;
            
        case kInventoryTextFieldPrice:
        {
            if (textField.text.doubleValue == 0) {
                textField.text = @"";
            }
            
            cellData.copyPrice = theTextfield.text.doubleValue;
        }
            break;
            
        default:
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    JCHTagTextField *theTextfield = (JCHTagTextField *)textField;
    JCHBeginInventoryForSKUViewData *cellData = (JCHBeginInventoryForSKUViewData *)theTextfield.textfieldTag;
    if ([theTextfield.text isEqualToString:@""]) {
        switch (theTextfield.textfieldType) {
            case kInventoryTextFieldCount:
            {
                textField.text = [NSString stringFromCount:0 unitDigital:cellData.unitDigital];
            }
                break;
                
            case kInventoryTextFieldPrice:
            {
                textField.text = @"0.00";
            }
                break;
                
            default:
                break;
        }
    }
    
    switch (theTextfield.textfieldType) {
        case kInventoryTextFieldCount:
        {
            cellData.copyCount = theTextfield.text.doubleValue;
        }
            break;
            
        case kInventoryTextFieldPrice:
        {
            cellData.copyPrice = theTextfield.text.doubleValue;
        }
            break;
            
        default:
            break;
    }
}

@end

