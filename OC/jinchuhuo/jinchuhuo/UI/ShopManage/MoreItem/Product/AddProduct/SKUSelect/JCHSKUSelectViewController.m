//
//  JCHSKUSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSKUSelectViewController.h"
#import "JCHAddSKUViewController.h"
#import "JCHItemListFooterView.h"
#import "JCHAddProductRecordViewController.h"
#import "JCHSKUSelectTableViewCell.h"
#import "CommonHeader.h"

static NSString *kJCHSKUSelectTableViewCellTag = @"kJCHSKUSelectTableViewCellTag";

@interface JCHSKUSelectViewController () <UITableViewDataSource, UITableViewDelegate, JCHItemListFooterViewDelegate>

@property (nonatomic, retain) NSArray *skuTypeArray;
@property (nonatomic, retain) GoodsSKURecord4Cocoa *goodsSKURecord;

@property (nonatomic, retain) NSArray *allSKUValueForTypeArray;
@property (nonatomic, retain) NSMutableArray *selectedSKUValueForTypeArray;

@property (nonatomic, retain) NSString *goodsSKUUUID;
@property (nonatomic, retain) NSString *goodsUUID;

@property (nonatomic, retain) JCHSKUSelectTableViewCell *utilityCell;

@property (nonatomic, retain) NSMutableDictionary *cellStatusForRow;

@end

@implementation JCHSKUSelectViewController
{
    JCHItemListFooterView *_footerView;
}
- (instancetype)initWithGoodsSKUUUID:(NSString *)goodsSKUUUID goodsUUID:(NSString *)goodsUUID
{
    self = [super init];
    if (self) {
        self.title = @"规格选择";
        self.goodsSKUUUID = goodsSKUUUID;
        self.goodsUUID = goodsUUID;
    }
    return self;
}

- (void)dealloc
{
    self.skuTypeArray = nil;
    self.goodsSKURecord = nil;
    self.goodsSKUUUID = nil;
    self.allSKUValueForTypeArray = nil;
    self.selectedSKUValueForTypeArray = nil;
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)createUI
{
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveRecord)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    _footerView = [[[JCHItemListFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 49, kScreenWidth, 49)] autorelease];
    _footerView.categoryName = @"规格";
    _footerView.categoryUnit = @"种";
    _footerView.delegate = self;
    [self.view addSubview:_footerView];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(_footerView.mas_top);
    }];
    
    [self.tableView registerClass:[JCHSKUSelectTableViewCell class] forCellReuseIdentifier:kJCHSKUSelectTableViewCellTag];
    self.utilityCell = [self.tableView dequeueReusableCellWithIdentifier:kJCHSKUSelectTableViewCellTag];
    
    
#if MMR_TAKEOUT_VERSION
    _footerView.hidden = YES;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
#endif
}

#pragma mark - LoadData
- (void)loadData
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    //查询所有的type
    NSArray *allSKUType = nil;
    [skuService queryAllSKUType:&allSKUType];
    self.skuTypeArray = allSKUType;
    
    [_footerView setData:allSKUType.count];
    
    BOOL isFirstLoad = NO;
    if (self.cellStatusForRow == nil) {
        self.cellStatusForRow = [NSMutableDictionary dictionary];
        isFirstLoad = YES;
    }
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    JCHAddProductRecordViewController *addProductRecordViewController = viewControllers[viewControllers.count - 2];
    self.selectedSKUValueForTypeArray = [NSMutableArray arrayWithArray:addProductRecordViewController.currentSKURecord.skuArray];
    
    NSMutableArray *selectedSKUType = [NSMutableArray array];
    for (NSDictionary *dict in self.selectedSKUValueForTypeArray) {
        [selectedSKUType addObject:[[dict allKeys] firstObject]];
    }
    //将商品已有的规格类型放到前面
    NSMutableArray *allSKUTypeMutableArray = [NSMutableArray arrayWithArray:allSKUType];
    for (SKUTypeRecord4Cocoa *skuTypeRecord in allSKUType) {
        if ([selectedSKUType containsObject:skuTypeRecord.skuTypeName]) {
            [allSKUTypeMutableArray removeObject:skuTypeRecord];
            [allSKUTypeMutableArray insertObject:skuTypeRecord atIndex:0];
        }
    }
    allSKUType = allSKUTypeMutableArray;
    
    //查询所有skuType对应的skuValue
    NSMutableArray *skuValueForTypeArray = [NSMutableArray array];
    for (NSInteger i = 0; i < allSKUType.count; i++) {
        
        if (isFirstLoad) {
            [self.cellStatusForRow setObject:@(NO) forKey:@(i)];
        }
        
        SKUTypeRecord4Cocoa *skuTypeRecord = allSKUType[i];
        NSArray *allValuesInType = nil;
        [skuService querySKUWithType:skuTypeRecord.skuTypeUUID skuRecordVector:&allValuesInType];
        
        //查出来的skuValueRecord没有skuTypename,自己赋值
        for (SKUValueRecord4Cocoa *valueRecord in allValuesInType) {
            valueRecord.skuType = skuTypeRecord.skuTypeName;
        }
        NSDictionary *data = [NSDictionary dictionaryWithObject:allValuesInType forKey:skuTypeRecord.skuTypeName];
        [skuValueForTypeArray addObject:data];
    }
    self.allSKUValueForTypeArray = skuValueForTypeArray;
    
    
    
    [self.tableView reloadData];
}


#pragma mark - SaveRecord
- (void)handleSaveRecord
{
    if (self.selectedSKUValueForTypeArray.count > 5) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"一个商品最多只允许添加5种规格"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    for (NSDictionary *dict in self.selectedSKUValueForTypeArray) {
        NSArray *skuValueRecordList = [[dict allValues] firstObject];
        
        if (skuValueRecordList.count < 2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"多规格商品每种规格至少需要添加两种属性"
                                                               delegate:nil
                                                      cancelButtonTitle:@"我知道了"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    JCHAddProductRecordViewController *addProductRecordViewController = viewControllers[viewControllers.count - 2];
    GoodsSKURecord4Cocoa *record = [[[GoodsSKURecord4Cocoa alloc] init] autorelease];
    
    record.goodsSKUUUID = self.goodsSKUUUID;
    record.skuArray = self.selectedSKUValueForTypeArray;
    addProductRecordViewController.currentSKURecord = record;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectSKUValueRecord:(SKUValueRecord4Cocoa *)skuValueRecord
{
    //没有已选规格
    if (self.selectedSKUValueForTypeArray.count == 0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@[skuValueRecord] forKey:skuValueRecord.skuType];
        [self.selectedSKUValueForTypeArray addObject:dict];
    } else {
        //有已选规格在已选规格中查找同种类型的规格，如果找到则添加该skuValurRecord
        for (NSInteger i = 0; i < self.selectedSKUValueForTypeArray.count; i++) {
            NSDictionary *dict = self.selectedSKUValueForTypeArray[i];
            if ([[[dict allKeys] firstObject] isEqualToString:skuValueRecord.skuType]) {
                NSMutableArray *skuValueRecordArray = [NSMutableArray arrayWithArray:[dict objectForKey:skuValueRecord.skuType]];
                
                if (![self skuValueRecordArray:skuValueRecordArray containRecord:skuValueRecord]) {
                    [skuValueRecordArray addObject:skuValueRecord];
                    NSDictionary *newDict = [NSDictionary dictionaryWithObject:skuValueRecordArray forKey:skuValueRecord.skuType];
                    [self.selectedSKUValueForTypeArray replaceObjectAtIndex:i withObject:newDict];
                }
                
                return;
            }
        }
        
        //如果没有找到，添加一种类型到self.selectedSKUValueForTypeArray中
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@[skuValueRecord] forKey:skuValueRecord.skuType];
        [self.selectedSKUValueForTypeArray addObject:dict];
    }
}

- (BOOL)skuValueRecordArray:(NSArray *)skuValueRecordArray containRecord:(SKUValueRecord4Cocoa *)skuValueRecord
{
    BOOL contain = NO;
    for (SKUValueRecord4Cocoa *record in skuValueRecordArray) {
        if ([record.skuValueUUID isEqualToString:skuValueRecord.skuValueUUID]) {
            contain = YES;
            break;
        }
    }
    
    return contain;
}

- (BOOL)deselectSKUValueRecord:(SKUValueRecord4Cocoa *)skuValueRecord button:(UIButton *)button
{
    id <SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    if (self.goodsUUID)
    {
        BOOL skuTypeCanNotBeUnselected = [skuService isSKUValueUsedInManifest:skuValueRecord.skuValueUUID goodsUUID:_goodsUUID];
        
        if (skuTypeCanNotBeUnselected) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:@"该属性已被商品使用,不能取消"
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil];
            [av show];
            return NO;
        }
        //有已选规格在已选规格中查找同种类型的规格，如果找到则删除该skuValurRecord
        for (NSInteger i = 0; i < self.selectedSKUValueForTypeArray.count; i++) {
            NSDictionary *dict = self.selectedSKUValueForTypeArray[i];
            if ([[[dict allKeys] firstObject] isEqualToString:skuValueRecord.skuType]) {
                NSMutableArray *skuValueRecordArray = [NSMutableArray array];
                for (SKUValueRecord4Cocoa *record in [dict objectForKey:skuValueRecord.skuType]) {
                    if (![record.skuValue isEqualToString:skuValueRecord.skuValue]) {
                        [skuValueRecordArray addObject:record];
                    }
                }
                if (skuValueRecordArray.count == 0) {
                    button.selected = NO;
                    [self.selectedSKUValueForTypeArray removeObject:dict];
                } else {
                    NSDictionary *newDict = [NSDictionary dictionaryWithObject:skuValueRecordArray forKey:skuValueRecord.skuType];
                    [self.selectedSKUValueForTypeArray replaceObjectAtIndex:i withObject:newDict];
                }
                //[skuValueRecordArray removeObject:skuValueRecord];
            }
        }
        return YES;
    }
    
    //有已选规格在已选规格中查找同种类型的规格，如果找到则删除该skuValurRecord
    for (NSInteger i = 0; i < self.selectedSKUValueForTypeArray.count; i++) {
        NSDictionary *dict = self.selectedSKUValueForTypeArray[i];
        if ([[[dict allKeys] firstObject] isEqualToString:skuValueRecord.skuType]) {
            NSMutableArray *skuValueRecordArray = [NSMutableArray array];
            for (SKUValueRecord4Cocoa *record in [dict objectForKey:skuValueRecord.skuType]) {
                if (![record.skuValue isEqualToString:skuValueRecord.skuValue]) {
                    [skuValueRecordArray addObject:record];
                }
            }
            if (skuValueRecordArray.count == 0) {
                button.selected = NO;
                [self.selectedSKUValueForTypeArray removeObject:dict];
            } else {
                NSDictionary *newDict = [NSDictionary dictionaryWithObject:skuValueRecordArray forKey:skuValueRecord.skuType];
                [self.selectedSKUValueForTypeArray replaceObjectAtIndex:i withObject:newDict];
            }
        }
    }
    return YES;
}

- (void)addSKUValue:(NSString *)skuTypeName
{
    for (SKUTypeRecord4Cocoa *skuTypeRecord in self.skuTypeArray) {
        if ([skuTypeRecord.skuTypeName isEqualToString:skuTypeName]) {
            
            JCHAddSKUViewController *addController = [[[JCHAddSKUViewController alloc] initWithType:kJCHSKUTypeModify skuTypeRecord:skuTypeRecord] autorelease];
            [self.navigationController pushViewController:addController animated:YES];
            break;
        }
    }
}



#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allSKUValueForTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSKUSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHSKUSelectTableViewCellTag forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *skuValueForType = self.allSKUValueForTypeArray[indexPath.row];
    
    for (NSDictionary *dict in self.selectedSKUValueForTypeArray) {
        if ([[[dict allKeys] firstObject] isEqualToString:[[skuValueForType allKeys] firstObject]]) {
            cell.selectedSKUValueRecordArray = [[dict allValues] firstObject];
        }
    }
    
    [cell setCellData:skuValueForType];
    
    WeakSelf;
    [cell setButtonSelectBlock:^(SKUValueRecord4Cocoa *skuValueRecord) {
        [weakSelf selectSKUValueRecord:skuValueRecord];
    }];
    
    [cell setButtonDeslectBlock:^(SKUValueRecord4Cocoa *skuValueRecord, UIButton *button) {
        return [weakSelf deselectSKUValueRecord:skuValueRecord button:button];
    }];
    
    [cell setAddSKUValueBlock:^(NSString *skuTypeName) {
        [weakSelf addSKUValue:skuTypeName];
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL cellStatus = [[self.cellStatusForRow objectForKey:@(indexPath.row)] boolValue];
    if (cellStatus) {
        NSDictionary *skuValueForType = self.allSKUValueForTypeArray[indexPath.row];
        return [self.utilityCell calculateHeightWithData:skuValueForType];
    } else {
        return kStandardItemHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL cellStatus = [[self.cellStatusForRow objectForKey:@(indexPath.row)] boolValue];
    if (cellStatus) {
        [self.cellStatusForRow setObject:@(NO) forKey:@(indexPath.row)];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [self.cellStatusForRow setObject:@(YES) forKey:@(indexPath.row)];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - JCHItemListFooterViewDelegate
- (void)addItem
{
    JCHAddSKUViewController *addController = [[[JCHAddSKUViewController alloc] initWithType:kJCHSKUTypeAdd skuTypeRecord:nil] autorelease];
    [self.navigationController pushViewController:addController animated:YES];
}

@end
