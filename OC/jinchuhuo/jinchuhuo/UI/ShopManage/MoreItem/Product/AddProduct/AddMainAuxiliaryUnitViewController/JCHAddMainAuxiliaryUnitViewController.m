//
//  JCHAddMainAuxiliaryUnitViewController.m
//  jinchuhuo
//
//  Created by apple on 16/8/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddMainAuxiliaryUnitViewController.h"
#import "JCHUnitListViewController.h"
#import "JCHItemListTableViewCell.h"
#import "JCHTitleDetailLabel.h"
#import "JCHAddMainAuxilaryUnitCell.h"
#import "JCHAddSKUValueFooterView.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"
#import <Masonry.h>

#ifndef kMaxUnitRowCount
#define kMaxUnitRowCount 5
#endif

@interface JCHAddMainAuxiliaryUnitViewController ()<JCHAddSKUValueFooterViewDelegate,
                                                    UITextFieldDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource>
{
    JCHTitleDetailLabel *mainUnitTitleLabel;
    JCHAddSKUValueFooterView *addUnitButtonView;
    NSInteger currentUnitViewCount;
    
    UIView *mainUnitTopSeparateLine;
    UIView *mainUnitBottomSeparateLine;
    
    UIView *addUnitTopSeparateLine;
    UIView *addUnitBottomSeparateLine;
    
    UITableView *contentTableView;
}

@property (retain, nonatomic, readwrite) NSMutableArray<ProductUnitRecord *> *finalProductUnitArray;
@property (retain, nonatomic, readwrite) NSMutableArray<ProductUnitRecord *> *editProductUnitArray;
@property (retain, nonatomic, readwrite) UnitRecord4Cocoa *mainUnitRecord;
@property (retain, nonatomic, readwrite) NSArray<UnitRecord4Cocoa *> *allUnitList;
@property (retain, nonatomic, readwrite) NSString *currentProductUUID;
@end

@implementation JCHAddMainAuxiliaryUnitViewController

- (id)initWithMainUnit:(NSString *)productUUID
              mainUnit:(UnitRecord4Cocoa *)mainUnit
             unitArray:(NSMutableArray<ProductUnitRecord *> *)unitArray
{
    self = [super init];
    if (self) {
        self.title = @"主辅单位";
        self.finalProductUnitArray = unitArray;
        self.mainUnitRecord = mainUnit;
        self.currentProductUUID = productUUID;
        currentUnitViewCount = self.editProductUnitArray.count;
        
        self.editProductUnitArray = [[[NSMutableArray alloc] init] autorelease];
        for (ProductUnitRecord *record in self.finalProductUnitArray) {
            ProductUnitRecord *productRecord = [[[ProductUnitRecord alloc] init] autorelease];
            productRecord.recordUUID = record.recordUUID;
            productRecord.unitRecord = record.unitRecord;
            productRecord.convertRatio = record.convertRatio;
            productRecord.copyConvertRatio = record.convertRatio;
            
            [self.editProductUnitArray addObject:productRecord];
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.currentProductUUID = nil;
    self.mainUnitRecord = nil;
    self.editProductUnitArray = nil;
    self.allUnitList = nil;
    self.finalProductUnitArray = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self createUI];
    
    return;
}

- (void)loadData
{
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    self.allUnitList = [unitService queryAllUnit];
    currentUnitViewCount = self.editProductUnitArray.count;
    
    return;
}

- (void)createUI
{
    // 导航栏按钮
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveProductUnit:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIColor *textColor = JCHColorMainBody;
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    // table view header
    mainUnitTitleLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"主单位"
                                                               font:textFont
                                                          textColor:textColor
                                                             detail:self.mainUnitRecord.unitName
                                                   bottomLineHidden:NO];
    [self.backgroundScrollView addSubview:mainUnitTitleLabel];
    mainUnitTitleLabel.detailLabel.textColor = textColor;
    mainUnitTitleLabel.detailLabel.font = textFont;
    mainUnitTitleLabel.detailLabel.text = self.mainUnitRecord.unitName;
    mainUnitTitleLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, kStandardItemHeight);
    [self.view addSubview:mainUnitTitleLabel];
    
    // table view
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.allowsSelection = YES;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    // table view footer
    addUnitButtonView = [[[JCHAddSKUValueFooterView alloc] initWithFrame:CGRectZero] autorelease];
    [addUnitButtonView setTitleName:@"添加辅单位"];
    addUnitButtonView.delegate = self;
    addUnitButtonView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:addUnitButtonView];
    
    mainUnitTopSeparateLine = [JCHUIFactory createSeperatorLine:0];
    [mainUnitTitleLabel addSubview:mainUnitTopSeparateLine];
    
    mainUnitBottomSeparateLine = [JCHUIFactory createSeperatorLine:0];
    [mainUnitTitleLabel addSubview:mainUnitBottomSeparateLine];
    
    addUnitTopSeparateLine = [JCHUIFactory createSeperatorLine:0];
    [addUnitButtonView addSubview:addUnitTopSeparateLine];
    
    addUnitBottomSeparateLine = [JCHUIFactory createSeperatorLine:0];
    [addUnitButtonView addSubview:addUnitBottomSeparateLine];
    
    // 进行布局
    [self layoutAllSubviews];
    
    if (currentUnitViewCount >= kMaxUnitRowCount) {
        addUnitButtonView.hidden = YES;
    } else {
        addUnitButtonView.hidden = NO;
    }
    
    return;
}

- (void)layoutAllSubviews
{
    [mainUnitTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [contentTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainUnitTitleLabel.mas_bottom).with.offset(kStandardTopMargin);
        if (self.editProductUnitArray.count <= 4) {
            make.height.mas_equalTo((2 * kStandardItemHeight + kStandardTopMargin) * self.editProductUnitArray.count);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-kStandardItemHeight);
        }
        make.left.and.right.equalTo(self.view);
    }];
    
    [addUnitButtonView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(contentTableView.mas_bottom);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    [mainUnitTopSeparateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(mainUnitTitleLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [mainUnitBottomSeparateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.equalTo(mainUnitTitleLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [addUnitTopSeparateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(addUnitButtonView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [addUnitBottomSeparateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.equalTo(addUnitButtonView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    return;
}

#pragma mark -
#pragma mark JCHAddSKUValueFooterViewDelegate
- (void)addItem
{
    if (currentUnitViewCount >= 5) {
        return;
    }
    
    ProductUnitRecord *unitRecord = [[[ProductUnitRecord alloc] init] autorelease];
    unitRecord.recordUUID = nil;
    unitRecord.convertRatio = 1.0;
    unitRecord.copyConvertRatio = 1.0;
    unitRecord.unitRecord = self.allUnitList[0];
    [self.editProductUnitArray addObject:unitRecord];
    
    ++currentUnitViewCount;
    if (currentUnitViewCount >= kMaxUnitRowCount) {
        addUnitButtonView.hidden = YES;
    } else {
        addUnitButtonView.hidden = NO;
    }
    
    [contentTableView reloadData];
    [self layoutAllSubviews];
    
    return;
}

#pragma mark -
#pragma mark 保存
- (void)handleSaveProductUnit:(id)sender
{
    [self.view endEditing:NO];
    
    for (ProductUnitRecord *record in self.editProductUnitArray) {
        if ([record.unitRecord.unitName isEqualToString:self.mainUnitRecord.unitName]) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"商品辅单位不能与主单位相同"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            
            return;
        }
    }
    
    BOOL hasInvalidRecord = NO;
    for (ProductUnitRecord *record in self.editProductUnitArray) {
        if (record.copyConvertRatio <= 0.00001) {
            hasInvalidRecord = YES;
            break;
        }
    }
    
    if (hasInvalidRecord) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"主辅单位换算比例不能为0"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        
        return;
    }
    
    
    for (ProductUnitRecord *record in self.editProductUnitArray) {
        record.convertRatio = record.copyConvertRatio;
    }
    
    // 清除转换数量为0的单位
#if 0
    while (YES) {
        ProductUnitRecord *invalidRecord = nil;
        for (ProductUnitRecord *unitRecord in self.editProductUnitArray) {
            if (unitRecord.convertRatio <= 0) {
                invalidRecord = unitRecord;
                break;
            }
        }
        
        if (nil == invalidRecord) {
            break;
        } else {
            [self.editProductUnitArray removeObject:invalidRecord];
        }
    }
#endif
    
    [self.finalProductUnitArray removeAllObjects];
    for (ProductUnitRecord *record in self.editProductUnitArray) {
        [self.finalProductUnitArray addObject:record];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    JCHTagTextField *theTextfield = (JCHTagTextField *)textField;
    ProductUnitRecord *cellData = (ProductUnitRecord *)theTextfield.textfieldTag;
    cellData.copyConvertRatio = theTextfield.text.doubleValue;
    
    return;
}

#pragma mark -
#pragma mark 选择单位
- (void)handleSelectUnit:(NSIndexPath *)indexPath
{
    ProductUnitRecord *currentUnitRecord = self.editProductUnitArray[indexPath.row];
    JCHUnitListViewController *unitListViewController = [[[JCHUnitListViewController alloc] initWithType:kJCHUnitListTypeSelect] autorelease];
    unitListViewController.selectUnitRecord = currentUnitRecord.unitRecord;
    unitListViewController.sendValueBlock = ^(UnitRecord4Cocoa *selectUnitRecord){
        currentUnitRecord.unitRecord = selectUnitRecord;
        
        [contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:unitListViewController animated:YES];
}

#pragma mark -
#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.editProductUnitArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardItemHeight * 2 + kStandardTopMargin;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kReuseIdentifier = @"kReuseIdentifier";
    JCHAddMainAuxilaryUnitCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (nil == cell) {
        cell = [[[JCHAddMainAuxilaryUnitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ProductUnitRecord *unitRecord = self.editProductUnitArray[indexPath.row];
    
    cell.productUnitRecord = unitRecord;
    
    [cell setCellData:indexPath.row + 1
         mainUnitName:self.mainUnitRecord.unitName
     auxilaryUnitName:unitRecord.unitRecord.unitName
         convertRatio:[NSString stringFromCount:unitRecord.copyConvertRatio unitDigital:unitRecord.unitRecord.unitDecimalDigits]
    textfieldDelegate:self];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleSelectUnit:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ProductUnitRecord *unitRecord = [self.editProductUnitArray objectAtIndex:indexPath.row];
        id<FinanceCalculateService> financeService = [[ServiceFactory sharedInstance] financeCalculateService];
        InventoryDetailRecord4Cocoa *inventoryRecord = nil;
        if (nil != self.currentProductUUID && NO == [self.currentProductUUID isEqualToString:@""]) {
            inventoryRecord= [financeService calculateInventoryFor:self.currentProductUUID ? self.currentProductUUID : @""
                                                          unitUUID:unitRecord.unitRecord.unitUUID
                                                     warehouseUUID:@"-1"];
        }
        
        if (nil == inventoryRecord || 0 == inventoryRecord.currentInventoryCount) {
            [self.editProductUnitArray removeObjectAtIndex:indexPath.row];
            
            --currentUnitViewCount;
            if (currentUnitViewCount <= kMaxUnitRowCount) {
                addUnitButtonView.hidden = NO;
            }
            
            [contentTableView reloadData];
            [self layoutAllSubviews];
        } else {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"当前辅单位有关联的商品库存，不能删除"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        }
    }
}

@end





@implementation ProductUnitRecord

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    self.recordUUID = nil;
    self.unitRecord = nil;
    [super dealloc];
}

@end


