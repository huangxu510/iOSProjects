//
//  JCHTakeoutManager.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutManager.h"
#import "JCHUserInfoViewController.h"
#import "JCHLoginViewController.h"
#import "CommonHeader.h"
#import "JCHTakeoutOrderInfoModel.h"


@implementation JCHTakeoutManager
{
    dispatch_group_t _uploadImageGroup;
}

+ (instancetype)sharedInstance
{
    static JCHTakeoutManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JCHTakeoutManager alloc] init];
    });
    return manager;
}

#pragma mark - 根据订单id数组查询订单信息
- (void)queryOrderInfo:(NSArray *)orders resource:(NSString *)resource print:(BOOL)print
{
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    QueryOrderByIDRequest *request = [[[QueryOrderByIDRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/queryOrderByIds", kTakeoutServerIP];
    request.resource = resource;
    request.orderIDList = orders;
    [takeoutService queryOrderByID:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
            } else {
                NSLog(@"responseData = %@", responseData);
                
                NSArray *orders = responseData[@"data"][@"orders"];
                
                if (print) {
                    for (NSDictionary *orderInfo in orders) {
                        [[JCHBluetoothManager shareInstance] printTakeoutOrderInfo:orderInfo];
                    }
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
        }
    }];
}

#pragma mark - 查询未接单个数
- (void)queryTakeoutNewOrder:(BOOL)showLoginVC
{
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    UntreatedOrderStatisticsRequest *request = [[[UntreatedOrderStatisticsRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/count", kTakeoutServerIP];
    [takeoutService untreatedOrderStatistics:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                if (responseCode == 22000 && showLoginVC) {
                    [MBProgressHUD showHUDWithTitle:@""
                                             detail:@"该账号已在其它设备登录，请重新登陆！"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                         completion:^{
                                             
                                             [JCHUserInfoViewController clearUserLoginStatus];
                                             JCHLoginViewController *loginController = [[[JCHLoginViewController alloc] init] autorelease];
                                             loginController.showBackNavigationItem = NO;
                                             loginController.registButtonShow = YES;
                                             loginController.hidesBottomBarWhenPushed = YES;
                                             
                                             AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
                                             [appDelegate.rootNavigationController pushViewController:loginController animated:YES];
                                         }];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                NSInteger newOrderCount = [responseData[@"data"][@"count"] integerValue];
                UITabBarController *tabBarController = [[AppDelegate sharedAppDelegate].rootNavigationController.childViewControllers firstObject];
                UITabBarItem *tabBarItem = [tabBarController.tabBar.items firstObject];
                if (newOrderCount == 0) {
                    tabBarItem.badgeValue = nil;
                } else {
                    tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", newOrderCount];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
        }
    }];
}

#pragma mark - 拉取已完成订单
- (void)fetchCompletedOrders
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    FetchCompleteOrderRequest *request = [[[FetchCompleteOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/pullComplete", kTakeoutServerIP];
    
    [takeoutService fetchCompleteOrder:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
    
            } else {
                NSLog(@"responseData = %@", responseData);
                
                // 插入货单到本地
                NSString *jsonString = [responseData dataToJSONString];
                NSLog(@"%@", jsonString);
                NSArray *ordersInfo = responseData[@"data"][@"orders"];

                for (NSInteger i = 0; i < ordersInfo.count; i++) {
                    NSDictionary *orderInfoDict = ordersInfo[i];
                    JCHTakeoutOrderInfoModel *model = [JCHTakeoutOrderInfoModel modelWithDictionary:orderInfoDict];
                    [self saveOrderInfo:model];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);

        }
    }];
}

// 根据查询到的订单信息将订单保存到本地
- (void)saveOrderInfo:(JCHTakeoutOrderInfoModel *)model
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    NSArray *allProduct = [productService queryAllCuisine:YES];
    NSArray *allSKUType = nil;
    [skuService queryAllSKUType:&allSKUType];
    SKUTypeRecord4Cocoa *skuTypeRecord = [allSKUType firstObject];
    
    NSArray *allSKUValue = nil;
    if(skuTypeRecord) {
        [skuService querySKUWithType:skuTypeRecord.skuTypeUUID skuRecordVector:&allSKUValue];
    }
    
    NSMutableArray *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    CGFloat boxTotalPrice = 0;
    for (NSInteger j = 0; j < model.detail.count; j++) {
        
        JCHTakeoutOrderInfoDishModel *dishModel = model.detail[j];
        
        NSString *takeoutBindId = dishModel.foodId;
        ProductRecord4Cocoa *currentProductRecord = nil;
        // 根据bindID在本地找到这个菜品
        for (ProductRecord4Cocoa *productRecord in allProduct) {
            
            NSString *dishTakeoutBindId = [JCHTakeoutManager getDishTakeoutBindID:productRecord takeoutResource:model.resource];
            if ([dishTakeoutBindId isEqualToString:takeoutBindId]) {
                currentProductRecord = productRecord;
                break;
            }
        }
        
        if (!currentProductRecord) {
            continue;
        }
        NSInteger productCount = dishModel.quantity;
        CGFloat productPrice = dishModel.price;
        NSString *skuName = dishModel.skuName;
        NSString *skuUUID = nil;
        for (SKUValueRecord4Cocoa *skuValueRecord in allSKUValue) {
            if ([skuValueRecord.skuValue isEqualToString:skuName]) {
                skuUUID = skuValueRecord.skuValueUUID;
                break;
            }
        }
        
        CGFloat boxPrice = dishModel.boxNum * dishModel.boxPrice;
        boxTotalPrice += boxPrice;
        
        ManifestTransactionRecord4Cocoa *record = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        record.productCategory = currentProductRecord.goods_type;
        record.productCount = productCount;
        record.productDiscount = 1.0;
        record.productName = currentProductRecord.goods_name;
        record.productPrice = productPrice;
        record.productUnit = currentProductRecord.goods_unit;
        record.goodsNameUUID = currentProductRecord.goods_uuid;
        record.goodsCategoryUUID = currentProductRecord.goods_category_uuid;
        record.unitUUID = currentProductRecord.goods_unit_uuid;
        record.warehouseUUID = [[[ServiceFactory sharedInstance] utilityService] getDefaultWarehouseUUID];
        record.transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        record.dishProperty = dishModel.foodProperty;
        
        if (skuUUID) {
            record.goodsSKUUUIDArray = @[skuUUID];
        } else {
            record.goodsSKUUUIDArray = @[];
        }
        
        [transactionList addObject:record];
    }
    
    if (transactionList.count == 0) {
        return;
    }
    
    CGFloat deliveryAmount = model.shippingFee;;
    CGFloat boxAmount = boxTotalPrice;
    NSString *takeoutRemark = model.caution;
    
    NSMutableArray *feeRecordList = [NSMutableArray array];
    
    // 配送费
    if (deliveryAmount > 0) {
        FeeRecord4Cocoa *deliveryFeeRecord = [[[FeeRecord4Cocoa alloc] init] autorelease];
        deliveryFeeRecord.feeAccountUUID = [manifestService getShippingFeeAccountUUID];
        deliveryFeeRecord.fee = deliveryAmount;
        [feeRecordList addObject:deliveryFeeRecord];
    }
    
    // 餐盒费
    if (boxAmount > 0) {
        FeeRecord4Cocoa *boxFeeRecord = [[[FeeRecord4Cocoa alloc] init] autorelease];
        boxFeeRecord.feeAccountUUID = [manifestService getBoxFeeAccountUUID];
        boxFeeRecord.fee = boxAmount;
        [feeRecordList addObject:boxFeeRecord];
    }
    
    NSString *counterPartyUUID = [manifestService getDefaultCustomUUID];
    NSString *paymentAccountUUID = @"";
    if (model.payType == kJCHTakeoutPayTypeDelivery) {
        paymentAccountUUID = [manifestService getDefaultCashRMBAccountUUID];
    } else if (model.payType == kJCHTakeoutPayTypeHasPayedOnline) {
        
        if (model.resource == kJCHTakeoutResourceMeituan) {
            paymentAccountUUID = [manifestService getMeiTuanTakeoutAccountUUID];
        } else if (model.resource == kJCHTakeoutResourceEleme) {
            paymentAccountUUID = [manifestService getEleTakeoutAccountUUID];
        } else if (model.resource == kJCHTakeoutResourceBaidu) {
            paymentAccountUUID = [manifestService getBaiduTakeoutAccountUUID];
        }
    }
    
    NSString *manifestID = [manifestService createManifestID:kJCHOrderShipment];
    NSInteger operatorID = [[[JCHSyncStatusManager shareInstance] userID] integerValue];
    
    NSArray *takeoutResourceList = @[@"美团外卖", @"饿了么", @"百度外卖"];
    
    NSString *takeoutOrderResource = takeoutResourceList[model.resource - 1];
    
    NSString *manifestRemark = [NSString stringWithFormat:@"%@ 订单编号:%@\n%@", takeoutOrderResource, model.orderIdView, takeoutRemark];
    
    
    // 添加联系人
    NSString *recipientName = model.recipientName;
    NSInteger gender = 0;
    if ([model.recipientName containsString:@"(先生)"]) {
        recipientName = [model.recipientName stringByReplacingOccurrencesOfString:@"(先生)" withString:@""];
        gender = 0;
    } else if ([model.recipientName containsString:@" 先生"]) {
        recipientName = [model.recipientName stringByReplacingOccurrencesOfString:@" 先生" withString:@""];
        gender = 0;
    } else if ([model.recipientName containsString:@"(女士)"]) {
        recipientName = [model.recipientName stringByReplacingOccurrencesOfString:@"(女士)" withString:@""];
        gender = 1;
    } else if ([model.recipientName containsString:@" 女士"]) {
        recipientName = [model.recipientName stringByReplacingOccurrencesOfString:@" 女士" withString:@""];
        gender = 1;
    }
    
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactRecord = [[[ContactsRecord4Cocoa alloc] init] autorelease];
    
    contactRecord.name = recipientName;
    contactRecord.phone = model.recipientPhone;
    contactRecord.address = model.recipientAddress;
    contactRecord.gender = gender;
    contactRecord.birthday = 0;
    contactRecord.relationshipVector = @[@"客户"];
    NSString *contactUUID =  nil;
    [contactsService addOrUpdateContactsByPhone:&contactUUID contactRecord:contactRecord];
    
    if (contactUUID) {
        counterPartyUUID = contactUUID;
    }
    
    ManifestInfoRecord4Cocoa *manifestInfoRecord = [[[ManifestInfoRecord4Cocoa alloc] init] autorelease];
    manifestInfoRecord.manifestID = manifestID;
    manifestInfoRecord.manifestType = kJCHOrderShipment;
    manifestInfoRecord.manifestRemark = manifestRemark;
    manifestInfoRecord.manifestTimestamp = model.orderTime;
    manifestInfoRecord.thirdPartOrderID = model.orderIdView;
    manifestInfoRecord.thirdPartType = [JCHTakeoutManager getThirdPartType:model.resource];
    manifestInfoRecord.expressCompany = @"";
    manifestInfoRecord.expressNumber = @"";
    manifestInfoRecord.consigneeName = contactRecord.name;
    manifestInfoRecord.consigneePhone = contactRecord.phone;
    manifestInfoRecord.consigneeAddress = contactRecord.address;
    
    
    
    int status = [manifestService insertManifest:manifestInfoRecord
                                 transactionList:transactionList
                                manifestDiscount:1.0f
                                     eraseAmount:0
                                    counterParty:counterPartyUUID
                              paymentAccountUUID:paymentAccountUUID
                                      operatorID:operatorID
                                   feeRecordList:feeRecordList];
    
    NSLog(@"保存订单 %d, 订单id = %@", status, model.orderIdView);
}

#pragma mark - 拉取已退单的订单
- (void)fetchRefundedOrders
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    FetchBackOrderRequest *request = [[[FetchBackOrderRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/order/pullBack", kTakeoutServerIP];
    
    [takeoutService fetchBackOrder:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                
            } else {
                NSLog(@"responseData = %@", responseData);
                
                NSArray *orders = responseData[@"data"][@"orders"];
                // 本地退单
    
                for (NSDictionary *orderInfo in orders) {
                    [self refundOrder:orderInfo];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            
        }
    }];
}

- (void)refundOrder:(NSDictionary *)orderInfo
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    NSString *orderIdView = orderInfo[@"orderIdView"];
    JCHTakeoutResource resource = [orderInfo[@"resource"] integerValue];
    
    int status = [manifestService returnThirdPartManifest:[JCHTakeoutManager getThirdPartType:resource]
                                         thirdPartOrderID:orderIdView];
    NSLog(@"退单成功 %d, 订单id = %@", status, orderIdView);
}

#pragma mark - 同步外卖数据
- (void)syncTakeoutData:(JCHTakeoutResource)takeoutResource
{
    NSString *detail = @"数据同步中";
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        detail = @"美团数据同步中";
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        detail = @"饿了么数据同步中";
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        detail = @"百度数据同步中";
    }
    
    [MBProgressHUD showHUDWithTitle:@""
                             detail:detail
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    // 1）要先查询绑定状态，判断是否为第一次同步数据
    [self queryBindStatus:^(NSArray *bindStatus) {
        
        // 2）同步数据
        
        if (bindStatus.count > 0) {
            [self handleSyncData:takeoutResource
                      bindStatus:bindStatus];
        } else {
            [MBProgressHUD hideAllHudsForWindow];
        }
    }];
}

// 查询绑定状态
- (void)queryBindStatus:(void(^)(NSArray *))result
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    QueryBindStatusRequest *bindStatusRequest = [[[QueryBindStatusRequest alloc] init] autorelease];
    bindStatusRequest.token = statusManager.syncToken;
    bindStatusRequest.bookID = statusManager.accountBookID;
    bindStatusRequest.serviceURL = [NSString stringWithFormat:@"%@/book/binds", kTakeoutServerIP];
    
    [takeoutService queryBindStatus:bindStatusRequest callback:^(id response) {
        
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
                
                NSArray *bindStatus = responseData[@"data"][@"binds"];
                
                if (result) {
                    result(bindStatus);
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""];
        }
    }];
}

- (void)handleSyncData:(JCHTakeoutResource)takeoutResource
            bindStatus:(NSArray *)bindStatus
{
    // 是否所有平台都未同步过
    BOOL allTakeoutHasnotSyncFlag = YES;
    for (NSDictionary *bindInfo in bindStatus) {
        NSInteger syncStatus = [bindInfo[@"syncTimes"] integerValue];
        
        if (syncStatus == 1) {
            allTakeoutHasnotSyncFlag = NO;
            break;
        }
    }
    
    
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    
    TakeOutBindSyncRequest *syncRequest = [[[TakeOutBindSyncRequest alloc] init] autorelease];
    syncRequest.token = statusManager.syncToken;
    syncRequest.bookID = statusManager.accountBookID;
    syncRequest.serviceURL = [NSString stringWithFormat:@"%@/bind/sync", kTakeoutServerIP];
    syncRequest.resource = [NSString stringWithFormat:@"%ld", takeoutResource];
    
    [takeoutService bindShopSync:syncRequest callback:^(id response) {
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
                
                NSDictionary *takeoutData = response[@"data"][@"data"];
                NSInteger syncStatus = [takeoutData[@"sync"] integerValue];
                
                
                if (syncStatus == 0) {
                    if (allTakeoutHasnotSyncFlag) {
                        // 首次同步数据
                        [self transformDataFirstSync:takeoutData
                                     takeoutResource:takeoutResource];
                    } else {
                        // 非首次同步数据
                        [self transformDataNotFirstSync:takeoutData
                                             bindStatus:bindStatus
                                        takeoutResource:takeoutResource];
                    }
                } else {
                    [MBProgressHUD hideAllHudsForWindow];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""];
        }
    }];
}

// 首次同步数据
- (void)transformDataFirstSync:(NSDictionary *)takeoutData
               takeoutResource:(JCHTakeoutResource)takeoutResource
{
    // 1) 清空本地数据
    [[ServiceFactory sharedInstance] clearDatabase];
    
    // * 删除默认分类
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    NSArray *allCagegory = [categoryService queryAllCategory];
    for (CategoryRecord4Cocoa *categoryRecord in allCagegory) {
        [categoryService deleteCategory:categoryRecord.categoryUUID];
    }
    
    // 2) 添加分类
    NSArray *categories = takeoutData[@"categories"];
    [self addCategories:categories];
    
    
    // 3) 添加单位
    NSArray *units = takeoutData[@"units"];
    [self addUnits:units];
    
    // 4) 添加sku
    NSArray *skus = takeoutData[@"skus"];
    [self addSKU:skus];
    
    // 5) 添加菜品
    NSArray *dishes = takeoutData[@"dishes"];
    for (NSDictionary *dishData in dishes) {
        [self addDish:dishData takeoutResource:takeoutResource];
    }
    
    [MBProgressHUD showResultCustomViewHUDWithTitle:@"" detail:@"同步成功" duration:kJCHDefaultShowHudTime result:YES completion:nil];
}

// 非首次同步数据
- (void)transformDataNotFirstSync:(NSDictionary *)takeoutData
                       bindStatus:(NSArray *)bindStatus
                  takeoutResource:(JCHTakeoutResource)takeoutResource
{
    // 1) 添加分类
    NSArray *categories = takeoutData[@"categories"];
    [self addCategories:categories];
    
    // 2) 添加单位
    NSArray *units = takeoutData[@"units"];
    [self addUnits:units];
    
    // 3) 添加sku
    NSArray *skus = takeoutData[@"skus"];
    [self addSKU:skus];
    
    // 4) 添加菜品
    NSArray *dishes = takeoutData[@"dishes"];
    
    
    _uploadImageGroup = dispatch_group_create();
    
    for (NSDictionary *dishData in dishes) {
        
        [self addDish:dishData takeoutResource:takeoutResource];
    }
    
    // 5）本地菜品没有绑定id的要自己生成绑定id
    [self handleTakeoutBindIDForNotFirstSync:bindStatus];
    
    dispatch_group_notify(_uploadImageGroup, dispatch_get_main_queue(), ^{
        [self putawayDishesAfterUplpadImage:bindStatus];
        dispatch_release(_uploadImageGroup);
        _uploadImageGroup = NULL;
    });
}

- (void)putawayDishesAfterUplpadImage:(NSArray *)bindStatus
{
    // 6) 上架所有菜品
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    NSArray *allDishes = [productService queryAllCuisine:YES];
    
    NSMutableDictionary *imageURLForDishUUID = [NSMutableDictionary dictionary];
    
    dispatch_group_t getURLGroup = dispatch_group_create();
    
    for (ProductRecord4Cocoa *dish in allDishes) {
        
        dispatch_group_enter(getURLGroup);
        
        [JCHImageUtility getImageURL:@[dish.goods_image_name] successHandler:^(NSDictionary *dict) {
            
            dispatch_group_leave(getURLGroup);
            
            NSString *imageURL = dict[dish.goods_image_name];
            imageURL = [imageURL stringByReplacingOccurrencesOfString:@"\\/"
                                                           withString:@"/"];
            if (!imageURL) {
                imageURL = @"";
            }
            
            [imageURLForDishUUID setObject:imageURL forKey:dish.goods_uuid];
        } failureHandler:^(NSError *error) {
            
            dispatch_group_leave(getURLGroup);
            
            [imageURLForDishUUID setObject:@"" forKey:dish.goods_uuid];
        }];
    }
    
    dispatch_group_notify(getURLGroup, dispatch_get_main_queue(), ^{
        
        dispatch_group_t putawayGroup = dispatch_group_create();
        
        
        
        for (NSDictionary *dict in bindStatus) {
            dispatch_group_enter(putawayGroup);
            JCHTakeoutResource takeoutResource = [dict[@"type"] integerValue];
            
            [self handlePutawayDishes:allDishes takeoutResource:takeoutResource imageURLForDishUUID:imageURLForDishUUID callback:^{
                dispatch_group_leave(putawayGroup);
            }];
        }
        
        dispatch_group_notify(putawayGroup, dispatch_get_main_queue(), ^{
            [MBProgressHUD showResultCustomViewHUDWithTitle:@"" detail:@"同步成功" duration:kJCHDefaultShowHudTime result:YES completion:nil];
            dispatch_release(putawayGroup);
            dispatch_release(getURLGroup);
        });
    });
}


// 添加分类
- (void)addCategories:(NSArray *)categories
{
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    
    NSArray *allCategory = [categoryService queryAllCategory];
    
    for (NSDictionary *catetoryData in categories) {
        NSString *categoryName = catetoryData[@"newName"];
        
        BOOL existing = NO;
        for (CategoryRecord4Cocoa *categoryRecord in allCategory) {
            if ([categoryRecord.categoryName isEqualToString:categoryName]) {
                existing = YES;
                break;
            }
        }
        if (existing == NO) {
            CategoryRecord4Cocoa *categoryRecord = [[[CategoryRecord4Cocoa alloc] init] autorelease];
            categoryRecord.categoryMemo = @"";
            categoryRecord.categoryName = categoryName;
            categoryRecord.categoryProperty = @"";
            categoryRecord.categoryUUID = [utilityService generateUUID];
            [categoryService insertCategory:categoryRecord];
        }
    }
}

// 添加单位
- (void)addUnits:(NSArray *)units
{
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    NSArray *allUnits = [unitService queryAllUnit];
    
    
    for (NSDictionary *unitData in units) {
        NSString *unitName = unitData[@"unitName"];
        
        BOOL existing = NO;
        for (UnitRecord4Cocoa *unitRecord in allUnits) {
            if ([unitRecord.unitName isEqualToString:unitName]) {
                existing = YES;
                break;
            }
        }
        if (existing == NO) {
            UnitRecord4Cocoa *unitRecord = [[[UnitRecord4Cocoa alloc] init] autorelease];
            unitRecord.unitDecimalDigits = 0;
            unitRecord.unitName = unitName;
            unitRecord.unitMemo = @"";
            unitRecord.unitProperty = @"";
            [unitService insertUnit:unitRecord];
        }
    }
}

// 添加SKU
- (void)addSKU:(NSArray *)skus
{
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    NSArray *allSKU = nil;
    [skuService queryAllSKUType:&allSKU];
    
    SKUTypeRecord4Cocoa *theOnlySKUTypeRecord = nil;
    if (allSKU.count == 0) {
        // 先添加一种skuType
        SKUTypeRecord4Cocoa *skuTypeRecord = [[[SKUTypeRecord4Cocoa alloc] init] autorelease];
        skuTypeRecord.skuTypeName = @"规格";
        skuTypeRecord.skuSortIndex = 0;
        skuTypeRecord.skuTypeUUID = [utilityService generateUUID];
        [skuService addSKUType:skuTypeRecord];
        
        theOnlySKUTypeRecord = skuTypeRecord;
    } else {
        theOnlySKUTypeRecord = allSKU.firstObject;
    }
    
    NSArray *allSKUValue = nil;
    [skuService querySKUWithType:theOnlySKUTypeRecord.skuTypeUUID skuRecordVector:&allSKUValue];
    
    for (NSDictionary *skuValueData in skus) {
        
        NSString *skuName = skuValueData[@"name"];
        BOOL existing = NO;
        for (SKUValueRecord4Cocoa *skuValueRecord in allSKUValue) {
            if ([skuValueRecord.skuValue isEqualToString:skuName]) {
                existing = YES;
                break;
            }
        }
        if (existing == NO) {
            
            SKUValueRecord4Cocoa *skuValueRecord = [[[SKUValueRecord4Cocoa alloc] init] autorelease];
            skuValueRecord.skuValue = skuName;
            skuValueRecord.skuValueUUID = [utilityService generateUUID];
            skuValueRecord.skuType = theOnlySKUTypeRecord.skuTypeName;
            skuValueRecord.skuTypeUUID = theOnlySKUTypeRecord.skuTypeUUID;
            [skuService addSKUValue:skuValueRecord];
        }
    }
}

- (void)addDish:(NSDictionary *)dishData takeoutResource:(JCHTakeoutResource)takeoutResource
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    
    NSString *unitName = dishData[@"unitName"];
    NSString *categoryName = dishData[@"categoryName"];
    NSString *dishName = dishData[@"name"];
    
    BOOL exisiting = NO;
    
    NSArray *allDishes = [productService queryAllCuisine:YES];
    for (ProductRecord4Cocoa *productRecord in allDishes) {
        if ([productRecord.goods_name isEqualToString:dishName] && [productRecord.goods_type isEqualToString:categoryName]) {
            exisiting = YES;
            
            // 发现相同的商品，说明非第一次同步数据，则只需将本次的菜品id更新到商品中
            [JCHTakeoutManager setDishTakeoutBindID:productRecord.takoutRecord
                                    takeoutResource:takeoutResource
                                             bindID:dishData[@"id"]];
            
            [productService updateCuisine:productRecord];
            return;
        }
    }
    
    UnitRecord4Cocoa *currentUnitRecord = nil;
    CategoryRecord4Cocoa *currentCategoryRecord = nil;
    
    NSArray *allUnitRecord = [unitService queryAllUnit];
    NSArray *allCategoryRecord = [categoryService queryAllCategory];
    
    // 找到unitRecord
    for (UnitRecord4Cocoa *unitRecord in allUnitRecord) {
        if ([unitRecord.unitName isEqualToString:unitName]) {
            currentUnitRecord = unitRecord;
            break;
        }
    }
    
    // 找到categoryRecord
    for (CategoryRecord4Cocoa *categoryRecord in allCategoryRecord) {
        if ([categoryRecord.categoryName isEqualToString:categoryName]) {
            currentCategoryRecord = categoryRecord;
            break;
        }
    }
    
    NSString *goodsSKUUUID = [utilityService generateUUID];
    NSArray *allSKUType = nil;
    NSArray *allSKUValue = nil;
    [skuService queryAllSKUType:&allSKUType];
    SKUTypeRecord4Cocoa *skuTypeRecord = [allSKUType firstObject];
    [skuService querySKUWithType:skuTypeRecord.skuTypeUUID skuRecordVector:&allSKUValue];
    
    
    BOOL isSKUProduct = NO;
    NSArray *productSKUData = dishData[@"skus"];
    
    if (productSKUData.count > 1) {
        isSKUProduct = YES;
        
        for (NSDictionary *skuData in productSKUData) {
            NSString *skuValueName = skuData[@"name"];
            for (SKUValueRecord4Cocoa *skuValueRecord in allSKUValue) {
                if ([skuValueRecord.skuValue isEqualToString:skuValueName]) {
                    [skuService addGoodsSKU:goodsSKUUUID skuUUID:skuValueRecord.skuValueUUID];
                    break;
                }
            }
        }
    }
    
    ProductRecord4Cocoa *productRecord = [[[ProductRecord4Cocoa alloc] init] autorelease];
    productRecord.goods_name = dishName;
    productRecord.goods_domain = @"";
    productRecord.goods_type = categoryName;
    productRecord.goods_memo = @"";
    productRecord.goods_image_name = @"";
    productRecord.goods_property = @"";
    productRecord.goods_unit = unitName;
    productRecord.goods_code = @"";
    productRecord.goods_category_path = @"";
    productRecord.goods_sell_price = [dishData[@"price"] doubleValue];
    productRecord.goods_currency = @"人民币";
    productRecord.goods_unit_digits = 0;
    productRecord.goods_hiden_flag = NO;
    productRecord.sku_hiden_flag = !isSKUProduct;
    productRecord.goods_uuid = [utilityService generateUUID];
    
    TakeoutProductRecord4Cocoa *takeoutProductRecord = [[[TakeoutProductRecord4Cocoa alloc] init] autorelease];
    
    [JCHTakeoutManager setDishTakeoutBindID:takeoutProductRecord takeoutResource:takeoutResource bindID:dishData[@"id"]];
    
    takeoutProductRecord.boxNum = [dishData[@"boxNum"] integerValue];
    takeoutProductRecord.boxPrice = [dishData[@"boxPrice"] doubleValue];
    
    NSArray *properties = dishData[@"properties"];
    
    productRecord.cuisineProperty = [properties dataToJSONString];
    productRecord.takoutRecord = takeoutProductRecord;
    
    // 更新takeouRecord里面的status
    [JCHTakeoutManager updateTakeoutStatus:![dishData[@"isSoldOut"] boolValue] takeoutResource:takeoutResource dish:productRecord];
    
    productRecord.goods_unit_uuid = currentUnitRecord.unitUUID;
    productRecord.goods_category_uuid = currentCategoryRecord.categoryUUID;
    productRecord.goods_sku_uuid = goodsSKUUUID;
    productRecord.goods_bar_code = @"";
    productRecord.goods_merchant_code = @"";
    productRecord.goods_last_purchase_price = 0.00;
    productRecord.sort_index = 0;
    productRecord.has_sold_out = NO;
    productRecord.is_multi_unit_enable = NO;
    
    // 保存图片
    NSString *imageURL = dishData[@"image"];
    if (imageURL && ![imageURL isEmptyString]) {
        [self saveProductImage:dishData[@"image"] productRecord:productRecord imageUUID:dishData[@"imageUuid"]];
    }
    
    
    // 多规格设置单品成本价
    if (productRecord.sku_hiden_flag == NO) {
        [self setSKUPrice:dishData productRecord:productRecord takeoutResource:takeoutResource];
    }
    
    //    [productService addProduct:productRecord recordVector:beginInvenyoryArray];
    int result = [productService addCuisine:productRecord];
    NSLog(@"addCuisineResult = %d", result);
}

- (void)saveProductImage:(NSString *)imageUrl productRecord:(ProductRecord4Cocoa *)productRecord imageUUID:(NSString *)imageUUID
{
    UIImage *productImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]] autorelease];
//    productImage = [productImage imageByScalingToSize:CGSizeMake(600, 600)];
    productImage = [UIImage compressImage:productImage scaledToSize:CGSizeMake(600, 600)];
    if (productImage) {
        // 压缩图片不超过400k
//        productImage = [JCHImageUtility compressImage:productImage maxLength:400];
        NSData *imageData = [JCHImageUtility compressImage:productImage maxLength:400];
        
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *imagesDirectory = [document stringByAppendingPathComponent:@"images"];
        
        
        NSString *imageName = imageUUID;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL saveImageSuccess = [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@", imagesDirectory, imageName] contents:imageData attributes:nil];
        if (NO == saveImageSuccess) {
            NSLog(@"save image fail");
        } else {
            
            productRecord.goods_image_name = imageName;
            
            // 上传图片到七牛
            if (_uploadImageGroup) {
                dispatch_group_enter(_uploadImageGroup);
                NSLog(@"dispatch_group_enter");
            }
            
            [JCHImageUtility uploadProductImages:@[imageName] completionCallBack:^{
                if (_uploadImageGroup) {
                    dispatch_group_leave(_uploadImageGroup);
                    NSLog(@"dispatch_group_leave");
                }
            }];
        }
    }
}

- (void)setSKUPrice:(NSDictionary *)dishData productRecord:(ProductRecord4Cocoa *)productRecord takeoutResource:(JCHTakeoutResource)takeoutResource
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    NSArray *allSKUType = nil;
    NSArray *allSKUValue = nil;
    [skuService queryAllSKUType:&allSKUType];
    SKUTypeRecord4Cocoa *skuTypeRecord = [allSKUType firstObject];
    [skuService querySKUWithType:skuTypeRecord.skuTypeUUID skuRecordVector:&allSKUValue];
    
    NSMutableArray *productRecordItems = [NSMutableArray array];
    for (NSDictionary *skuData in dishData[@"skus"]) {
        
        ProductItemRecord4Cocoa *productItem = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
        SKUValueRecord4Cocoa *skuValueRecord = nil;
        for (SKUValueRecord4Cocoa *record in allSKUValue) {
            if ([record.skuValue isEqualToString:skuData[@"name"]]) {
                skuValueRecord = record;
                break;
            }
        }
        productItem.goodsUUID = productRecord.goods_uuid;
        productItem.goodsSkuUUID = @"";
        productItem.goodsUnitUUID = @"";
        productItem.skuUUIDVector = @[skuValueRecord.skuValueUUID];
        productItem.imageName1 = productRecord.goods_image_name;
        productItem.itemPrice = [skuData[@"price"] doubleValue];
        
        TakeoutProductRecord4Cocoa *takeoutProductRecord = [[[TakeoutProductRecord4Cocoa alloc] init] autorelease];
        [JCHTakeoutManager setDishTakeoutBindID:takeoutProductRecord takeoutResource:takeoutResource bindID:skuData[@"id"]];
        takeoutProductRecord.boxNum = [skuData[@"boxNum"] integerValue];
        takeoutProductRecord.boxPrice = [skuData[@"boxPrice"] doubleValue];
        productItem.takoutRecord = takeoutProductRecord;
        [productRecordItems addObject:productItem];
    }
    
    productRecord.productItemList = productRecordItems;
}

// 处理非第一次同步的外卖绑定id,本地菜品没有绑定id的要自己生成绑定id，单品要全新生成绑定id
- (void)handleTakeoutBindIDForNotFirstSync:(NSArray *)bindStatus
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    NSArray *allDishes = [productService queryAllCuisine:YES];
    
    for (ProductRecord4Cocoa *dish in allDishes) {
        for (NSDictionary *bindInfo in bindStatus) {
            
            JCHTakeoutResource takeoutResource = [bindInfo[@"type"] integerValue];
            
            [JCHTakeoutManager setBindIDForAllEmptyBindID:dish.takoutRecord takeoutResource:takeoutResource];
            
            [productService updateCuisine:dish];
        }
        
        NSArray *productItemList = dish.productItemList;
        for (ProductItemRecord4Cocoa *productItemRecord in productItemList) {
            
            for (NSDictionary *bindInfo in bindStatus) {
                
                JCHTakeoutResource takeoutResource = [bindInfo[@"type"] integerValue];
                [JCHTakeoutManager setBindIDForAllEmptyBindID:productItemRecord.takoutRecord takeoutResource:takeoutResource];
            }
        }
        dish.productItemList = productItemList;
        [productService updateCuisine:dish];
    }
}


// 上传所有菜品到某个平台
- (void)handlePutawayDishes:(NSArray *)dishes
            takeoutResource:(JCHTakeoutResource)takeoutResource
        imageURLForDishUUID:(NSDictionary *)imageURLForDishUUID
                   callback:(void(^)())callback
{
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    NSMutableArray *dishList = [NSMutableArray array];
    for (ProductRecord4Cocoa *dish in dishes) {
        NSMutableDictionary *putawayData = [NSMutableDictionary dictionary];
        
        NSMutableArray *skus = [NSMutableArray array];
        
        NSArray *productItemList = dish.productItemList;
        
        // 如果是无规格则要拼一个skuData
        
        if (dish.sku_hiden_flag) {
            NSMutableDictionary *skuDict = [NSMutableDictionary dictionary];
            [skuDict setObject:@(dish.goods_sell_price) forKey:@"price"];
            [skuDict setObject:@"*" forKey:@"count"];
            
            
            [skuDict setObject:dish.goods_unit forKey:@"name"];
            [skuDict setObject:@"" forKey:@"remark"];
            [skuDict setObject:@"" forKey:@"barCode"];
            [skuDict setObject:@(dish.takoutRecord.boxNum) forKey:@"boxNum"];
            [skuDict setObject:@(dish.takoutRecord.boxPrice) forKey:@"boxPrice"];
            
            NSString *bindID = [JCHTakeoutManager getDishTakeoutBindID:dish takeoutResource:takeoutResource];
            [skuDict setObject:bindID forKey:@"id"];
            [skus addObject:skuDict];
        } else {
            for (ProductItemRecord4Cocoa *productItemRecord in productItemList) {
                
                NSMutableDictionary *skuDict = [NSMutableDictionary dictionary];
                [skuDict setObject:@(productItemRecord.itemPrice) forKey:@"price"];
                [skuDict setObject:@"*" forKey:@"count"];
                
       
                GoodsSKURecord4Cocoa *goodsSKURecord = nil;
                [skuService queryGoodsSKU:productItemRecord.goodsSkuUUID skuArray:&goodsSKURecord];
                NSArray *skuCombineList = [JCHTransactionUtility getSKUCombineListWithGoodsSKURecord:goodsSKURecord];
                NSString *skuName = skuCombineList.firstObject;
                [skuDict setObject:skuName forKey:@"name"];
                
                [skuDict setObject:@"" forKey:@"remark"];
                [skuDict setObject:@"" forKey:@"barCode"];
                [skuDict setObject:@(productItemRecord.takoutRecord.boxNum) forKey:@"boxNum"];
                [skuDict setObject:@(productItemRecord.takoutRecord.boxPrice) forKey:@"boxPrice"];
                
                NSString *skuID = [JCHTakeoutManager getProductItemTakeoutBindID:productItemRecord takeoutResource:takeoutResource];
                [skuDict setObject:skuID forKey:@"id"];
                [skus addObject:skuDict];
            }
        }
        
        
        [putawayData setObject:skus forKey:@"skus"];
        
        NSString *imageURL = imageURLForDishUUID[dish.goods_uuid];
        
        [putawayData setObject:imageURL forKey:@"image"];
        [putawayData setObject:JCHSafeString(dish.goods_image_name) forKey:@"imageUuid"];
        [putawayData setObject:@(takeoutResource) forKey:@"resource"];
        [putawayData setObject:JCHSafeString(dish.goods_memo) forKey:@"remark"];
        [putawayData setObject:dish.goods_unit forKey:@"unitName"];
        [putawayData setObject:dish.goods_type forKey:@"categoryName"];
        
        // 排序默认传1
        [putawayData setObject:@"1" forKey:@"sequence"];
        [putawayData setObject:@"1" forKey:@"minOrderCount"];
        [putawayData setObject:[NSString stringWithFormat:@"%.2f", dish.goods_sell_price] forKeyedSubscript:@"price"];
        [putawayData setObject:@"0" forKey:@"isSoldOut"];
        [putawayData setObject:dish.goods_name forKey:@"name"];
        
        NSString *takeoutBindID = [JCHTakeoutManager getDishTakeoutBindID:dish takeoutResource:takeoutResource];
        [putawayData setObject:takeoutBindID forKey:@"id"];
        [putawayData setObject:@(dish.takoutRecord.boxNum) forKey:@"boxNum"];
        [putawayData setObject:@(dish.takoutRecord.boxPrice) forKey:@"boxPrice"];
        
        
        if (!dish.cuisineProperty || [dish.cuisineProperty isEmptyString]) {
            [putawayData setObject:@[] forKey:@"properties"];
        } else {
            NSArray *properties = [dish.cuisineProperty jsonStringToArrayOrDictionary];
            [putawayData setObject:properties forKey:@"properties"];
        }
        
        
        [dishList addObject:putawayData];
    }
    
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    PutAwayProductRequest *request = [[[PutAwayProductRequest alloc] init] autorelease];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/dish/putOn", kTakeoutServerIP];
    request.resource = [NSString stringWithFormat:@"%ld", takeoutResource];
    request.dishList = dishList;

    [takeoutService putAwayProduct:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            NSLog(@"resource = %@", request.resource);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
            } else {
                NSLog(@"responseData = %@, resource = %@", responseData, request.resource);
                
                id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
                
                for (ProductRecord4Cocoa *dish in dishes) {
                    [JCHTakeoutManager updateTakeoutStatus:1
                                           takeoutResource:takeoutResource
                                                      dish:dish];
                    [productService updateCuisine:dish];
                }
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
        }
        
        if (callback) {
            callback();
        }
    }];
}


#pragma mark - 类方法
// 获取平台的名称
+ (NSString *)getTakeoutPlatformName:(JCHTakeoutResource)takeoutResource
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        return @"美团外卖";
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        return @"饿了么";
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        return @"百度外卖";
    } else {
        return @"未知平台";
    }
}

// 根据平台返回菜品的该平台绑定id
+ (NSString *)getDishTakeoutBindID:(ProductRecord4Cocoa *)dish
                   takeoutResource:(JCHTakeoutResource)takeoutResource
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        return dish.takoutRecord.meituanBindID;
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        return dish.takoutRecord.eleBindID;
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        return dish.takoutRecord.baiduBindID;
    } else {
        return @"";
    }
}

// 根据平台返回单品的该平台绑定id
+ (NSString *)getProductItemTakeoutBindID:(ProductItemRecord4Cocoa *)productItem
                          takeoutResource:(JCHTakeoutResource)takeoutResource
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        return productItem.takoutRecord.meituanBindID;
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        return productItem.takoutRecord.eleBindID;
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        return productItem.takoutRecord.baiduBindID;
    } else {
        return @"";
    }
}

+ (void)setDishTakeoutBindID:(TakeoutProductRecord4Cocoa *)takeoutRecord
             takeoutResource:(JCHTakeoutResource)takeoutResource
                    bindID:(NSString *)bindID
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        takeoutRecord.meituanBindID = bindID;
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        takeoutRecord.eleBindID = bindID;
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        takeoutRecord.baiduBindID = bindID;
    }
}


// 更新菜品的绑定状态
+ (void)updateTakeoutStatus:(NSInteger)status
            takeoutResource:(JCHTakeoutResource)takeoutResource
                     dish:(ProductRecord4Cocoa *)dish
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        dish.takoutRecord.meituanStatus = status;
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        dish.takoutRecord.eleStatus = status;
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        dish.takoutRecord.baiduStatus = status;
    }
}

// 获取菜品某一平台的上下架状态
+ (NSInteger)getTakeoutStatus:(ProductRecord4Cocoa *)dish
              takeoutResource:(JCHTakeoutResource)takeoutResource
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        return dish.takoutRecord.meituanStatus;
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        return dish.takoutRecord.eleStatus;
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        return dish.takoutRecord.baiduStatus;
    } else {
        return 0;
    }
}

// 设置本地数据对应该平台的绑定id（如果有值不需要设置）
+ (void)setBindIDForAllEmptyBindID:(TakeoutProductRecord4Cocoa *)takeoutRecord
                   takeoutResource:(JCHTakeoutResource)takeoutResource
{
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        if (takeoutRecord.meituanBindID == nil || [takeoutRecord.meituanBindID isEmptyString]) {
            takeoutRecord.meituanBindID = [utilityService generateUUID];
        }
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        if (takeoutRecord.eleBindID == nil || [takeoutRecord.eleBindID isEmptyString] ) {
            takeoutRecord.eleBindID = [utilityService generateUUID];
        }
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        if (takeoutRecord.baiduBindID == nil || [takeoutRecord.baiduBindID isEmptyString]) {
            takeoutRecord.baiduBindID = [utilityService generateUUID];
        }
    }

}

+ (NSInteger)getThirdPartType:(JCHTakeoutResource)takeoutResource
{
    if (takeoutResource == kJCHTakeoutResourceMeituan) {
        return kJCHThirdPartMeituan;
    } else if (takeoutResource == kJCHTakeoutResourceEleme) {
        return kJCHThirdPartEle;
    } else if (takeoutResource == kJCHTakeoutResourceBaidu) {
        return kJCHThirdPartBaidu;
    } else {
        return 0;
    }
}

@end
