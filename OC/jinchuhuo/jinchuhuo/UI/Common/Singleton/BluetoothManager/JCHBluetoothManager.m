//
//  JCHBluetoothHelper.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBluetoothManager.h"
#import "ProductRecord4Cocoa.h"
#import "NSString+JCHString.h"
#import "JCHAddProductMainViewController.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHSyncStatusManager.h"
#import "JCHManifestType.h"
#import "JCHTransactionUtility.h"
#import "CommonHeader.h"
#import "SEPrinterManager.h"


static NSString *kCanPrintInShipmentKey = @"bluetoothManager.canPrintInShipment";
static NSString *kCanPrintInPurchaseKey = @"bluetoothManager.canPrintInPurchase";
static NSString *kCanPrintInManifestDetailKey = @"bluetoothManager.canPrintInManifestDetail";
static NSString *kNotFirstSettingBluetoothKey = @"bluetoothManager.notFirstSettingBluetooth";
static NSString *kPrintRepeatCountKey = @"bluetoothManager.printRepeatCount";
static NSString *kPrintMeanwhileItemKey = @"bluetoothManager.printMeanwhileItem";
static NSString *kDefaultPrintTypeKey = @"bluetoothManager.defaultPrintType";


static NSInteger kMaxCharNumberOnALine = 32;
static NSInteger kCountOverCharNumber = 16;
static NSInteger kPriceOverCharNumber = 24;
static NSString *kSeparateBrokenLine = @"--------------------------------\n";

#define RMBSymbol @"￥"


typedef NS_ENUM(NSInteger, JCHPrinterMode) {
    kJCHPrinterModeNormal,
    kJCHPrinterModeTakeout,
    kJCHPrinterModeRestaurant,
};

@interface JCHBluetoothManager ()

@property (nonatomic, retain) NSString *productTitle;
@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, assign) JCHPrinterMode printMode;

@end

@implementation JCHBluetoothManager

+ (instancetype)shareInstance
{
    static JCHBluetoothManager *bluetoothManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (bluetoothManager == nil) {
            bluetoothManager = [[JCHBluetoothManager alloc] init];
            
            //第一次打开app 
            if (![JCHUserDefaults boolForKey:kNotFirstSettingBluetoothKey]){
                bluetoothManager.canPrintInPurchase = NO;
                bluetoothManager.canPrintInShipment = YES;
                bluetoothManager.canPrintInManifestDetail = YES;
                bluetoothManager.printRepeatCount = 1;
                bluetoothManager.printMeanwhileItem = kJCHPrintMeanwhileItemNone;
                bluetoothManager.defaultPrintType = kJCHDefaultPrintTypeReceipt;
            }
            [JCHUserDefaults setBool:YES forKey:kNotFirstSettingBluetoothKey];
            [JCHUserDefaults synchronize];
        }
    });
    
    return bluetoothManager;
}



- (void)dealloc
{
    self.productTitle = nil;
    self.takeoutPrintInfo = nil;
    
    [super dealloc];
}

// 自动连接上次连接的设备
- (void)autoConnectLastPeripheral
{
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    [printerManager autoConnectLastPeripheralTimeout:20 completion:nil];
}

- (void)addNewLineData:(HLPrinter *)printer
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    [printer appendCustomData:[@"\n" dataUsingEncoding:enc]];
}


- (NSString *)moveTextToCenter:(NSString *)text
{
    if (text == nil || [text isEqualToString:@""]) {
        return @"";
    } else {
        
        NSMutableString *newText = [NSMutableString string];
        NSInteger num = [text charNumber];
        for (NSInteger i = 0; i < (kMaxCharNumberOnALine - num) / 2; i++) {
            [newText appendString:@" "];
        }
        [newText appendString:text];
        [newText appendString:@"\n"];
        return newText;
    }
}


- (void)addSeperatorLine:(HLPrinter *)printer
{
    NSMutableData *data = [NSMutableData data];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    [data appendData:[kSeparateBrokenLine dataUsingEncoding:enc]];
    
    [printer appendCustomData:data];
}


#pragma mark - 普通版打印
- (void)printManifest:(JCHPrintInfoModel *)model showHud:(BOOL)hud
{
    self.printMode = kJCHPrinterModeNormal;
    
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    NSArray *connectedPerpherals = printerManager.connectedPerpherals;
    if (connectedPerpherals.count == 0) {
        if (hud) {
            [MBProgressHUD showHUDWithTitle:@"未连接设备"
                                     detail:nil
                                   duration:1.5
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
        return;
    }
    
    
    for (CBPeripheral *peripheral in connectedPerpherals) {
        
        [self setGlobalVariabl:peripheral];
        
        HLPrinter *printer = [[[HLPrinter alloc] init] autorelease];
        
        [self addHeader:model printer:printer];
        [self addDetailProductList:model.transactionList printer:printer];
        [self addOtherFeeList:model.otherFeeList printer:printer];
        [self addTotalInfo:model printer:printer];
        [self addFooter:printer];
        
        NSData *data = [printer getFinalData];
        
        [printerManager sendPrintData:data peripheral:peripheral completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error) {
            NSLog(@"%d---%@",completion,error);
        }];
    }
}

// 一些全局变量设置
- (void)setGlobalVariabl:(CBPeripheral *)peripheral
{
    NSString *productTitle = @"";
    if (self.printMode == kJCHPrinterModeNormal) {
        productTitle = @"商品";
    } else if (self.printMode == kJCHPrinterModeTakeout || self.printMode == kJCHPrinterModeRestaurant) {
        productTitle = @"菜品";
    }
    if ([peripheral.name isEqualToString:@"QSprinter"]) {
        kMaxCharNumberOnALine = 31;
        kCountOverCharNumber = 15;
        kPriceOverCharNumber = 23;
        self.productTitle = [NSString stringWithFormat:@"%@       数量    单价    小计", productTitle];
    } else {
        kMaxCharNumberOnALine = 32;
        kCountOverCharNumber = 16;
        kPriceOverCharNumber = 24;
        self.productTitle = [NSString stringWithFormat:@"%@        数量    单价    小计", productTitle];
    }
}

- (void)addHeader:(JCHPrintInfoModel *)printInfo printer:(HLPrinter *)printer
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    BookInfoRecord4Cocoa *bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
    
    //标题
    [printer appendText:@"欢迎光临" alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleSmalle];
    
    //店名
    [printer appendText:[NSString stringWithFormat:@"%@\n", bookInfoRecord.bookName] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleSmalle];

    //货单号
    NSString *manifestID = [NSString stringWithFormat:@"单号:%@", printInfo.manifestID];
    [printer appendText:manifestID alignment:HLTextAlignmentLeft];

    //日期
    NSString *manifestDate = [NSString stringWithFormat:@"日期:%@", printInfo.manifestDate];
    [printer appendText:manifestDate alignment:HLTextAlignmentLeft];
    
    
    //供应商/客户
    NSString *member = nil;
    if (printInfo.manifestType == kJCHOrderShipment || printInfo.manifestType == kJCHOrderShipmentReject) {
        member = [NSString stringWithFormat:@"客户:%@", printInfo.contactName ? printInfo.contactName : @"默认客户"];
    } else if (printInfo.manifestType == kJCHOrderPurchases || printInfo.manifestType == kJCHOrderPurchasesReject) {
        member = [NSString stringWithFormat:@"供应商:%@", printInfo.contactName ? printInfo.contactName : @"默认供应商"];
    }
    [printer appendText:member alignment:HLTextAlignmentLeft];
    [printer appendSeperatorLine];
}

- (void)addOtherFeeList:(NSArray *)feeList printer:(HLPrinter *)printer
{
    if (feeList.count > 0) {
        
        NSMutableData *data = [NSMutableData data];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        CGFloat totalOtherFee = 0;
        for (FeeRecord4Cocoa *feeRecord in feeList) {
            
            if (feeRecord.fee != 0) {
                NSString *title = [NSString stringWithFormat:@"%@:", feeRecord.feeAccountName];
                NSString *feeInfo = [self addTitle:title
                                             value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, feeRecord.fee]];
                [data appendData:[feeInfo dataUsingEncoding:enc]];
                totalOtherFee += feeRecord.fee;
            }
        }
        self.totalAmount += totalOtherFee;
        
        [printer appendCustomData:data];
        [printer appendSeperatorLine];
    }
}

// 所有商品的信息
- (void)addDetailProductList:(NSArray *)productList printer:(HLPrinter *)printer
{
    [printer appendText:self.productTitle alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleSmalle];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSMutableData *detailData = [NSMutableData data];
    CGFloat totalAmount = 0;
    
    for (ManifestTransactionDetail *product in productList) {
        
        NSMutableString *text = [NSMutableString string];
        NSString *productName = nil;
        if (product.skuValueCombine && ![product.skuValueCombine isEqualToString:@""]) {
            productName = [NSString stringWithFormat:@"%@ %@",product.productName, product.skuValueCombine];
        } else {
            productName = product.productName;
        }
        
        
        CGFloat productPriceFloat = [product.productPrice doubleValue] * [product.productDiscount doubleValue];
        NSString *productPrice = [NSString stringWithFormat:@"%.1f", productPriceFloat];
        NSString *productCount = nil;
        CGFloat productCountFloat = [product.productCount doubleValue];
        if (product.productUnit_digits == 0) {
            productCount = [NSString stringWithFormat:@"%.0f", productCountFloat];
        } else {
            productCount = [NSString stringWithFormat:@"%.1f", productCountFloat];
        }
        
        CGFloat amount = productPriceFloat * productCountFloat;
        totalAmount += amount;
        NSString *productAmount = [NSString stringWithFormat:@"%.1f", amount];
        
        
        
        
        NSString *productInfo = [self getProductString:productName
                                          productCount:productCount
                                          productPrice:productPrice
                                         productAmount:productAmount];

        [text appendString:productInfo];
        [text appendString:@"\n"];
        [detailData appendData:[text dataUsingEncoding:enc]];
    }
    self.totalAmount = totalAmount;
    
    [printer appendCustomData:detailData];
    [printer appendSeperatorLine];
}

// 一个商品的信息拼成字符串
- (NSString *)getProductString:(NSString *)productName
                  productCount:(NSString *)productCount
                  productPrice:(NSString *)productPrice
                 productAmount:(NSString *)productAmount
{
    NSMutableString *productInfo = [NSMutableString stringWithString:productName];
    
    if (([productInfo charNumber] + [productCount charNumber]) >= kCountOverCharNumber) {
        [productInfo appendString:@"\n"];
    }
    
    //数量
    NSMutableString *productCountMutableString = nil;
    
    if ([productInfo containsString:[NSString stringWithFormat:@"%@\n", productName]]) {
        productCountMutableString = [NSMutableString string];
    } else {
        productCountMutableString = [NSMutableString stringWithString:productName];
    }
    
    while (1) {
        
        if ([productCountMutableString charNumber] + [productCount charNumber] < kCountOverCharNumber) {
            
            [productInfo appendString:@" "];
            [productCountMutableString appendString:@" "];
            
        } else {
            
            [productInfo appendString:productCount];
            [productCountMutableString appendString:productCount];
            break;
        }
    }
    
    if (([productCountMutableString charNumber] + [productPrice charNumber]) >= kPriceOverCharNumber) {
        [productInfo appendString:@"\n"];
        [productCountMutableString appendString:@"\n"];
    }
    
    //价格
    NSMutableString *productPriceMutableString = nil;
    
    if ([productInfo containsString:[NSString stringWithFormat:@"%@\n", productCount]]) {
        productPriceMutableString  = [NSMutableString string];
    } else {
        productPriceMutableString = [NSMutableString stringWithString:productCountMutableString];
    }
    while (1) {
        
        
        if ([productPriceMutableString charNumber] + [productPrice charNumber] < kPriceOverCharNumber) {
            
            [productInfo appendString:@" "];
            [productPriceMutableString appendString:@" "];
            
        } else {
            
            [productInfo appendString:productPrice];
            [productPriceMutableString appendString:productPrice];
            break;
        }
    }
    
    if (([productPriceMutableString charNumber] + [productAmount charNumber]) >= kMaxCharNumberOnALine) {
        [productInfo appendString:@"\n"];
        [productPriceMutableString appendString:@"\n"];
    }
    
    
    
    //金额
    NSMutableString *productAmountMutableString = nil;
    
    if ([productInfo containsString:[NSString stringWithFormat:@"%@\n", productPrice]]) {
        productAmountMutableString = [NSMutableString string];
    } else {
        productAmountMutableString = [NSMutableString stringWithString:productPriceMutableString];
    }
    while (1) {
        
        if ([productAmountMutableString charNumber] + [productAmount charNumber] < kMaxCharNumberOnALine) {
            
            [productInfo appendString:@" "];
            [productAmountMutableString appendString:@" "];
            
        } else {
            
            [productInfo appendString:productAmount];
            [productAmountMutableString appendString:productAmount];
            break;
        }
    }
    
    return productInfo;
}

- (void)addTotalInfo:(JCHPrintInfoModel *)printInfo printer:(HLPrinter *)printer
{
    [printer setAlignment:HLTextAlignmentLeft];
    NSMutableData *data = [NSMutableData data];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSString *totalAmount = [self addTitle:@"总计:"
                                     value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, self.totalAmount]];
    [data appendData:[totalAmount dataUsingEncoding:enc]];
    
    NSString *discount = [self addTitle:@"折扣:"
                                  value:[JCHTransactionUtility getOrderDiscountFromFloat:printInfo.manifestDiscount]];
    [data appendData:[discount dataUsingEncoding:enc]];
    
    if (printInfo.eraseAmount != 0) {
        NSString *eraseAmount = [self addTitle:@"抹零:"
                                         value:[NSString stringWithFormat:@"-%.2f", printInfo.eraseAmount]];
        [data appendData:[eraseAmount dataUsingEncoding:enc]];
    }
    
    NSString *realPayAmount = [self addTitle:@"实付:"
                                       value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, self.totalAmount * printInfo.manifestDiscount * printInfo.hasPayed - printInfo.eraseAmount]];
    [data appendData:[realPayAmount dataUsingEncoding:enc]];
    
    if (printInfo.manifestRemark && ![printInfo.manifestRemark isEmptyString]) {
        NSMutableString *remarkInfo = [NSMutableString stringWithFormat:@"备注:%@\n", printInfo.manifestRemark];
        [data appendData:[remarkInfo dataUsingEncoding:enc]];
    }
    
    [printer appendCustomData:data];
    [printer appendSeperatorLine];
}

- (NSString *)addTitle:(NSString *)title value:(NSString *)value
{
    NSMutableString *info = [NSMutableString stringWithString:title];
    
    while (1) {
        
        if ([info charNumber] + [value charNumber] < kMaxCharNumberOnALine) {
            
            [info appendString:@" "];
        } else {
            
            [info appendString:value];
            [info appendString:@"\n"];
            break;
        }
    }
    
    return info;
}

- (void)addFooter:(HLPrinter *)printer
{
    [printer appendText:@"谢谢惠顾,欢迎下次光临!" alignment:HLTextAlignmentCenter];
    [printer appendText:@"买卖人科技提供技术支持" alignment:HLTextAlignmentCenter];
    [printer appendText:@"www.maimairen.com" alignment:HLTextAlignmentCenter];
    [printer appendNewLine];
    [printer appendNewLine];
    [printer appendNewLine];
    [printer appendNewLine];
}

#pragma mark - 外卖打印模板
- (void)printTakeoutProductList:(NSArray *)productList showHud:(BOOL)hud
{
    self.printMode = kJCHPrinterModeTakeout;
    
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    NSArray *connectedPerpherals = printerManager.connectedPerpherals;
    if (connectedPerpherals.count == 0) {
        if (hud) {
            [MBProgressHUD showHUDWithTitle:@"未连接设备"
                                     detail:nil
                                   duration:1.5
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
        return;
    }
    
    for (CBPeripheral *peripheral in connectedPerpherals) {
        
        [self setGlobalVariabl:peripheral];
        
        NSInteger printCount = self.printRepeatCount + 1;
        
        for (NSInteger i = 0; i < printCount; i++) {
            
            HLPrinter *printer = [[[HLPrinter alloc] init] autorelease];
            
            // Header
            {
                NSArray *printNumberList = @[@" 一联", @" 二联", @" 三联", @" 四联", @" 五联"];
                NSArray *takeoutResourceList = @[@"美团外卖", @"饿了么", @"百度外卖"];
                NSString *printNumber = @"";
                if (printCount > 1) {
                    printNumber = printNumberList[i];
                }
                NSString *title = [NSString stringWithFormat:@"%@%@", takeoutResourceList[self.takeoutPrintInfo.takeoutResource - 1], printNumber];
                [printer appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleMiddle];
                [printer appendSeperatorLine];
                NSString *orderId = [NSString stringWithFormat:@"单号: %@", self.takeoutPrintInfo.orderIdView];
                [printer appendText:orderId alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
                NSString *orderDateInfo = [NSString stringWithFormat:@"时间: %@", self.takeoutPrintInfo.orderDate];
                [printer appendText:orderDateInfo alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
                [printer appendSeperatorLine];
            }
            
            // Detail
            {
                [printer appendText:self.productTitle alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleSmalle];
                [printer setAlignment:HLTextAlignmentLeft];
                CGFloat totalAmount = 0;
                
                NSMutableData *detailData = [NSMutableData data];
                for (ManifestTransactionDetail *product in productList) {
                    
                    NSMutableString *text = [NSMutableString string];
                    NSString *productName = nil;
                    if (product.skuValueCombine && ![product.skuValueCombine isEqualToString:@""]) {
                        productName = [NSString stringWithFormat:@"%@ %@",product.productName, product.skuValueCombine];
                    } else {
                        productName = product.productName;
                    }
                    
                    
                    CGFloat productPriceFloat = [product.productPrice doubleValue] * [product.productDiscount doubleValue];
                    NSString *productPrice = [NSString stringWithFormat:@"%.1f", productPriceFloat];
                    NSString *productCount = nil;
                    CGFloat productCountFloat = [product.productCount doubleValue];
                    if (product.productUnit_digits == 0) {
                        productCount = [NSString stringWithFormat:@"%.0f", productCountFloat];
                    } else {
                        productCount = [NSString stringWithFormat:@"%.1f", productCountFloat];
                    }
                    
                    CGFloat amount = productPriceFloat * productCountFloat;
                    totalAmount += amount;
                    NSString *productAmount = [NSString stringWithFormat:@"%.1f", amount];
                    
                    
                    
                    
                    NSString *productInfo = [self getProductString:productName
                                                      productCount:productCount
                                                      productPrice:productPrice
                                                     productAmount:productAmount];
                    
                    [text appendString:productInfo];
                    [text appendString:@"\n"];
                    [detailData appendData:[text dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
                }
                self.totalAmount = totalAmount;
                [printer appendCustomData:detailData];
            }
            
            // Footer
            {
                [printer appendSeperatorLine];
                
                if (self.takeoutPrintInfo.deliveryAmount > 0) {
                    NSString *distributionAmount = [self addTitle:@"配餐费:"
                                                            value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, self.takeoutPrintInfo.deliveryAmount]];
                    [printer appendCustomData:[distributionAmount dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
                }
                
                if (self.takeoutPrintInfo.boxAmount > 0) {
                    NSString *mealBoxAmount = [self addTitle:@"餐盒费:"
                                                       value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, self.takeoutPrintInfo.boxAmount]];
                    [printer appendCustomData:[mealBoxAmount dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
                }
                
                if (self.takeoutPrintInfo.deliveryAmount > 0 || self.takeoutPrintInfo.boxAmount > 0) {
                    [printer appendSeperatorLine];
                }
                
                NSString *totalAmount = [self addTitle:@"合计:"
                                                 value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, self.takeoutPrintInfo.totalAmount]];
                [printer appendCustomData:[totalAmount dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
                [printer appendSeperatorLine];
                
                [printer setFontBoldMode:YES];
                NSString *customInfo = [self addTitle:[NSString stringWithFormat:@"手机:%@", self.takeoutPrintInfo.customerPhone] value:self.takeoutPrintInfo.customerName];
                [printer appendCustomData:[customInfo dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
                
                [printer appendText:self.takeoutPrintInfo.customerAddress alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
                [printer setFontBoldMode:NO];
                [printer appendNewLine];
                [printer appendNewLine];
                [printer appendNewLine];
                [printer appendNewLine];
            }
            
            NSData *printerData = [printer getFinalData];
            
            [printerManager sendPrintData:printerData peripheral:peripheral completion:nil];
        }
    }
}

#pragma mark - 外卖版根据服务器返回的订单信息打印订单
- (void)printTakeoutOrderInfo:(NSDictionary *)orderInfo
{
    JCHTakeoutPrintInfoModel *printInfo = [[[JCHTakeoutPrintInfoModel alloc] init] autorelease];
    printInfo.takeoutResource = [orderInfo[@"resource"] integerValue];
    NSTimeInterval orderTimeInterval = [orderInfo[@"ctime"] integerValue];
    
    printInfo.orderIdView = orderInfo[@"orderIdView"];
    printInfo.orderDate = [NSString stringFromSeconds:orderTimeInterval dateStringType:kJCHDateStringType8];
    
    printInfo.customerName = orderInfo[@"recipientName"];
    printInfo.customerAddress = orderInfo[@"recipientAddress"];
    printInfo.customerPhone = orderInfo[@"recipientPhone"];
    
    printInfo.totalAmount = [orderInfo[@"originalPrice"] doubleValue];
    
    NSArray *detailInfoList = orderInfo[@"detail"];
    
    NSMutableArray *dishList = [NSMutableArray array];
    
    CGFloat boxTotalPrice = 0;
    CGFloat dishTotalAmount = 0;
    for (NSInteger j = 0; j < detailInfoList.count; j++) {
        NSDictionary *detailInfo = detailInfoList[j];
        ManifestTransactionDetail *detail = [[[ManifestTransactionDetail alloc] init] autorelease];
        detail.productName = detailInfo[@"foodName"];
        detail.productCountFloat = [detailInfo[@"quantity"] integerValue];
        detail.productPrice = [NSString stringWithFormat:@"%.2f", [detailInfo[@"price"] doubleValue]];
        
        NSString *skuName = detailInfo[@"skuName"];
        NSString *foodProperty = detailInfo[@"foodProperty"];
        NSString *skuValueCombine = nil;
        
        if ([detail.productName isEqualToString:skuName]) {
            skuName = @"";
        }
        
        if ([skuName isEmptyString] && [foodProperty isEmptyString]) {
            skuValueCombine = @"";
        } else if ([skuName isEmptyString] && ![foodProperty isEmptyString]) {
            skuValueCombine = [NSString stringWithFormat:@"(%@)", foodProperty];
        } else if (![skuName isEmptyString] && [foodProperty isEmptyString]) {
            skuValueCombine = [NSString stringWithFormat:@"(%@)", skuName];
        } else {
            skuValueCombine = [NSString stringWithFormat:@"(%@,%@)", skuName, foodProperty];
        }
        detail.skuValueCombine = skuValueCombine;
        
        [dishList addObject:detail];
        
        CGFloat boxPrice = [detailInfo[@"boxNum"] integerValue] * [detailInfo[@"boxPrice"] doubleValue];
        boxTotalPrice += boxPrice;
        CGFloat dishAmount = detail.productCountFloat * detail.productPrice.doubleValue;
        dishTotalAmount += dishAmount;
    }
    dishTotalAmount += boxTotalPrice;
    
    
    printInfo.deliveryAmount = [orderInfo[@"shippingFee"] doubleValue];
    printInfo.boxAmount = boxTotalPrice;
    printInfo.remark = orderInfo[@"caution"];
    self.takeoutPrintInfo = printInfo;
    [self printTakeoutProductList:dishList showHud:NO];
}

#pragma mark - 餐厅版打印
- (void)printRestaurantProductList:(NSArray *)productList showHud:(BOOL)hud
{
    self.printMode = kJCHPrinterModeRestaurant;
    
    SEPrinterManager *printerManager = [SEPrinterManager sharedInstance];
    NSArray *connectedPerpherals = printerManager.connectedPerpherals;
    if (connectedPerpherals.count == 0) {
        if (hud) {
            [MBProgressHUD showHUDWithTitle:@"未连接设备"
                                     detail:nil
                                   duration:1.5
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
        return;
    }
    
    for (CBPeripheral *peripheral in connectedPerpherals) {
        [self setGlobalVariabl:peripheral];
        
        HLPrinter *printer = [[[HLPrinter alloc] init] autorelease];
        
        // Header
        {
            [printer appendText:@"B18" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleMiddle];
            [printer appendText:@"千味涮深圳欢乐颂店" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
            [printer appendText:@"时间: 2016-12-28 12:01:59" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
            [printer appendText:@"单号: 1233453465-123123" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
            [printer appendText:@"开单人: 大麦子" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
            [printer appendSeperatorLine];
        }
        
        // Detail
        {
            [printer appendText:self.productTitle alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleSmalle];
            
            CGFloat totalAmount = 0;
            
            NSMutableData *detailData = [NSMutableData data];
            for (ManifestTransactionDetail *product in productList) {
                
                NSMutableString *text = [NSMutableString string];
                NSString *productName = nil;
                if (product.skuValueCombine && ![product.skuValueCombine isEqualToString:@""]) {
                    productName = [NSString stringWithFormat:@"%@ %@",product.productName, product.skuValueCombine];
                } else {
                    productName = product.productName;
                }
                
                CGFloat productPriceFloat = [product.productPrice doubleValue] * [product.productDiscount doubleValue];
                NSString *productPrice = [NSString stringWithFormat:@"%.1f", productPriceFloat];
                NSString *productCount = nil;
                CGFloat productCountFloat = [product.productCount doubleValue];
                if (product.productUnit_digits == 0) {
                    productCount = [NSString stringWithFormat:@"%.0f", productCountFloat];
                } else {
                    productCount = [NSString stringWithFormat:@"%.1f", productCountFloat];
                }
                
                CGFloat amount = productPriceFloat * productCountFloat;
                totalAmount += amount;
                NSString *productAmount = [NSString stringWithFormat:@"%.1f", amount];
                
                
                
                
                NSString *productInfo = [self getProductString:productName
                                                  productCount:productCount
                                                  productPrice:productPrice
                                                 productAmount:productAmount];
                
                [text appendString:productInfo];
                [text appendString:@"\n"];
                [detailData appendData:[text dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
            }
            self.totalAmount = totalAmount;
            [printer appendCustomData:detailData];
        }
        
        // Footer
        {
            [printer appendSeperatorLine];
            NSString *distributionAmount = [self addTitle:@"菜品小计:"
                                                    value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, 139.00]];
            [printer appendCustomData:[distributionAmount dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
            [printer appendSeperatorLine];
            
            
            [printer setFontBoldMode:YES];
            NSString *shouldPayAmount = [self addTitle:@"应付:"
                                                    value:[NSString stringWithFormat:@"%@%.2f", RMBSymbol, 139.00]];
            [printer appendCustomData:[shouldPayAmount dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
            [printer setFontBoldMode:NO];
            [printer appendNewLine];
            
            [printer appendText:@"地址: 南山区南新路欢乐颂购物中心四层" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
            [printer appendText:@"电话: 0755-86646771" alignment:HLTextAlignmentLeft fontSize:HLFontSizeTitleSmalle];
            [printer appendNewLine];
        }
        NSData *printerData = [printer getFinalData];
        
        [printerManager sendPrintData:printerData peripheral:peripheral completion:nil];
        
        {
            
            printer = [[[HLPrinter alloc] init] autorelease];
            // 二维码
            if ([peripheral.name containsString:@"Gprinter"]) {
                // 佳博
                [printer appendQRCodeWithInfo:@"c123456789-123456789"
                                         size:8
                                    alignment:HLTextAlignmentCenter
                            qrCodeCommandType:HLQRCodeCommandTypeOne];
            } else if ([peripheral.name containsString:@"SGT"]) {
                // SGT-B58V size 越小二维码越大
                [printer appendQRCodeWithInfo:@"c123456789-123456789"
                                         size:2
                                    alignment:HLTextAlignmentCenter
                            qrCodeCommandType:HLQRCodeCommandTypeTwo];
            } else if ([peripheral.name isEqualToString:@"BlueTooth Printer"]) {
                // 迅雷 size 越大二维码越大
                [printer appendQRCodeWithInfo:@"c123456789-123456789"
                                         size:4
                                    alignment:HLTextAlignmentCenter
                            qrCodeCommandType:HLQRCodeCommandTypeTwo];
            } else {
                // 其它
                [printer appendQRCodeWithInfo:@"c123456789-123456789"
                                         size:7
                                    alignment:HLTextAlignmentCenter
                            qrCodeCommandType:HLQRCodeCommandTypeOne];
            }
            
            
            [printer appendNewLine];
            [printer appendNewLine];
            [printer appendNewLine];
        }
        
        printerData = [printer getFinalData];
        [printerManager sendPrintData:printerData peripheral:peripheral completion:nil];
        sleep(0.3);
    }
}


#pragma mark - setter && getter

- (void)setCanPrintInPurchase:(BOOL)canPrintInPurchase
{
    [JCHUserDefaults setObject:@(canPrintInPurchase) forKey:kCanPrintInPurchaseKey];
    [JCHUserDefaults synchronize];
}

- (BOOL)canPrintInPurchase
{
    return [[JCHUserDefaults objectForKey:kCanPrintInPurchaseKey] boolValue];
}

- (void)setCanPrintInShipment:(BOOL)canPrintInShipment
{
    [JCHUserDefaults setObject:@(canPrintInShipment) forKey:kCanPrintInShipmentKey];
    [JCHUserDefaults synchronize];
}

- (BOOL)canPrintInShipment
{
    return [[JCHUserDefaults objectForKey:kCanPrintInShipmentKey] boolValue];
}

- (void)setCanPrintInManifestDetail:(BOOL)canPrintInManifestDetail
{
    [JCHUserDefaults setObject:@(canPrintInManifestDetail) forKey:kCanPrintInManifestDetailKey];
    [JCHUserDefaults synchronize];
}

- (BOOL)canPrintInManifestDetail
{
    return [[JCHUserDefaults objectForKey:kCanPrintInManifestDetailKey] boolValue];
}

- (void)setPrintRepeatCount:(JCHPrintRepeatCount)printRepeatCount
{
    [JCHUserDefaults setObject:@(printRepeatCount) forKey:kPrintRepeatCountKey];
    [JCHUserDefaults synchronize];
}

- (JCHPrintRepeatCount)printRepeatCount
{
    return (JCHPrintRepeatCount)[[JCHUserDefaults objectForKey:kPrintRepeatCountKey] integerValue];
}

- (void)setPrintMeanwhileItem:(JCHPrintMeanwhileItem)printMeanwhileItem
{
    [JCHUserDefaults setObject:@(printMeanwhileItem) forKey:kPrintMeanwhileItemKey];
    [JCHUserDefaults synchronize];
}

- (JCHPrintMeanwhileItem)printMeanwhileItem
{
    return (JCHPrintMeanwhileItem)[[JCHUserDefaults objectForKey:kPrintMeanwhileItemKey] integerValue];
}

- (void)setDefaultPrintType:(JCHDefaultPrintType)defaultPrintType
{
    [JCHUserDefaults setObject:@(defaultPrintType) forKey:kDefaultPrintTypeKey];
    [JCHUserDefaults synchronize];
}

- (JCHDefaultPrintType)defaultPrintType
{
    return (JCHDefaultPrintType)[[JCHUserDefaults objectForKey:kDefaultPrintTypeKey] integerValue];
}

@end


