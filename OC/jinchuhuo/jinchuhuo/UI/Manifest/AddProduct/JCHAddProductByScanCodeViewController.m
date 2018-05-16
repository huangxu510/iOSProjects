//
//  JCHAddProductByScanCodeViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddProductByScanCodeViewController.h"
#import "JCHCreateManifestViewController.h"
#import "JCHAddProductSKUListView.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHCreateManifestViewController.h"
#import "JCHCreateManifestTableSectionView.h"
#import "JCHCreateManifestTableViewCell.h"
#import "JCHAddProductFooterView.h"
#import "JCHInputView.h"
#import "CommonHeader.h"
#import <AVFoundation/AVFoundation.h>

@interface JCHAddProductByScanCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    UIView *_previewView;
    UIView *_scanRectView;
    UIImageView *_scanLine;
    
    JCHCreateManifestViewController *_createManifestVC;
}
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureMetadataOutput *captureOutput;
@property (nonatomic, retain) NSTimer *scanLineTimer;
@property (nonatomic, retain) NSArray *allProducts;
@property (nonatomic, retain) id observer;

@property (nonatomic, retain) NSMutableDictionary *productItemRecordForUnitCache;
@property (nonatomic, retain) NSMutableDictionary *productItemRecordForSKUCache;

@end

@implementation JCHAddProductByScanCodeViewController

- (instancetype)initWithAllProducts:(NSArray *)allProducts
{
    self = [super init];
    if (self) {
        self.allProducts = allProducts;
        self.productItemRecordForSKUCache = [NSMutableDictionary dictionary];
        self.productItemRecordForUnitCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [JCHNotificationCenter removeObserver:self.observer];
    [JCHNotificationCenter removeObserver:self];
    
    self.callBackBlock = nil;
    self.session = nil;
    self.scanLineTimer = nil;
    self.observer = nil;
    self.captureOutput = nil;
    self.productItemRecordForUnitCache = nil;
    self.productItemRecordForSKUCache = nil;
    self.inventoryMap = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self setUpAVCapture];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.session startRunning];
    
    [_createManifestVC changeUIForScanCodeViewController];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(applicationWillEnterForeground:)
                                  name:UIApplicationWillEnterForegroundNotification
                                object:nil];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(applicationDidEnterBackground:)
                                  name:UIApplicationDidEnterBackgroundNotification
                                object:nil];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(keyboardShow:)
                                  name:UIKeyboardWillShowNotification object:nil];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(keyboardHide:)
                                  name:UIKeyboardWillHideNotification object:nil];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(keyboardShow:)
                                  name:kJCHSettleAccountsKeyboardWillShowNotification
                                object:nil];
    
    [JCHNotificationCenter addObserver:self
                              selector:@selector(keyboardHide:)
                                  name:kJCHSettleAccountsKeyboardDidHideNotification
                                object:nil];
}

- (void)popToSwitchTargetController
{
    [self.scanLineTimer invalidate];
    self.scanLineTimer = nil;
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scanLineTimer = [NSTimer scheduledTimerWithTimeInterval:2.5
                                                          target:self
                                                        selector:@selector(moveScanLine)
                                                        userInfo:nil
                                                         repeats:YES];
    [self.scanLineTimer fire];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.session stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [JCHNotificationCenter removeObserver:self];
}

- (void)createUI
{
    CGFloat previewViewHeight = 186.0f;
    CGFloat scanRectViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:261.0f];
    CGFloat scanRectViewHeight = 104;
    
    _previewView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, previewViewHeight)] autorelease];
    _previewView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_previewView];
    
    _scanRectView =  [[[UIView alloc] init] autorelease];
    _scanRectView.backgroundColor = [UIColor clearColor];
    _scanRectView.frame = CGRectMake((kScreenWidth - scanRectViewWidth) / 2, 44 + 19, scanRectViewWidth, scanRectViewHeight);
    _scanRectView.clipsToBounds = YES;
    [self.view addSubview:_scanRectView];
    
    //四个角
    {
        UIImageView *leftTopCorner = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_scan_01"]] autorelease];
        [_scanRectView addSubview:leftTopCorner];
        [leftTopCorner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(_scanRectView);
            make.width.height.mas_equalTo(10);
        }];
        
        UIImageView *rightTopCorner = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_scan_02"]] autorelease];
        [_scanRectView addSubview:rightTopCorner];
        [rightTopCorner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(_scanRectView);
            make.width.height.mas_equalTo(10);
        }];
        
        UIImageView *leftBottomCorner = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_scan_03"]] autorelease];
        [_scanRectView addSubview:leftBottomCorner];
        [leftBottomCorner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(_scanRectView);
            make.width.height.mas_equalTo(10);
        }];
        
        UIImageView *rightBottomCorner = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_scan_04"]] autorelease];
        [_scanRectView addSubview:rightBottomCorner];
        [rightBottomCorner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(_scanRectView);
            make.width.height.mas_equalTo(10);
        }];
    }
    
    _scanLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_scanLine"]] autorelease];
    _scanLine.frame = CGRectMake(0, -scanRectViewHeight, scanRectViewWidth, scanRectViewHeight);
    [_scanRectView addSubview:_scanLine];
    
    {
        UIView *topMaskView = [[[UIView alloc] init] autorelease];
        topMaskView.backgroundColor = [UIColor blackColor];
        topMaskView.alpha = 0.7;
        [self.view addSubview:topMaskView];
        
        [topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.bottom.equalTo(_scanRectView.mas_top);
        }];
        
        UIView *leftMaskView = [[[UIView alloc] init] autorelease];
        leftMaskView.backgroundColor = [UIColor blackColor];
        leftMaskView.alpha = 0.7;
        [self.view addSubview:leftMaskView];
        
        [leftMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(_scanRectView.mas_left);
            make.top.equalTo(topMaskView.mas_bottom);
            make.bottom.equalTo(_scanRectView);
        }];
        
        UIView *rightMaskView = [[[UIView alloc] init] autorelease];
        rightMaskView.backgroundColor = [UIColor blackColor];
        rightMaskView.alpha = 0.7;
        [self.view addSubview:rightMaskView];
        
        [rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_scanRectView.mas_right);
            make.right.equalTo(self.view);
            make.top.equalTo(leftMaskView);
            make.bottom.equalTo(_scanRectView);
        }];
        
        UIView *bottomMaskView = [[[UIView alloc] init] autorelease];
        bottomMaskView.backgroundColor = [UIColor blackColor];
        bottomMaskView.alpha = 0.7;
        [self.view addSubview:bottomMaskView];
        
        [bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(_scanRectView.mas_bottom);
            make.bottom.equalTo(self.view);
        }];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton setImage:[UIImage imageNamed:@"bt_back"] forState:UIControlStateNormal];
        dismissButton.frame = CGRectMake(10, 20, 44, 44);
        [dismissButton addTarget:self action:@selector(handlePop) forControlEvents:UIControlEventTouchUpInside];
        [topMaskView addSubview:dismissButton];
        
        UILabel *titleLabel = [JCHUIFactory createJCHLabel:CGRectMake(kScreenWidth / 2 - 75, 20, 150, 44)
                                                     title:@"扫码"
                                                      font:[UIFont boldSystemFontOfSize:18]
                                                 textColor:[UIColor whiteColor]
                                                    aligin:NSTextAlignmentCenter];
        [topMaskView addSubview:titleLabel];
        
        UILabel *detailInfoLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                          title:@""
                                                           font:[UIFont systemFontOfSize:16]
                                                      textColor:[UIColor whiteColor]
                                                         aligin:NSTextAlignmentCenter];
        [topMaskView addSubview:detailInfoLabel];
    }
    
    _createManifestVC = [[[JCHCreateManifestViewController alloc] init] autorelease];
    _createManifestVC.inventoryMap = self.inventoryMap;
    [self addChildViewController:_createManifestVC];
    
    [self.view addSubview:_createManifestVC.view];
    
    [_createManifestVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_previewView.mas_bottom);
        make.bottom.equalTo(self.view);//.with.offset(-kTabBarHeight);
    }];
}

- (void)setUpAVCapture
{
    //1.摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"摄像头开启失败:%@", error.localizedDescription);
        return;
    }
    
    //3.设置输出(Metadata元数据)
    AVCaptureMetadataOutput *captureOutput = [[[AVCaptureMetadataOutput alloc] init] autorelease];
    
    // 3.1 设置输出的代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.captureOutput = captureOutput;
    
    //4.拍摄会话
    AVCaptureSession *session = [[[AVCaptureSession alloc] init] autorelease];
    //添加session的输入输出
    [session addInput:input];
    [session addOutput:captureOutput];
    //使用1080p的图像输出
    session.sessionPreset = AVCaptureSessionPreset1920x1080;
    self.session = session;
    //[output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
    
    //4.1 设置输出的格式
    [captureOutput setMetadataObjectTypes:@[AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code]];
    
    
    //5.设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = _previewView.bounds;
    [_previewView.layer insertSublayer:previewLayer atIndex:0];
    
    //调整识别范围
    WeakSelf;
    self.observer = [JCHNotificationCenter addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                       object:nil
                                                        queue:[NSOperationQueue mainQueue]
                                                   usingBlock:^(NSNotification * _Nonnull note) {
                                                       if (weakSelf){
                                                           //调整扫描区域
                                                           AVCaptureMetadataOutput *output = weakSelf.session.outputs.firstObject;
                                                           output.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:weakSelf -> _previewView.bounds];
                                                       }
                                                   }];
    
}

#pragma mark - LoadData
- (void)loadData
{
    [_createManifestVC loadData];
}


- (void)handlePop
{
    [self.scanLineTimer invalidate];
    self.scanLineTimer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moveScanLine
{
    [UIView animateWithDuration:2 animations:^{
        _scanLine.transform = CGAffineTransformMakeTranslation(0, _scanRectView.frame.size.height);
    } completion:^(BOOL finished) {
        _scanLine.transform = CGAffineTransformIdentity;
    }];
}

- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self.session  startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        
        AVCaptureMetadataOutput *output = (AVCaptureMetadataOutput *)captureOutput;
        [output setMetadataObjectsDelegate:nil queue:nil];
        
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *code = [obj stringValue];
        
        //这里有可能不在主线程，大部分情况下在主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addProductByCode:code];
        });
    
        NSLog(@"code = %@", code);
    }
}

- (void)addProductByCode:(NSString *)code
{
    id<ProductService> productService = [[ServiceFactory sharedInstance] productService];
    
    ProductRecord4Cocoa *currentProductRecord = nil;
    ProductItemRecord4Cocoa *currentProductItemRecord = nil;
    
    for (ProductRecord4Cocoa *productRecord in self.allProducts) {
        if (productRecord.is_multi_unit_enable) {   //主辅单位
            
            //主单位(构造一个ProductItemRecord)
            if ([productRecord.goods_bar_code isEqualToString:code]) {
                currentProductRecord = productRecord;
                currentProductItemRecord = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
                currentProductItemRecord.unitName = productRecord.goods_unit;
                currentProductItemRecord.goodsUnitUUID = productRecord.goods_unit_uuid;
                currentProductItemRecord.unitDigits = (int)productRecord.goods_unit_digits;
                currentProductItemRecord.itemPrice = productRecord.goods_sell_price;
                break;
            } else {
                
                //辅单位
                NSArray<ProductItemRecord4Cocoa *> *unitProductItemList = nil;
                
                if ([self.productItemRecordForUnitCache objectForKey:productRecord.goods_uuid]) {
                    unitProductItemList = [self.productItemRecordForUnitCache objectForKey:productRecord.goods_uuid];
                } else {
                    unitProductItemList = [productService queryUnitGoodsItem:productRecord.goods_uuid];
                }
                
                
                
                for (ProductItemRecord4Cocoa *productItemRecord in unitProductItemList) {
                    if ([productItemRecord.itemBarCode isEqualToString:code]) {
                        currentProductRecord = productRecord;
                        currentProductItemRecord = productItemRecord;
                        goto label;
                    }
                }
            }
        } else {
            if (!productRecord.sku_hiden_flag) {    //多规格
                
                //优先查找sku条码
                NSArray<ProductItemRecord4Cocoa *> *skuProductItemList = nil;
                
                if ([self.productItemRecordForSKUCache objectForKey:productRecord.goods_uuid]) {
                    skuProductItemList = [self.productItemRecordForSKUCache objectForKey:productRecord.goods_uuid];
                } else {
                    skuProductItemList = [productService querySkuGoodsItem:productRecord.goods_uuid];
                }
                
                for (ProductItemRecord4Cocoa *productItemRecord in skuProductItemList) {
                    if ([productItemRecord.itemBarCode isEqualToString:code]) {
                        currentProductRecord = productRecord;
                        currentProductItemRecord = productItemRecord;
                        currentProductItemRecord.unitName = productRecord.goods_unit;
                        currentProductItemRecord.goodsUnitUUID = productRecord.goods_unit_uuid;
                        currentProductItemRecord.unitDigits = (int)productRecord.goods_unit_digits;
                        currentProductItemRecord.itemPrice = productRecord.goods_sell_price;
                        goto label;
                    }
                }
                
                //如果在sku条码里面没有找到，则
                if (currentProductItemRecord == nil) {
                    if ([productRecord.goods_bar_code isEqualToString:code]) {
                        currentProductRecord = productRecord;
                        break;
                    }
                }
            } else {                                //无规格
                if ([productRecord.goods_bar_code isEqualToString:code]) {
                    currentProductRecord = productRecord;
                    currentProductItemRecord = [[[ProductItemRecord4Cocoa alloc] init] autorelease];
                    currentProductItemRecord.unitName = productRecord.goods_unit;
                    currentProductItemRecord.goodsUnitUUID = productRecord.goods_unit_uuid;
                    currentProductItemRecord.unitDigits = (int)productRecord.goods_unit_digits;
                    currentProductItemRecord.itemPrice = productRecord.goods_sell_price;
                    break;
                }
            }
        }
    }
    
    label : NSLog(@"goto");
    
    //如果是多规格商品，找到该规格组合
    NSString *skuValueCombine = @"";
    if (currentProductRecord.sku_hiden_flag == NO && currentProductItemRecord) {
        skuValueCombine = [self findSKUValueCombine:currentProductItemRecord];
    }
    
    
    
    //音效
    [JCHAudioUtility playAudio:@"barCodeAudio.wav" shake:NO];
    
    //1.5秒后继续扫码
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.captureOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    });
    
    
    if (!currentProductItemRecord && !currentProductRecord) {
        [MBProgressHUD showHUDWithTitle:@""
                                 detail:@"未搜到相关商品"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
        return;
    }
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if ( manifestStorage.currentManifestType == kJCHManifestAssembling) {
        // 拼装单如果扫到的是辅单位，提示用户请扫主单位条码
        if (currentProductItemRecord && currentProductRecord && ![currentProductItemRecord.unitName isEqualToString:currentProductRecord.goods_unit]) {
            [MBProgressHUD showHUDWithTitle:@""
                                     detail:@"拼装单请扫描该商品主单位条码"
                                   duration:kJCHDefaultShowHudTime
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            return;
        }
    } else if (manifestStorage.currentManifestType == kJCHManifestDismounting) {
        // 拆装单如果扫到的是主单位，提示用户请扫辅单位条码
        if (currentProductItemRecord && currentProductRecord && [currentProductItemRecord.unitName isEqualToString:currentProductRecord.goods_unit]) {
            [MBProgressHUD showHUDWithTitle:@""
                                     detail:@"拼装单请扫描该商品辅单位条码"
                                   duration:kJCHDefaultShowHudTime
                                       mode:MBProgressHUDModeText
                                 completion:nil];
            return;
        }
    }
    
    NSString *productUnitInfo = @"";
    if (currentProductRecord) {
        if (currentProductRecord.is_multi_unit_enable) {
            productUnitInfo = [NSString stringWithFormat:@"（%@）", currentProductItemRecord.unitName];
        }
    }
    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%@%@", currentProductRecord.goods_name, productUnitInfo]
                             detail:skuValueCombine
                           duration:kJCHDefaultShowHudTime
                               mode:MBProgressHUDModeText
                         completion:nil];
    
    BOOL addRecordFlag = NO;
    
    if (currentProductRecord.is_multi_unit_enable) {    //主辅单位
        if (currentProductItemRecord) {
            addRecordFlag = YES;
        }
    } else {
        if (!currentProductRecord.sku_hiden_flag) {     //多规格
            if (currentProductItemRecord) {
                addRecordFlag = YES;
            }
        } else {                                        //无规格
            if (currentProductRecord) {
                addRecordFlag = YES;
            }
        }
    }
    
    //直接添加一条流水
    if (addRecordFlag) {
        // 拼装单直接弹出键盘
        if (manifestStorage.currentManifestType == kJCHManifestAssembling) {
            if ([currentProductItemRecord.goodsUnitUUID isEqualToString:currentProductRecord.goods_unit_uuid]) {
                [_createManifestVC showAssemblingKeyboard:currentProductRecord];
            }
        } else {
            NSMutableArray *allManifestTransactionDetails = (NSMutableArray *)[manifestStorage getAllManifestRecord];
            BOOL isTransactionInStorage = NO;
            
            ManifestTransactionDetail *detail = nil;
            //先在当前已经添加的商品列表找改商品，如果找到则数量+1，如果没找到则添加该商品
            for (ManifestTransactionDetail *storedTransactionDetail in allManifestTransactionDetails) {
                if ((([storedTransactionDetail.goodsNameUUID isEqualToString: currentProductRecord.goods_uuid] &&
                      [JCHTransactionUtility skuUUIDs:storedTransactionDetail.skuValueUUIDs isEqualToArray:currentProductItemRecord.skuUUIDVector]) &&
                     [storedTransactionDetail.unitUUID isEqualToString:currentProductItemRecord.goodsUnitUUID])) { //有规格 根据名称类型的uuid还有sku判断是否为同一规格
                    
                    //重新取当前时间
                    storedTransactionDetail.productAddedTimestamp = time(NULL);
                    NSString *productCountStr = storedTransactionDetail.productCount;
                    CGFloat count = [productCountStr doubleValue];
                    
                    if (manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHManifestMigrate || manifestStorage.currentManifestType == kJCHManifestDismounting) {
                        count++;
                        storedTransactionDetail.productCount = [NSString stringFromCount:count unitDigital:currentProductRecord.goods_unit_digits];
                    } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                        
                        //弹键盘
                        [_createManifestVC showKeyboard:[allManifestTransactionDetails indexOfObject:storedTransactionDetail]];
                    }
                    
                    
                    detail = storedTransactionDetail;
                    isTransactionInStorage = YES;
                    break;
                }
            }
            
            //找到则将最新扫到的商品移动到第一个
            if (isTransactionInStorage) {
                [manifestStorage removeManifestRecord:detail];
                [manifestStorage insertManifestRecordAtHead:detail];
            } else {
                
                id<FinanceCalculateService> calculateService = [[ServiceFactory sharedInstance] financeCalculateService];
                JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
                InventoryDetailRecord4Cocoa *inventoryDetailRecord = [calculateService calculateInventoryFor:currentProductRecord.goods_uuid
                                                                                                    unitUUID:currentProductItemRecord.goodsUnitUUID
                                                                                               warehouseUUID:manifestStorage.warehouseID];
                
                //没有找到则添加
                ManifestTransactionDetail *detail = [[[ManifestTransactionDetail alloc] init] autorelease];
                
                detail.productCategory = currentProductRecord.goods_type;
                detail.productName = currentProductRecord.goods_name;
                detail.productUnit = currentProductItemRecord.unitName;
                detail.productImageName = currentProductRecord.goods_image_name;
                detail.productUnit_digits = currentProductItemRecord.unitDigits;
                detail.productDiscount = @"1.0";
                detail.productCount = @"1";
                detail.skuValueCombine = skuValueCombine;
                detail.skuHidenFlag = currentProductRecord.sku_hiden_flag;
                detail.warehouseUUID = manifestStorage.warehouseID;
                detail.goodsCategoryUUID = currentProductRecord.goods_category_uuid;
                detail.goodsNameUUID = currentProductRecord.goods_uuid;
                detail.unitUUID = currentProductItemRecord.goodsUnitUUID;
                detail.skuValueUUIDs = currentProductItemRecord.skuUUIDVector;
                detail.productInventoryCount = [NSString stringFromCount:inventoryDetailRecord.currentInventoryCount unitDigital:currentProductRecord.goods_unit_digits];
                detail.ratio = currentProductItemRecord.ratio;
                // 如果是出货单，在初始加载数据时，默认为显示商品的出货价格
                if (manifestStorage.currentManifestType == kJCHOrderShipment) {
                    detail.productPrice = [NSString stringWithFormat:@"%g", currentProductItemRecord.itemPrice];
                } else if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
                    // 如果是进货单，在初始加载数据时，默认为显示0.0
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", currentProductRecord.goods_last_purchase_price];
                } else if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                    // 盘点单，数量为库存，价格为平均价
                    
                    detail.productCount = [NSString stringFromCount:inventoryDetailRecord.currentInventoryCount unitDigital:currentProductRecord.goods_unit_digits];
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryDetailRecord.averageCostPrice];
                    
                    
                    detail.averagePriceBefore = [NSString stringWithFormat:@"%.2f", inventoryDetailRecord.averageCostPrice];
                } else if (manifestStorage.currentManifestType == kJCHManifestMigrate) {
                    
                } else if (manifestStorage.currentManifestType == kJCHManifestAssembling || manifestStorage.currentManifestType == kJCHManifestDismounting) {
                    detail.productPrice = [NSString stringWithFormat:@"%.2f", inventoryDetailRecord.averageCostPrice];
                } else {
                    // 其它未知情况
                    detail.productPrice = @"9999.99";
                }
                
                [manifestStorage insertManifestRecordAtHead:detail];
                
                if (manifestStorage.currentManifestType == kJCHManifestInventory) {
                    
                    [_createManifestVC loadData];
                    //弹键盘
                    [_createManifestVC showKeyboard:[allManifestTransactionDetails indexOfObject:detail]];
                }
            }
            
            _createManifestVC.lastEditedProductUUID = currentProductRecord.goods_uuid;
            
            [self loadData];
        }
    } else {
        //返回添加商品界面， 并且展开该对规格商品
        [self handlePop];
        if (self.callBackBlock) {
            self.callBackBlock(currentProductRecord);
        }
    }
}

//! @brief 根据skuUUIDVector 找到该skuValueCombine
- (NSString *)findSKUValueCombine:(ProductItemRecord4Cocoa *)currentProductItemRecord
{
    //如果是多规格商品，找到该规格组合
    NSString *skuValueCombine = @"";
    if (currentProductItemRecord.skuUUIDVector.count > 0) {
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        GoodsSKURecord4Cocoa *goodsSKURecord = nil;
        [skuService queryGoodsSKU:currentProductItemRecord.goodsSkuUUID skuArray:&goodsSKURecord];
        
        NSMutableArray *skuValueRecords = [NSMutableArray array];
        for (NSDictionary *dict in goodsSKURecord.skuArray) {
            [skuValueRecords addObject:[dict allValues][0]];
        }
        
        NSDictionary *dict = [JCHTransactionUtility getTransactionsWithData:skuValueRecords];
        NSArray *skuValueCombineArray = [[dict allValues] firstObject];
        NSArray *skuValueUUIDsArray = [[dict allKeys] firstObject];
        
        for (NSInteger i = 0; i < skuValueUUIDsArray.count; i++) {
            NSArray *skuUUIDs = skuValueUUIDsArray[i];
            if ([JCHTransactionUtility skuUUIDs:skuUUIDs isEqualToArray:currentProductItemRecord.skuUUIDVector]) {
                skuValueCombine = skuValueCombineArray[i];
            }
        }
    }
    return skuValueCombine;
}


- (void)keyboardShow:(NSNotification *)note
{
    [self.session stopRunning];
}

- (void)keyboardHide:(NSNotification *)note
{
    [self.session startRunning];
}



@end
