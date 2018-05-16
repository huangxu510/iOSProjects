//
//  JCHProductBarCodeViewController.m
//  jinchuhuo
//
//  Created by apple on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHProductBarCodeViewController.h"
#import "JCHProductBarCodeTableViewCell.h"
#import "CommonHeader.h"

@interface JCHProductBarCodeViewController ()<UITableViewDelegate,
                                            UITableViewDataSource,
                                            UITextFieldDelegate>
{
    UITableView *contentTableView;
    enum ProductBarCodeType currentBarCodeType;
}

@property (retain, nonatomic, readwrite) NSArray<ProductBarCodeRecord *> *currentProductList;
@property (retain, nonatomic, readwrite) NSArray<ProductUnitRecord *> *currentUnitList;
@property (retain, nonatomic, readwrite) UnitRecord4Cocoa *currentMainUnit;

@end


@implementation JCHProductBarCodeViewController

- (id)initWithType:(enum ProductBarCodeType)enumBarCodeType
       productList:(NSArray<ProductBarCodeRecord *> *)productList
          mainUnit:(UnitRecord4Cocoa *)mainUnit
          unitList:(NSArray<ProductUnitRecord *> *)unitList
{
    self = [super init];
    if (self) {
        self.title = @"条码";
        currentBarCodeType = enumBarCodeType;
        self.currentProductList = productList;
        self.currentUnitList = unitList;
        self.currentMainUnit = mainUnit;
        
        for (ProductBarCodeRecord *record in self.currentProductList) {
            record.productBarCodeCopy = record.productBarCode;
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.currentProductList = nil;
    self.currentUnitList = nil;
    self.currentMainUnit = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    return;
}

- (void)createUI
{
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveProductPrice:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIView *seperateView = nil;
    CGFloat seperateViewHeight = 0.0;
    
    if (currentBarCodeType == kProductBarCodeRecordForWithSKU) {
        seperateView = [JCHUIFactory createLabel:CGRectZero
                                           title:@"    注:如果单品条码一致，录入主条码即可"
                                            font:[UIFont systemFontOfSize:14.0]
                                       textColor:[UIColor grayColor]
                                          aligin:NSTextAlignmentLeft];
        seperateViewHeight = kStandardItemHeight;
    } else {
        seperateView = [JCHUIFactory createSeperatorLine:kStandardSeparateViewHeight];
        seperateViewHeight = kStandardSeparateViewHeight;
    }
    
    seperateView.backgroundColor = JCHColorGlobalBackground;
    [self.view addSubview:seperateView];
    [seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(seperateViewHeight);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.allowsSelection = NO;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(seperateView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.and.right.equalTo(self.view);
        
    }];
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentProductList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        if (1 == self.currentProductList.count) {
            return kStandardItemHeight;
        } else {
            return kStandardItemHeight + kStandardSeparateViewHeight;
        }
    } else {
        return kStandardItemHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kReuseIdentifier = @"kReuseIdentifier";
    JCHProductBarCodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (nil == cell) {
        cell = [[[JCHProductBarCodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier] autorelease];
    }
    
    ProductBarCodeRecord *record = self.currentProductList[indexPath.row];
    NSString *cellTitle = record.productName;
    if (kProductBarCodeRecordForMainUnit) {
        if ([self.currentMainUnit.unitName isEqualToString:record.productName]) {
            cellTitle = [NSString stringWithFormat:@"%@(主单位)", record.productName];
        } else {
            for (ProductUnitRecord *unit in self.currentUnitList) {
                if ([unit.unitRecord.unitName isEqualToString:record.productName]) {
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
    
    JCHProductBarCodeTableViewCellData *cellData = [JCHProductBarCodeTableViewCellData new];
    cellData.cellTitle = cellTitle;
    cellData.barCode = record.productBarCodeCopy;
    cellData.cellTag = record;
    cellData.hostController = self;
    [cell setCellData:cellData
    textfieldDelegate:self
       showBottomView:0 == indexPath.row && self.currentProductList.count > 1
          isFirstCell:0 == indexPath.row
     isLastCell:indexPath.row == self.currentProductList.count - 1];
    
    return cell;
}


#pragma mark -
#pragma mark 完成
- (void)handleSaveProductPrice:(id)sender
{
    [self.view endEditing:NO];
    
    for (ProductBarCodeRecord *record in self.currentProductList) {
        record.productBarCode = record.productBarCodeCopy;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    JCHTagTextField *theTextfield = (JCHTagTextField *)textField;
    ProductBarCodeRecord *cellData = (ProductBarCodeRecord *)theTextfield.textfieldTag;
    cellData.productBarCodeCopy = theTextfield.text;
    
    return;
}

@end




@implementation ProductBarCodeRecord

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
    self.productName = nil;
    self.productBarCode = nil;
    self.productBarCodeCopy = nil;
    
    [super dealloc];
    return;
}

@end



