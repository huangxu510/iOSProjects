//
//  JCHTakeoutPutawayViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutPutawayViewController.h"
#import "JCHTakeoutPutawayTableViewCell.h"
#import "JCHTakeoutPutawaySectionView.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHTakeoutDishPutawayEditView.h"
#import "CommonHeader.h"

typedef NS_ENUM(NSInteger, JCHTakeoutPutawayType) {
    kJCHTakeoutPutawayAdd,
    kJCHTakeoutPutawayUpdate,
};

@interface JCHTakeoutPutawayViewController () <UITableViewDataSource, UITableViewDelegate, JCHSettleAccountsKeyboardViewDelegate>
{
    UILabel *_totalInfoLabel;
    UIButton *_putawayButton;
    JCHSettleAccountsKeyboardView *_keyboardView;
    JCHTakeoutDishPutawayEditView *_editView;
}
@property (retain, nonatomic) NSArray *productSKUList;                  // tableView数据源
@property (retain, nonatomic) ProductRecord4Cocoa *productRecord;
@property (assign, nonatomic) JCHTakeoutPutawayType putawayType;
@property (retain, nonatomic) NSArray *meituanSKUInfoList;              // 美团上查到的单品的价格库存数据
@property (retain, nonatomic) NSString *imageURL;
@property (assign, nonatomic) JCHTakeoutResource takeoutResource;

@end

@implementation JCHTakeoutPutawayViewController

- (instancetype)initWithProductRecord:(ProductRecord4Cocoa *)productRecord
                      takeoutResource:(JCHTakeoutResource)takeoutResource
{
    self = [super init];
    if (self) {
        self.productRecord = productRecord;
        self.takeoutResource = takeoutResource;
        NSString *takeoutPlatformName =  [JCHTakeoutManager getTakeoutPlatformName:takeoutResource];
        NSInteger takeoutStatus = [JCHTakeoutManager getTakeoutStatus:productRecord takeoutResource:takeoutResource];
        if (!takeoutStatus) {
            self.putawayType = kJCHTakeoutPutawayAdd;
            self.title = [NSString stringWithFormat:@"%@商品上架", takeoutPlatformName];
        } else {
            self.putawayType = kJCHTakeoutPutawayUpdate;
            self.title = [NSString stringWithFormat:@"%@商品调整", takeoutPlatformName];
        }
        
        
        
        if (!self.productRecord.goods_image_name || [self.productRecord.goods_image_name isEmptyString]) {
            self.imageURL = @"";
        } else {
            [JCHImageUtility getImageURL:@[self.productRecord.goods_image_name] successHandler:^(NSDictionary *dict) {
                NSString *imageURL = dict[self.productRecord.goods_image_name];
                self.imageURL = [imageURL stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            } failureHandler:^(NSError *error) {
                self.imageURL = @"";
            }];
        }
    }
    return self;
}

- (void)dealloc
{
    self.productRecord = nil;
    self.productSKUList = nil;
    self.meituanSKUInfoList = nil;
    
    [super dealloc];
}

- (void)initData
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    if (self.putawayType == kJCHTakeoutPutawayAdd) {
        // 上架,如果绑定id为空， 生成菜品绑定id和sku绑定id
        NSString *takeoutBindID = [JCHTakeoutManager getDishTakeoutBindID:self.productRecord takeoutResource:self.takeoutResource];
        if (!takeoutBindID || [takeoutBindID isEmptyString]) {
            id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
            [JCHTakeoutManager setDishTakeoutBindID:self.productRecord.takoutRecord
                                    takeoutResource:self.takeoutResource
                                             bindID:[utilityService generateUUID]];
            
            if (!self.productRecord.sku_hiden_flag) {
                NSArray *productItemList = self.productRecord.productItemList;
                for (ProductItemRecord4Cocoa *productItem in productItemList) {
                    [JCHTakeoutManager setDishTakeoutBindID:productItem.takoutRecord
                                            takeoutResource:self.takeoutResource
                                                     bindID:[utilityService generateUUID]];
                }
                self.productRecord.productItemList = productItemList;
            }
        }
    }
    
    
    if (self.productRecord.sku_hiden_flag) {
        // 单品
        JCHTakeoutPutawayTableViewCellData *data = [[[JCHTakeoutPutawayTableViewCellData alloc] init] autorelease];
        data.skuName = self.productRecord.goods_name;
        data.skuLocalPrice = self.productRecord.goods_sell_price;
        data.status = YES;
        data.skuTakeoutPrice = [NSString stringWithFormat:@"%.2f", self.productRecord.goods_sell_price];
        data.skuTakeoutInventory = @"*";
        data.skuID = [JCHTakeoutManager getDishTakeoutBindID:self.productRecord takeoutResource:self.takeoutResource];
        data.boxNum = self.productRecord.takoutRecord.boxNum;
        data.boxPrice = self.productRecord.takoutRecord.boxPrice;
        self.productSKUList = @[data];
    } else {
        // 多规格
        id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
        
        NSMutableArray *productSKUList = [NSMutableArray array];
        NSArray *productItemList = self.productRecord.productItemList;
        for (ProductItemRecord4Cocoa *productItemRecord in productItemList) {
            GoodsSKURecord4Cocoa *goodsSKURecord = nil;
            [skuService queryGoodsSKU:productItemRecord.goodsSkuUUID skuArray:&goodsSKURecord];
            
            NSArray *skuCombineList = [JCHTransactionUtility getSKUCombineListWithGoodsSKURecord:goodsSKURecord];
            
            JCHTakeoutPutawayTableViewCellData *data = [[[JCHTakeoutPutawayTableViewCellData alloc] init] autorelease]; 
            data.skuName = [skuCombineList firstObject];
            data.skuLocalPrice = productItemRecord.itemPrice;
            data.status = YES;
            data.skuTakeoutPrice = [NSString stringWithFormat:@"%.2f", productItemRecord.itemPrice];
            data.skuTakeoutInventory = @"*";
            
            NSString *productItemTakeoutBindID = [JCHTakeoutManager getProductItemTakeoutBindID:productItemRecord
                                                                                takeoutResource:self.takeoutResource];
            
            // 如果单品的绑定id为空，则生成绑定id
            if (!productItemTakeoutBindID || [productItemTakeoutBindID isEmptyString]) {
                [JCHTakeoutManager setDishTakeoutBindID:productItemRecord.takoutRecord
                                        takeoutResource:self.takeoutResource
                                                 bindID:[utilityService generateUUID]];
            }
            
            data.skuID = [JCHTakeoutManager getProductItemTakeoutBindID:productItemRecord takeoutResource:self.takeoutResource];
            data.boxNum = productItemRecord.takoutRecord.boxNum;
            data.boxPrice = productItemRecord.takoutRecord.boxPrice;
            
            [productSKUList addObject:data];
        }
        self.productRecord.productItemList = productItemList;
        self.productSKUList = productSKUList;
    }
    
    
    // 如果在菜品的外卖bindID为空，表示该商品已经下架过（在美团已删除)，则无需查询该商品在美团的价格和库存
    if (self.putawayType == kJCHTakeoutPutawayAdd) {
        [self createUI];
    } else {
        
        // 查询外卖平台的价格和库存
        [self queryTakeoutPrice];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kTabBarHeight);
    }];
    [self.tableView registerClass:[JCHTakeoutPutawayTableViewCell class] forCellReuseIdentifier:@"JCHTakeoutPutawayTableViewCell"];
    
    UIView *bottomView = [[[UIView alloc] init] autorelease];
    bottomView.backgroundColor = [UIColor whiteColor];
    [bottomView addSeparateLineWithMasonryTop:YES bottom:NO];
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kTabBarHeight);
    }];
    
    CGFloat putawayButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120];
    
    _totalInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(14.0)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [bottomView addSubview:_totalInfoLabel];

    [_totalInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(bottomView);
        make.right.equalTo(bottomView).offset(-putawayButtonWidth);
    }];
    
    _putawayButton = [JCHUIFactory createButton:CGRectZero
                                         target:self
                                         action:@selector(handlePutaway)
                                          title:@"上架"
                                     titleColor:[UIColor whiteColor]
                                backgroundColor:nil];
    _putawayButton.titleLabel.font = JCHFont(16);
    [_putawayButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateNormal];
    [_putawayButton setBackgroundImage:[UIImage imageWithColor:JCHColorDisableButton] forState:UIControlStateDisabled];
    [_putawayButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
    if (self.putawayType == kJCHTakeoutPutawayUpdate) {
        [_putawayButton setTitle:@"调整" forState:UIControlStateNormal];
    }
    [bottomView addSubview:_putawayButton];
    
    [_putawayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(bottomView);
        make.width.mas_equalTo(putawayButtonWidth);
    }];
    
    [self updataFooter];
}


- (void)queryTakeoutPrice
{
    [MBProgressHUD showHUDWithTitle:@"加载中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    NSString *takeoutBindID = [JCHTakeoutManager getDishTakeoutBindID:self.productRecord takeoutResource:self.takeoutResource];
    
    QueryProductPriceRequest *request = [[[QueryProductPriceRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/dish/abstracts", kTakeoutServerIP];
    request.dishIDList = @[takeoutBindID];
    request.resource = [NSString stringWithFormat:@"%ld", self.takeoutResource];
    
    [takeoutService queryProductPrice:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                NSArray *skuInfoList = [responseData[@"data"][@"dishAbstracts"] firstObject][@"skuAbstracts"];
                self.meituanSKUInfoList = skuInfoList;
                
                for (JCHTakeoutPutawayTableViewCellData *data in self.productSKUList) {
                    for (NSDictionary *skuInfo in skuInfoList) {
                        if ([data.skuID isEqualToString:skuInfo[@"skuId"]]) {
                            data.skuTakeoutPrice = skuInfo[@"price"];
                            data.skuTakeoutInventory = skuInfo[@"stock"];
                            break;
                        }
                    }
                }
                [self createUI];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
}
#pragma mark - 上架
- (void)handlePutaway
{
    NSInteger i = 0;
    for (JCHTakeoutPutawayTableViewCellData *data in self.productSKUList) {
        if (data.status) {
            i++;
        }
    }
    
    if (self.putawayType == kJCHTakeoutPutawayAdd) {
        if (i==0) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未选择要上架的菜品" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        // 若果是无规格商品直接上架，如果是多规格商品，上架的时候至少要上架2个单品
        if (!self.productRecord.sku_hiden_flag && i < 2) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"多规格商品要至少上架两种规格" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
    }
    
    
    NSMutableArray *productSKUList = [NSMutableArray array];
    if (self.putawayType == kJCHTakeoutPutawayAdd) {
        // 如果是上架，则选了哪个就上架哪个
        for (JCHTakeoutPutawayTableViewCellData *data in self.productSKUList) {
            if (data.status) {
                [productSKUList addObject:data];
            }
        }
    } else {
        // 如果是更新，则只更新选择的，未选的按照查出来的价格更新（相当于价格不变）
        for (JCHTakeoutPutawayTableViewCellData *data in self.productSKUList) {
            
            // 未选择的
            if (!data.status) {
                for (NSDictionary *skuInfo in self.meituanSKUInfoList) {
                    if ([data.skuID isEqualToString:skuInfo[@"skuId"]]) {
                        data.skuTakeoutPrice = skuInfo[@"price"];
                        data.skuTakeoutInventory = [skuInfo[@"stock"] isEmptyString] ? @"*" : skuInfo[@"stock"];
                        break;
                    }
                }
            }
            [productSKUList addObject:data];
        }
    }
    

    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
//    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    NSMutableDictionary *putawayData = [NSMutableDictionary dictionary];
    
    NSMutableArray *skus = [NSMutableArray array];
    for (NSInteger i = 0; i < productSKUList.count; i++) {
    
        JCHTakeoutPutawayTableViewCellData *data = productSKUList[i];
        
        NSMutableDictionary *skuDict = [NSMutableDictionary dictionary];
        [skuDict setObject:data.skuTakeoutPrice forKey:@"price"];
        [skuDict setObject:data.skuTakeoutInventory forKey:@"count"];
        
        if (productSKUList.count == 1) {
            [skuDict setObject:self.productRecord.goods_unit forKey:@"name"];
        } else {
            [skuDict setObject:data.skuName forKey:@"name"];
        }
        
        [skuDict setObject:@"" forKey:@"remark"];
        [skuDict setObject:@"" forKey:@"barCode"];
        [skuDict setObject:@(data.boxNum) forKey:@"boxNum"];
        [skuDict setObject:@(data.boxPrice) forKey:@"boxPrice"];
        
        if (self.productRecord.sku_hiden_flag) {
            // 无规格
            NSString *takeoutBindID = [JCHTakeoutManager getDishTakeoutBindID:self.productRecord takeoutResource:self.takeoutResource];
            [skuDict setObject:takeoutBindID forKey:@"id"];
        } else {
            // 多规格
            [skuDict setObject:data.skuID forKey:@"id"];
        }
        [skus addObject:skuDict];
    }
    
    [putawayData setObject:skus forKey:@"skus"];
    [putawayData setObject:self.imageURL forKey:@"image"];
    [putawayData setObject:JCHSafeString(self.productRecord.goods_image_name) forKey:@"imageUuid"];
    [putawayData setObject:@"1" forKey:@"resource"];
    [putawayData setObject:JCHSafeString(self.productRecord.goods_memo) forKey:@"remark"];
    [putawayData setObject:self.productRecord.goods_unit forKey:@"unitName"];
    [putawayData setObject:self.productRecord.goods_type forKey:@"categoryName"];
    
    // 排序默认传1
    [putawayData setObject:@"1" forKey:@"sequence"];
    [putawayData setObject:@"1" forKey:@"minOrderCount"];
    [putawayData setObject:[NSString stringWithFormat:@"%.2f", self.productRecord.goods_sell_price] forKeyedSubscript:@"price"];
    [putawayData setObject:@"0" forKey:@"isSoldOut"];
    [putawayData setObject:self.productRecord.goods_name forKey:@"name"];
    NSString *takeoutBindID = [JCHTakeoutManager getDishTakeoutBindID:self.productRecord takeoutResource:self.takeoutResource];
    [putawayData setObject:takeoutBindID forKey:@"id"];
    [putawayData setObject:@(self.productRecord.takoutRecord.boxNum) forKey:@"boxNum"];
    [putawayData setObject:@(self.productRecord.takoutRecord.boxPrice) forKey:@"boxPrice"];
    
    
    if (!self.productRecord.cuisineProperty || [self.productRecord.cuisineProperty isEmptyString]) {
        [putawayData setObject:@[] forKey:@"properties"];
    } else {
        NSArray *properties = [self.productRecord.cuisineProperty jsonStringToArrayOrDictionary];
        [putawayData setObject:properties forKey:@"properties"];
    }
    
    
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    PutAwayProductRequest *request = [[[PutAwayProductRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/dish/putOn", kTakeoutServerIP];
    request.resource = [NSString stringWithFormat:@"%ld", self.takeoutResource];
    request.dishList = @[putawayData];
    
    [MBProgressHUD showHUDWithTitle:@""
                             detail:@"上架中..."
                           duration:20
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    [takeoutService putAwayProduct:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                
                id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
                [JCHTakeoutManager updateTakeoutStatus:1
                                       takeoutResource:self.takeoutResource
                                                  dish:self.productRecord];
                [productService updateCuisine:self.productRecord];
                [MBProgressHUD showHUDWithTitle:@"成功上架"
                                         detail:@""
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productSKUList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHTakeoutPutawayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHTakeoutPutawayTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    JCHTakeoutPutawayTableViewCellData *data = self.productSKUList[indexPath.row];

    WeakSelf;
    [cell setSelectBlock:^(BOOL selected) {
        data.status = selected;
        [weakSelf updataFooter];
    }];
    [cell setViewData:data];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[JCHTakeoutPutawaySectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf;
    _editView = [[[JCHTakeoutDishPutawayEditView alloc] initWithFrame:CGRectZero] autorelease];
    _editView.tag = indexPath.row;
    [_editView setCloseViewBlock:^{
        [weakSelf -> _keyboardView hide];
    }];
    
    [_editView setEditLabelChangeBlock:^(JCHBottomArrowButton *button) {
        
        if (button.tag == kJCHTakeoutPutawayButtonTagPrice) {
            [weakSelf -> _keyboardView setEditText:button.titleLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
        } else {
            [weakSelf -> _keyboardView setEditText:button.titleLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModeCount];
        }
    }];
    JCHTakeoutPutawayTableViewCellData *cellData = self.productSKUList[indexPath.row];
    JCHTakeoutDishPutawayEditViewData *data = [[[JCHTakeoutDishPutawayEditViewData alloc] init] autorelease];
    data.skuName = cellData.skuName;
    data.inventory = cellData.skuTakeoutInventory;
    data.price = cellData.skuTakeoutPrice;
    
    [_editView setViewData:data];
    
    CGFloat keyboardHeight = [JCHSizeUtility calculateWidthWithSourceWidth:196.0f];
    _keyboardView = [[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectZero
                                                           keyboardHeight:keyboardHeight
                                                                  topView:_editView
                                                   topContainerViewHeight:_editView.viewHeight];
    _keyboardView.delegate = self;

    [_keyboardView setEditText:@"0.00" editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
    [_keyboardView show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - JCHSettleAccountsKeyboardViewDelegate

- (NSString *)keyboardViewEditingChanged:(NSString *)editText
{
    _editView.selectedButton.titleLabel.text = editText;
    return editText;
}

- (void)keyboardViewOKButtonClick
{
    JCHTakeoutPutawayTableViewCellData *data = self.productSKUList[_editView.tag];
    data.status = YES;
    data.skuTakeoutPrice = _editView.price;
    data.skuTakeoutInventory = _editView.inventory;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_editView.tag inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_keyboardView hide];
}

- (void)updataFooter
{
    if (self.productRecord.sku_hiden_flag) {
        // 无规格
        _totalInfoLabel.text = @"无规格1件菜品";
    } else {
        // 多规格
        NSInteger i = 0;
        for (JCHTakeoutPutawayTableViewCellData *data in self.productSKUList) {
            if (data.status) {
                i++;
            }
        }
        _totalInfoLabel.text = [NSString stringWithFormat:@"多规格%ld件菜品", i];
    }
}
@end
