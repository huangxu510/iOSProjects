//
//  JCHProductSalePriceViewController.m
//  jinchuhuo
//
//  Created by apple on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHProductSalePriceViewController.h"
#import "JCHProductSalePriceTableViewCell.h"
#import "CommonHeader.h"

@interface JCHProductSalePriceViewController ()<UITableViewDelegate,
                                                UITableViewDataSource,
                                                UITextFieldDelegate>
{
    UITableView *contentTableView;
    enum ProductSalePriceType currentSalePriceType;
}

@property (retain, nonatomic, readwrite) NSArray<ProductSalePriceRecord *> *currentProductList;
@property (retain, nonatomic, readwrite) NSArray<ProductUnitRecord *> *currentUnitList;
@property (retain, nonatomic, readwrite) UnitRecord4Cocoa *currentMainUnit;

@end


@implementation JCHProductSalePriceViewController

- (id)initWithType:(enum ProductSalePriceType)enumPriceType
       productList:(NSArray<ProductSalePriceRecord *> *)productList
          mainUnit:(UnitRecord4Cocoa *)mainUnit
          unitList:(NSArray<ProductUnitRecord *> *)unitList
{
    self = [super init];
    if (self) {
        self.title = @"出售价";
        currentSalePriceType = enumPriceType;
        self.currentProductList = productList;
        self.currentUnitList = unitList;
        self.currentMainUnit = mainUnit;
        
        // 获取主售价
        double mainSalePrice = 0;
        for (ProductSalePriceRecord *record in self.currentProductList) {
            if ([record.productName isEqualToString:@"统一出售价"]) {
                mainSalePrice = record.productPriceCopy.doubleValue;
                break;
            }
        }
        
        if (mainSalePrice >= 0.0001) {
            for (ProductSalePriceRecord *record in self.currentProductList) {
                if (NO == [record.productName isEqualToString:@"统一出售价"]) {
                    if (record.productPrice.doubleValue <= 0.0001) {
                        record.productPrice = [NSString stringWithFormat:@"%.2f", mainSalePrice];
                    }
                }
            }
        }

        for (ProductSalePriceRecord *record in self.currentProductList) {
            record.productPriceCopy = record.productPrice;
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.currentProductList = nil;
    self.currentMainUnit = nil;
    self.currentUnitList = nil;
    
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
    
    if (currentSalePriceType == kProductSalePriceForWithSKU) {
        seperateView = [JCHUIFactory createLabel:CGRectZero
                                           title:@"    注:如果单品出售价一致，录入统一出售价即可"
                                            font:[UIFont systemFontOfSize:14.0]
                                       textColor:UIColorFromRGB(0XA4A4A4)
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
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.backgroundColor = JCHColorGlobalBackground;
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
    JCHProductSalePriceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (nil == cell) {
        cell = [[[JCHProductSalePriceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier] autorelease];
    }
    
    ProductSalePriceRecord *record = self.currentProductList[indexPath.row];
    NSString *cellTitle = record.productName;
    if (kProductSalePriceForMainUnit == currentSalePriceType) {
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
    
    JCHProductSalePriceTableViewCellData *cellData = [JCHProductSalePriceTableViewCellData new];
    cellData.cellTitle = cellTitle;
    cellData.priceText = record.productPriceCopy;
    cellData.cellTag = record;
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
    
    for (ProductSalePriceRecord *record in self.currentProductList) {
        record.productPrice = record.productPriceCopy;
    }
    
    // 对于多规格的出售价，以统一出售价为准
    [self fixupSKUSalePrice];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    JCHTagTextField *theTextfield = (JCHTagTextField *)textField;
    ProductSalePriceRecord *cellData = (ProductSalePriceRecord *)theTextfield.textfieldTag;
    if (textField.text.doubleValue == 0) {
        textField.text = @"";
    }
    
    cellData.productPriceCopy = theTextfield.text;
    
    return;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    JCHTagTextField *theTextfield = (JCHTagTextField *)textField;
    ProductSalePriceRecord *cellData = (ProductSalePriceRecord *)theTextfield.textfieldTag;
    cellData.productPriceCopy = theTextfield.text;
    
    [self fixupSKUSalePrice];
    
    if (theTextfield.textfieldTag == self.currentProductList[0]) {
        for (NSInteger i = 1; i < self.currentProductList.count; ++i) {
            JCHProductSalePriceTableViewCell *cell = [contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setCellText:self.currentProductList[i].productPriceCopy];
        }
    }

    return;
}

#pragma mark -
#pragma mark 多规格出售价处理
- (void)fixupSKUSalePrice
{
    if (currentSalePriceType == kProductSalePriceForWithSKU) {
        ProductSalePriceRecord *mainRecord = self.currentProductList[0];
        if (mainRecord.productPriceCopy.doubleValue >= 0.0001) {
            for (ProductSalePriceRecord *record in self.currentProductList) {
                if (record.productPriceCopy.doubleValue <= 0.0001) {
                    record.productPriceCopy = mainRecord.productPriceCopy;
                }
            }
        }
    }
    
    return;
}

@end




@implementation ProductSalePriceRecord

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
    self.productPrice = nil;
    self.productPriceCopy = nil;
    
    [super dealloc];
    return;
}

@end




