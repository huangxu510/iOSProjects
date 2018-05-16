//
//  JCHAddProductSearchViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddProductSearchViewController.h"
#import "JCHAddProductTableViewCell.h"
#import "CommonHeader.h"
#import "JCHSearchBar.h"

@interface JCHAddProductSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, JCHAddProductTableViewCellDelegate>

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *allProduct;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) NSMutableDictionary *productItemRecordForUnitCache;
@property (nonatomic, retain) NSMutableDictionary *heightForRow;

@end

@implementation JCHAddProductSearchViewController

- (instancetype)initWithAllProduct:(NSArray *)allProduct
                      inventoryMap:(NSDictionary *)inventoryMap;
{
    self = [super init];
    if (self) {
        self.allProduct = allProduct;
        self.inventoryMap = inventoryMap;
        self.heightForRow = [NSMutableDictionary dictionary];
        self.productItemRecordForUnitCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.searchBar = nil;
    self.allProduct = nil;
    self.dataSource = nil;
    self.callBackBlock = nil;
    
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)] autorelease];
    searchBar.showsCancelButton = YES;
    searchBar.delegate = self;
    NSAttributedString *placeHolder = [[[NSAttributedString alloc] initWithString:@"请输入商品名称/商品条码/商家简称" attributes:@{NSForegroundColorAttributeName : JCHColorAuxiliary, NSFontAttributeName : [UIFont systemFontOfSize:13.0f]}] autorelease];
    //! @brief调整searchBar样式
    {
        //开始搜索后的背景色
        searchBar.barTintColor = JCHColorGlobalBackground;
        searchBar.translucent = NO;
        
        //searchBar 内部的textField
        UITextField *textField = [[[searchBar.subviews firstObject] subviews] lastObject];
        textField.backgroundColor = JCHColorGlobalBackground;
        textField.attributedPlaceholder = placeHolder;
        textField.enablesReturnKeyAutomatically = YES;
        
        //背景色
        searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
        
        //开始搜索后取消按钮的颜色
        searchBar.tintColor = JCHColorAuxiliary;
        
        //更改cancel为取消
        for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
            if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
                UIButton * cancel =(UIButton *)view;
                [cancel setTitle:@"取消" forState:UIControlStateNormal];
                [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        
        [searchBar sizeToFit];
    }

    
    self.searchBar = searchBar;
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    [self.searchBar becomeFirstResponder];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[JCHAddProductTableViewCell class] forCellReuseIdentifier:@"JCHAddProductTableViewCell"];
}

#pragma mark - UITableViewDelegate & UItableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductRecord4Cocoa *productRecord = (ProductRecord4Cocoa *)(self.dataSource[indexPath.row]);
    
    JCHAddProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHAddProductTableViewCell" forIndexPath:indexPath];
    cell.addProductListStyle = [JCHUserDefaults integerForKey:kAddProductListUIStyleKey];
    
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSArray<ProductItemRecord4Cocoa *> *unitList = nil;
    
    if (productRecord.is_multi_unit_enable) {
        unitList = self.productItemRecordForUnitCache[productRecord.goods_uuid];
        if (unitList == nil) {
            unitList = [productService queryUnitGoodsItem:productRecord.goods_uuid];
            [self.productItemRecordForUnitCache setObject:unitList forKey:productRecord.goods_uuid];
        }
    }

    JCHAddProductTableViewCellData *cellData = [[[JCHAddProductTableViewCellData alloc] init] autorelease];
    
    cellData.productLogoImage = productRecord.goods_image_name;
    cellData.productCategory = productRecord.goods_type;
    cellData.productName = productRecord.goods_name;
    cellData.productUnit = productRecord.goods_unit;
    cellData.sku_hidden_flag = productRecord.sku_hiden_flag;
    cellData.is_multi_unit_enable = productRecord.is_multi_unit_enable;
    
#if 0
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    GoodsSKURecord4Cocoa *record = nil;
    [skuService queryGoodsSKU:productRecord.goods_sku_uuid skuArray:&record];
    cellData.goodsSKURecord = record;
#endif
    
    cellData.isArrowButtonStatusPullDown = NO;
    cellData.productLogoImage = productRecord.goods_image_name;
    
    
    //主辅单位数据 (库存，价格)
    if (productRecord.is_multi_unit_enable) {
        //得到主辅单位的viewData
        cellData.auxiliaryUnitList = [self getMainAuxiliaryViewData:productRecord unitList:unitList];
    } else {
        //设置cellData的价格数量
        [self setCellDataPriceAndInventoryCount:cellData productRecord:productRecord];
    }
    [cell setCellData:cellData];
    
    //主辅单位数据 (库存，价格)
    if (productRecord.is_multi_unit_enable) {
        [self.heightForRow setObject:@(cell.pullDownCellHeight) forKey:@(indexPath.row)];
    } else {
        [self.heightForRow setObject:@(cell.normalCellHeight) forKey:@(indexPath.row)];
    }

    cell.pullDownButton.hidden = YES;
    cell.delegate = self;
    cell.addProductListStyle = kJCHAddProductChildViewControllerTypeDefault;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *number = [self.heightForRow objectForKey:@(indexPath.row)];
    return [number doubleValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这里出现过数组越界的闪退，没跟踪到，所以判断一下
    if (indexPath.row + 1 > self.dataSource.count) {
        return;
    }
    ProductRecord4Cocoa *productRecord = self.dataSource[indexPath.row];
    
    [self.searchBar endEditing:YES];
    
    if (self.callBackBlock) {
        self.callBackBlock(productRecord, nil);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text isEqualToString:@""]) {
        self.dataSource = @[];
    } else {
        
        NSPredicate *predicate = nil;
        NSMutableArray *resultArr = [NSMutableArray array];
        //商品名称首字母
        {
            predicate = [NSPredicate predicateWithFormat:@"self.productNamePinYin contains[c] %@", searchBar.text];
            [resultArr addObjectsFromArray:[self.allProduct filteredArrayUsingPredicate:predicate]];
        }
        
        //商品名称汉字
        {
            predicate = [NSPredicate predicateWithFormat:@"self.goods_name contains[c] %@", searchBar.text];
            [resultArr addObjectsFromArray:[self.allProduct filteredArrayUsingPredicate:predicate]];
        }
        
        //商品条码
        {
            predicate = [NSPredicate predicateWithFormat:@"self.goods_bar_code contains[c] %@", searchBar.text];
            [resultArr addObjectsFromArray:[self.allProduct filteredArrayUsingPredicate:predicate]];
        }
        
        //商家简称
        {
            predicate = [NSPredicate predicateWithFormat:@"self.goods_merchant_code contains[c] %@", searchBar.text];
            [resultArr addObjectsFromArray:[self.allProduct filteredArrayUsingPredicate:predicate]];
        }
        
        //过滤重复
        resultArr = [resultArr valueForKeyPath:@"@distinctUnionOfObjects.self"];
        
        NSMutableArray *resultMutableArr = [NSMutableArray arrayWithArray:resultArr];
        [resultMutableArr sortUsingComparator:^NSComparisonResult(ProductRecord4Cocoa *obj1, ProductRecord4Cocoa *obj2) {
            return [obj1.goods_name compare:obj2.goods_name];
        }];
        
        
        self.dataSource = resultMutableArr;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - JCHAddProductTableViewCellDelegate

- (void)handleShowKeyboard:(JCHAddProductTableViewCell *)cell unitUUID:(NSString *)unitUUI
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //这里出现过数组越界的闪退，没跟踪到，所以判断一下
    if (indexPath.row + 1 > self.dataSource.count) {
        return;
    }
    ProductRecord4Cocoa *productRecord = self.dataSource[indexPath.row];
    
    [self.searchBar endEditing:YES];
    
    if (self.callBackBlock) {
        self.callBackBlock(productRecord, unitUUI);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
