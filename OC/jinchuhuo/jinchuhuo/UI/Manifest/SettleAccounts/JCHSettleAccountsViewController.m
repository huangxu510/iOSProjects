//
//  JCHSettleAccountsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettleAccountsViewController.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHBarCodeScannerViewController.h"
#import "JCHGroupContactsViewController.h"
#import "JCHCheckoutOnAccountViewController.h"
#import "JCHCheckoutViewController.h"
#import "JCHCheckoutOrderTableViewCell.h"
#import "JCHCheckoutBottomMenuView.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHCreateManifestTotalDiscountEditingView.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "JCHManifestMemoryStorage.h"
#import "JCHAddProductMainViewController.h"
#import "JCHTransactionUtility.h"
#import "JCHSyncStatusManager.h"
#import "ServiceFactory.h"
#import "JCHBluetoothManager.h"
#import "JCHSettlementManager.h"
#import "JCHEraseAmountTypeSelectView.h"
#import "JCHPayCodeViewController.h"
#import <Masonry.h>
#import <KLCPopup.h>
#import <MSWeakTimer.h>

static NSString *memberTitleName = @"";
static NSString *memberCenterContent = @"";

@interface JCHSettleAccountsViewController () <UITableViewDataSource,
                                                UITableViewDelegate,
                                                JCHCheckoutOrderTableViewCellDelegate,
                                                JCHCheckoutBottomMenuViewDelegate,
                                                JCHSettleAccountsKeyboardViewDelegate,
                                                JCHSettleAccountsKeyboardViewDelegate,
                                                JCHCreateManifestTotalDiscountEditingViewDelegate>
{
    JCHLabel *_receivableAmountLabel;
    UITableView *_contentTableView;
    JCHCheckoutBottomMenuView *_bottomMenuView;
    JCHSettleAccountsKeyboardView *_keyboard;
    JCHCreateManifestTotalDiscountEditingView *_discountEditingView;
    UITextField *_discountTextField;
    CGFloat _currentOrderDiscount;
    CGFloat _currentOrderTotalAmout;
    CGFloat _currentEraseAmount;
    BOOL _showPayWay;
    NSInteger queryPayStatusUsedTime;
}
@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) NSMutableArray *currentProductInManifestList;
@property (nonatomic, retain) KLCPopup *popupView;
@property (nonatomic, retain) NSArray *bottomViewEnabledButtonTags;
@property (nonatomic, retain) MSWeakTimer *payStatusTimer;
@property (nonatomic, retain) NSString *onlinePayAccountUUID;

@end

@implementation JCHSettleAccountsViewController

- (instancetype)initWithPayWayShow:(BOOL)show enabledButtonTags:(NSArray *)ButtonTags
{
    self = [self init];
    _showPayWay = show;
    self.bottomViewEnabledButtonTags = ButtonTags;
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _showPayWay = NO;
        _currentEraseAmount = 0.0f;
        _currentOrderDiscount = 1.0f;
        _currentOrderTotalAmout = 0.0f;
        self.onlinePayAccountUUID = @"";

        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];

        if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
            memberTitleName = @"供应商";
            memberCenterContent = @"默认供应商";
        } else if (manifestStorage.currentManifestType == kJCHOrderShipment ||
                   manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
            memberTitleName = @"会员";
            memberCenterContent = @"默认客户";
        }
        
        self.title = @"收银台";
        self.dataSource = [NSMutableArray array];
        JCHCheckoutOrderTableViewCellData *data = [[[JCHCheckoutOrderTableViewCellData alloc] init] autorelease];
        data.titleName = @"订单";
        data.centerContent = nil;
        data.value = @"¥ 00.00";//@"¥ 488.00";
        [self.dataSource addObject:data];
        
        
        data = [[[JCHCheckoutOrderTableViewCellData alloc] init] autorelease];
        data.titleName = @"打折";
        data.centerContent = @"不打折";
        data.value = @"- ¥ 00.00";
        [self.dataSource addObject:data];
        
        data = [[[JCHCheckoutOrderTableViewCellData alloc] init] autorelease];
        data.titleName = memberTitleName;
        data.centerContent = memberCenterContent;
        data.value = @"- ¥ 0.00";
        [self.dataSource addObject:data];
        
        data = [[[JCHCheckoutOrderTableViewCellData alloc] init] autorelease];
        data.titleName = @"抹零";
        data.centerContent = nil;
        data.value = @"- ¥ 00.00";
        [self.dataSource addObject:data];
        
        
        data = [[[JCHCheckoutOrderTableViewCellData alloc] init] autorelease];
        data.titleName = @"合计";
        data.centerContent = nil;
        data.value = @"= ¥ 00.00";
        [self.dataSource addObject:data];
    }
    return self;
}

- (void)dealloc
{
    [self stopQueryPayStatusTimer];

    self.payStatusTimer = nil;
    self.onlinePayAccountUUID = nil;
    [self.dataSource release];
    [self.currentProductInManifestList release];
    [self.popupView release];
    [self.bottomViewEnabledButtonTags release];
    
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
    self.view.backgroundColor = JCHColorGlobalBackground;
    self.view.clipsToBounds = YES;
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    CGFloat topContainerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:150.0f];
    CGFloat bottomViewHeight = 190;
    CGFloat keyboardViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:256.0f];
    
    UIView *topContainerView = [[[UIView alloc] init] autorelease];
    topContainerView.backgroundColor = JCHColorHeaderBackground;
    [self.view addSubview:topContainerView];
    
    [topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(topContainerViewHeight);
    }];
    
    JCHLabel *amountTitleLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                        title:@"应收金额"
                                                         font:[UIFont jchSystemFontOfSize:15.0f]
                                                    textColor:[UIColor whiteColor]
                                                       aligin:NSTextAlignmentLeft];
    amountTitleLabel.verticalAlignment = kVerticalAlignmentBottom;
    [topContainerView addSubview:amountTitleLabel];
    
    [amountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(topContainerView.mas_centerY).with.offset(-kStandardLeftMargin);
        make.left.equalTo(topContainerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(topContainerView).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(topContainerViewHeight / 3);
    }];
    
    _receivableAmountLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                    title:@"¥ 0.00"
                                                     font:[UIFont jchSystemFontOfSize:42.0f]
                                                textColor:[UIColor whiteColor]
                                                   aligin:NSTextAlignmentLeft];
    _receivableAmountLabel.verticalAlignment = kVerticalAlignmentTop;
    [topContainerView addSubview:_receivableAmountLabel];
    
    
    [_receivableAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topContainerView).with.offset(2 * kStandardLeftMargin);
        make.top.equalTo(topContainerView.mas_centerY).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(topContainerViewHeight / 2);
    }];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContainerView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-bottomViewHeight);
    }];
    
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)] autorelease];
    view.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.tableHeaderView = view;
    [_contentTableView registerClass:[JCHCheckoutOrderTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _bottomMenuView = [[[JCHCheckoutBottomMenuView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - bottomViewHeight, 2 * kScreenWidth, bottomViewHeight)] autorelease];
    _bottomMenuView.delegate = self;
    [self.view addSubview:_bottomMenuView];
    
    if (_showPayWay) {
        [_bottomMenuView setBackButtonHidden:YES];
        [_bottomMenuView showPayWay:NO];
    }
    
    if (self.bottomViewEnabledButtonTags) {
        for (UIButton *button in _bottomMenuView.subviews) {
            if ([self.bottomViewEnabledButtonTags containsObject:@(button.tag)]) {
                button.enabled = YES;
            } else {
                button.enabled = NO;
            }
        }
    }
    
    _discountEditingView = [[[JCHCreateManifestTotalDiscountEditingView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)] autorelease];
    _discountEditingView.delegate = self;
    [_discountEditingView.closeButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    _discountTextField = [JCHUIFactory createTextField:CGRectMake(0, 0, 100, -500)
                                           placeHolder:@""
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
    _discountTextField.inputAccessoryView = _discountEditingView;
    [self.view addSubview:_discountTextField];
    

    
    _keyboard = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, keyboardViewHeight)
                                                 keyboardHeight:keyboardViewHeight
                                                        topView:nil
                                         topContainerViewHeight:0] autorelease];
    _keyboard.delegate = self;
    _discountTextField.inputView = _keyboard;
    
    //_bindResultAlertView = [[[JCHBindResultStatusAlertView alloc] initWithFrame:CGRectMake(0, 0, alertViewWidth, alertViewHeight)] autorelease];
    //_bindResultAlertView.delegate = self;
    KLCPopup *popupView = [KLCPopup popupWithContentView:nil];
    popupView.backgroundColor = [UIColor clearColor];
    popupView.alpha = 0.5;
    popupView.dimmedMaskAlpha = 0.5f;
    popupView.maskType = KLCPopupMaskTypeDimmed;
    popupView.shouldDismissOnBackgroundTouch = NO;
    popupView.showType = KLCPopupShowTypeFadeIn;
    
    self.popupView = popupView;
    
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {
        amountTitleLabel.text = @"应收金额";
    } else if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
        amountTitleLabel.text = @"应付金额";
    } else if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
        amountTitleLabel.text = @"充值金额";
    }
}

- (void)hideKeyboard
{
    [_discountTextField resignFirstResponder];
}

- (void)calculateTotalOrderCost
{
    CGFloat totalCost = 0.0;
    for (ManifestTransactionDetail *product in self.currentProductInManifestList) {
        //double productCount = [product.productCount doubleValue];
        double productPrice = [product.productPrice doubleValue];
        double productDiscount = [product.productDiscount doubleValue];
        
        totalCost += product.productCountFloat * productPrice * productDiscount;
    }
    _currentOrderTotalAmout = totalCost;
    _keyboard.maxAmount = totalCost * 0.9;
}

#pragma mark - LoadData

- (void)loadData
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    _currentOrderDiscount = manifestStorage.currentManifestDiscount;

    _currentEraseAmount = manifestStorage.currentManifestEraseAmount;
    //_discountEditingView.discountLabel.text = [JCHTransactionUtility getOrderDiscountFromFloat:_currentOrderDiscount];
    _discountEditingView.discount = _currentOrderDiscount;

    
    NSArray *allManifestRecord = [manifestStorage getAllManifestRecord];
    self.currentProductInManifestList = [NSMutableArray arrayWithArray:allManifestRecord];
    
    if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
        _currentOrderTotalAmout = manifestStorage.savingCardRechargeAmount;
    } else {
        //其余货单类型计算总金额
        [self calculateTotalOrderCost];
    }
    
    
    [self reloadTableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    JCHCheckoutOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    cell -> _bottomLine.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    JCHCheckoutOrderTableViewCellData *data = self.dataSource[indexPath.row];
    
    if (([data.titleName isEqualToString:@"抹零"] && manifestStorage.isRejected) ||
        ([data.titleName isEqualToString:@"打折"] && (manifestStorage.currentManifestDiscount != 1)) ||
        ([data.titleName isEqualToString:memberTitleName] && manifestStorage.currentContactsRecord.contactUUID)) {
        
        //充值时不能删除会员
        if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
            [cell setDeleteButtonHidden:YES];
        } else {
            [cell setDeleteButtonHidden:NO];
        }
    } else {
        [cell setDeleteButtonHidden:YES];
    }
    
    
    [cell setCellData:data];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

#pragma mark - JCHCheckoutOrderTableViewCellDelegate

- (void)handleDeleteItem:(JCHCheckoutOrderTableViewCell *)cell
{
    [cell setDeleteButtonHidden:YES];
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    NSLog(@"row = %ld", indexPath.row);
    JCHCheckoutOrderTableViewCellData *data = self.dataSource[indexPath.row];
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if ([data.titleName isEqualToString:@"打折"]){
        manifestStorage.currentManifestDiscount = 1;
        _currentOrderDiscount = 1;
        
    } else if ([data.titleName isEqualToString:@"抹零"]){
        data.value = @"- ¥ 0.00";
        manifestStorage.isRejected = NO;
    } else if ([data.titleName isEqualToString:memberTitleName]){
        manifestStorage.currentContactsRecord = nil;
    }
    [self reloadTableView];
}

#pragma mark - JCHCheckoutBottomMenuViewDelegate - 抹零、打折、挂单、会员

-(void)handleBottomMenuViewAction:(UIButton *)button
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    switch (button.tag) {
        case kJCHCheckoutBottomMenuEraseTag:  //抹零
        {
            JCHEraseAmountTypeSelectView *view = [[[JCHEraseAmountTypeSelectView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kJCHEraseAmountTypeSelectViewItemHeight * 4)] autorelease];
            view.dataSource = @[@"抹角", @"抹个位", @"抹十位"];
            view.totalAmount = _currentOrderTotalAmout * _currentOrderDiscount;
            [view showView];
            
            WeakSelf;
            [view setSelectBlock:^(NSInteger index) {
                [weakSelf handleSelectEraseAmountType:index];
            }];
        }
            break;
            
        case kJCHCheckoutBottomMenuDiscountTag: //打折
        {
            _discountEditingView.totalAmount = _currentOrderTotalAmout;
            _discountEditingView.discount = 1.0;
            [_keyboard setEditText:_discountEditingView.discountLabel.text editMode:_discountEditingView.editMode];
            [_discountTextField becomeFirstResponder];
        }
            break;
        case kJCHCheckoutBottomMenuTemporaryManifestTag:   //挂单
        {
            [self insertTemporaryManifest];
        }
            break;
        case kJCHCheckoutBottomMenuMemberTag:   //会员
        {
            kJCHGroupContactsType groupContactsType;
            if (manifestStorage.currentManifestType == kJCHOrderPurchases) {
                groupContactsType = kJCHGroupContactsSupplier;
            } else if (manifestStorage.currentManifestType == kJCHOrderShipment) {
                groupContactsType = kJCHGroupContactsClient;
            }
            
            JCHGroupContactsViewController *contactsVC = [[[JCHGroupContactsViewController alloc] initWithType:groupContactsType selectMember:YES] autorelease];
            [contactsVC setSendValueBlock:^(ContactsRecord4Cocoa *contactRecord) {
                manifestStorage.currentContactsRecord = contactRecord;
            }];
            UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:contactsVC] autorelease];
            //[self.navigationController pushViewController:contactsVC animated:YES];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

// 保存挂单货单信息
- (void)insertTemporaryManifest
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger manifestTimeInterval = [[dateFormater dateFromString:manifestStorage.currentManifestDate] timeIntervalSince1970];
    if (!manifestStorage.currentManifestRemark) {
        manifestStorage.currentManifestRemark = @"";
    }
    if (!manifestStorage.currentContactsRecord) {
        manifestStorage.currentContactsRecord = [[[ContactsRecord4Cocoa alloc] init] autorelease];
    }
    NSArray *allManifestTransactionDetails = [NSArray arrayWithArray:[manifestStorage getAllManifestRecord]];

    NSMutableArray *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in allManifestTransactionDetails) {
        
        NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        ManifestTransactionRecord4Cocoa *record = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        record.productCategory = productDetail.productCategory;
        //record.productCount = [productDetail.productCount doubleValue];
        record.productCount = productDetail.productCountFloat;
        record.productDiscount = [productDetail.productDiscount doubleValue];
        record.productName = productDetail.productName;
        record.productPrice = [productDetail.productPrice doubleValue];
        record.productUnit = productDetail.productUnit;
        
        record.goodsNameUUID = productDetail.goodsNameUUID;
        record.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.warehouseUUID = productDetail.warehouseUUID;
        record.transactionUUID = transactionUUID;
        record.goodsSKUUUIDArray = productDetail.skuValueUUIDs;
        record.dishProperty = productDetail.dishProperty;
        
        [transactionList addObject:record];
    }
    
    
    NSString *counterPartyUUID = @"";
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    //counterPartyUUID 添加了客户或者供应商 则为客户或者供应商的UUID，没添加则为默认客户或者供应商的UUID
    if (kJCHOrderShipment == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultCustomUUID];
    } else if (kJCHOrderPurchases == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultSupplierUUID];
    }
    
    if (manifestStorage.currentContactsRecord.contactUUID) {
        counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
    }
    
    
    [manifestService stashManifest:transactionList
                      manifestType:manifestStorage.currentManifestType
                      manifestTime:manifestTimeInterval
                        manifestID:manifestStorage.currentManifestID
                  manifestDiscount:manifestStorage.currentManifestDiscount
                    manifestRemark:manifestStorage.currentManifestRemark
                       eraseAmount:manifestStorage.currentManifestEraseAmount
                      counterParty:counterPartyUUID];
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

- (void)handleSelectEraseAmountType:(NSInteger)index
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (index == 0) {
        _currentEraseAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:fmod(_currentOrderTotalAmout * _currentOrderDiscount, 1)];
    } else if (index == 1) {
        _currentEraseAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:fmod(_currentOrderTotalAmout * _currentOrderDiscount, 10)];
    } else if (index == 2) {
        _currentEraseAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:fmod(_currentOrderTotalAmout * _currentOrderDiscount, 100)];
    } else {
        //pass
    }
    if (_currentEraseAmount != 0) {
        manifestStorage.isRejected = YES;
    } else {
        manifestStorage.isRejected = NO;
    }
    [self reloadTableView];
}

#pragma mark - 付款方式
- (void)handleSelectPayWay:(UIButton *)button
{
    JCHManifestMemoryStorage *manifestMemoryStorage = [JCHManifestMemoryStorage sharedInstance];
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    switch (button.tag) {
        case kJCHPayWayCachTag:  //现金
        {
            JCHCheckoutViewController *checkoutBuCashVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWayCash] autorelease];
            [self.navigationController pushViewController:checkoutBuCashVC animated:YES];
        }
            break;
            
        case kJCHPayWayWeChatTag:  //微信
        {
            self.onlinePayAccountUUID = [manifestService getWeiXinPayViaCMBCAccountUUID];
            JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
            [settlementManager handleSelectPayWay:button viewController:self];              
        }
            break;
            
        case kJCHPayWayAlipayTag:   //支付宝
        {
            self.onlinePayAccountUUID = [manifestService getAliPayViaCMBCAccountUUID];
            JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
            [settlementManager handleSelectPayWay:button viewController:self];            
        }
            break;
            
        case kJCHPayWayUnionPayTag:  //银联
        {
            JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
            [settlementManager handleSelectPayWay:button viewController:self];
        }
            break;
            
        case kJCHPayWayTickTag:      //赊销赊购
        {
            if (manifestMemoryStorage.currentContactsRecord.contactUUID) {
                JCHCheckoutOnAccountViewController *onAccountVC = [[[JCHCheckoutOnAccountViewController alloc] init] autorelease];
                [self.navigationController pushViewController:onAccountVC animated:YES];
            } else {
                
                kJCHGroupContactsType groupContactsType;
                if (manifestMemoryStorage.currentManifestType == kJCHOrderPurchases) {
                    groupContactsType = kJCHGroupContactsSupplier;
                } else if (manifestMemoryStorage.currentManifestType == kJCHOrderShipment) {
                    groupContactsType = kJCHGroupContactsClient;
                }
                JCHGroupContactsViewController *contactsVC = [[[JCHGroupContactsViewController alloc] initWithType:groupContactsType selectMember:YES] autorelease];
                [contactsVC setSendValueBlock:^(ContactsRecord4Cocoa *contactRecord) {
                    manifestMemoryStorage.currentContactsRecord = contactRecord;
                }];
                UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:contactsVC] autorelease];
                //[self.navigationController pushViewController:contactsVC animated:YES];
                [self presentViewController:nav animated:YES completion:nil];
                
                return;
            }
            
        }
            break;
            
        case kJCHPayWaySavingsCardTag: //储值卡
        {
            JCHCheckoutViewController *checkoutVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWaySavingCard] autorelease];
            [self.navigationController pushViewController:checkoutVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - JCHSettleAccountsKeyboardViewDelegate
- (void)keyboardViewOKButtonClick
{
    if (_discountEditingView.editMode == kJCHSettleAccountsKeyboardViewEditModePrice) {
        
        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        _currentOrderDiscount = _discountEditingView.discount;
        
        //如果打折 和 直接优惠的金钱数不等，则通过抹零来补齐
        
        if ([JCHFinanceCalculateUtility floatValueIsZero:_discountEditingView.totalAmount * (1 - _discountEditingView.discount) - [JCHFinanceCalculateUtility roundDownFloatNumber:_discountEditingView.reduceAmount]])
        {
            //如果打折 和 直接优惠的金钱数相等，打折会将抹零清除
            manifestStorage.isRejected = NO;
        } else {
            _currentEraseAmount = _discountEditingView.reduceAmount - _discountEditingView.totalAmount * (1 - _discountEditingView.discount);
            manifestStorage.isRejected = YES;
        }

    } else if (_discountEditingView.editMode == kJCHSettleAccountsKeyboardViewEditModeDiscount) {
        JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
        //打折会将抹零清除
        manifestStorage.isRejected = NO;
        _currentOrderDiscount = _discountEditingView.discount;;
    }
    
    [_discountTextField resignFirstResponder];
    [self reloadTableView];
}
- (NSString *)keyboardViewEditingChanged:(NSString *)editText
{
    if (_discountEditingView.editMode == kJCHSettleAccountsKeyboardViewEditModePrice) {
        _discountEditingView.reducedAmountString = editText;
    } else if (_discountEditingView.editMode == kJCHSettleAccountsKeyboardViewEditModeDiscount) {
        CGFloat discount = [JCHTransactionUtility getOrderDiscountFromString:editText];
        _discountEditingView.discount = discount;
    }
    return editText;
}

#pragma mark - JCHCreateManifestTotalDiscountEditingViewDelegate
- (void)createManifestTotalDiscountEditingViewTaped:(JCHCreateManifestTotalDiscountEditingView *)discountEditingView
{
    if (_discountEditingView.editMode == kJCHSettleAccountsKeyboardViewEditModePrice) {
        [_keyboard setEditText:discountEditingView.reducedAmountString editMode:kJCHSettleAccountsKeyboardViewEditModePrice];
    } else if (_discountEditingView.editMode == kJCHSettleAccountsKeyboardViewEditModeDiscount) {
         [_keyboard setEditText:discountEditingView.discountLabel.text editMode:kJCHSettleAccountsKeyboardViewEditModeDiscount];
    }
}

- (void)reloadTableView
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    manifestStorage.currentManifestEraseAmount = _currentEraseAmount;
    if (_currentEraseAmount == 0) {
        manifestStorage.isRejected = NO;
    }
    manifestStorage.currentManifestDiscount = _currentOrderDiscount;
    
    for (JCHCheckoutOrderTableViewCellData *data in self.dataSource) {
        if ([data.titleName isEqualToString:@"订单"]) {
            data.value = [NSString stringWithFormat:@"¥ %.2f", _currentOrderTotalAmout];
        } else if ([data.titleName isEqualToString:@"抹零"]) {
            data.value = [NSString stringWithFormat:@"- ¥ %.2f", _currentEraseAmount * manifestStorage.isRejected];
        } else if ([data.titleName isEqualToString:@"打折"]) {
            data.centerContent = [JCHTransactionUtility getOrderDiscountFromFloat:_currentOrderDiscount];
            data.value = [NSString stringWithFormat:@"- ¥ %.2f", _currentOrderTotalAmout * (1 - _currentOrderDiscount)];
        } else if ([data.titleName isEqualToString:memberTitleName]) {
            if (manifestStorage.currentContactsRecord.contactUUID) {
                data.centerContent = manifestStorage.currentContactsRecord.name;
                //如果是开单 && 并且选择了客户 && 储值卡余额 大于0 && 该货单不是储值卡充值，有余额则点亮储值卡按钮
                id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                CGFloat balance = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
                if (balance > 0 && manifestStorage.currentManifestType != kJCHManifestCardRecharge && manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
                    [_bottomMenuView setButton:kJCHPayWaySavingsCardTag Enabled:YES];
                } else {
                    [_bottomMenuView setButton:kJCHPayWaySavingsCardTag Enabled:NO];
                }
            } else {
                data.centerContent = memberCenterContent;
                [_bottomMenuView setButton:kJCHPayWaySavingsCardTag Enabled:NO];
            }
            
        } else if ([data.titleName isEqualToString:@"合计"]) {
            
            CGFloat receivableAmount = _currentOrderTotalAmout * _currentOrderDiscount - _currentEraseAmount * manifestStorage.isRejected;
            
            
            manifestStorage.receivableAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:receivableAmount];
            data.value = [NSString stringWithFormat:@"= ¥ %.2f", manifestStorage.receivableAmount];
        }
    }
    
    _receivableAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.receivableAmount];
    
    [_contentTableView reloadData];
}

- (void)saveOrderList:(NSString *)paymentAccountUUID
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    NSArray *currentProductInManifestList = [manifestStorage getAllManifestRecord];
    NSMutableArray *transactionList = [[[NSMutableArray alloc] init] autorelease];
    
    for (ManifestTransactionDetail *productDetail in currentProductInManifestList) {
        
        NSString *transactionUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
        ManifestTransactionRecord4Cocoa *record = [[[ManifestTransactionRecord4Cocoa alloc] init] autorelease];
        record.productCategory = productDetail.productCategory;
        //record.productCount = [productDetail.productCount doubleValue];
        record.productCount = productDetail.productCountFloat;
        record.productDiscount = [productDetail.productDiscount doubleValue];
        record.productName = productDetail.productName;
        record.productPrice = [productDetail.productPrice doubleValue];
        record.productUnit = productDetail.productUnit;
        
        record.goodsNameUUID = productDetail.goodsNameUUID;
        record.goodsCategoryUUID = productDetail.goodsCategoryUUID;
        record.unitUUID = productDetail.unitUUID;
        record.warehouseUUID = productDetail.warehouseUUID;
        record.transactionUUID = transactionUUID;
        record.goodsSKUUUIDArray = productDetail.skuValueUUIDs;
        record.dishProperty = productDetail.dishProperty;
        
        [transactionList addObject:record];
    }
    
    NSString *orderDate = manifestStorage.currentManifestDate;
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *selectedDate = [dateFormater dateFromString:orderDate];
    time_t manifestTime = [selectedDate timeIntervalSince1970];
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    //! @todo 接入通讯录后，这里设置为真实的结算账户及交易方
    NSString *counterPartyUUID = @"";
    
    if (kJCHOrderShipment == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultCustomUUID];
    } else if (kJCHOrderPurchases == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultSupplierUUID];
    }
    
    if (manifestStorage.currentContactsRecord.contactUUID) {
        counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
    }
    
    
    //! @note 分两种情况，调两种接口   1.出货单或者收款单   2.储值卡充值
    if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderReceipt) {
        
        //出货单或者收款单
        
        ManifestInfoRecord4Cocoa *manifestInfoRecord = [[[ManifestInfoRecord4Cocoa alloc] init] autorelease];
        manifestInfoRecord.manifestID = manifestStorage.currentManifestID;
        manifestInfoRecord.manifestType = manifestStorage.currentManifestType;
        manifestInfoRecord.manifestRemark = manifestStorage.currentManifestRemark;
        manifestInfoRecord.manifestTimestamp = manifestTime;
        manifestInfoRecord.thirdPartOrderID = @"";
        manifestInfoRecord.thirdPartType = 0;
        manifestInfoRecord.expressCompany = @"";
        manifestInfoRecord.expressNumber = @"";
        manifestInfoRecord.consigneeName = @"";
        manifestInfoRecord.consigneePhone = @"";
        manifestInfoRecord.consigneeAddress = @"";
        
        
        [manifestService insertManifest:manifestInfoRecord
                        transactionList:transactionList
                       manifestDiscount:manifestStorage.currentManifestDiscount
                            eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                           counterParty:counterPartyUUID
                     paymentAccountUUID:paymentAccountUUID
                             operatorID:[[[JCHSyncStatusManager shareInstance] userID] integerValue]
                          feeRecordList:nil];
        
        manifestStorage.hasPayed = YES;
        
        //蓝牙打印
#if !TARGET_OS_SIMULATOR
        JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
        
        if ((bluetoothManager.canPrintInShipment && manifestStorage.currentManifestType == kJCHOrderShipment) ||
            (bluetoothManager.canPrintInPurchase && manifestStorage.currentManifestType == kJCHOrderPurchases)) {
            
#if !TARGET_OS_SIMULATOR
            JCHPrintInfoModel *printInfo = [[[JCHPrintInfoModel alloc] init] autorelease];
            printInfo.manifestType = manifestStorage.currentManifestType;
            printInfo.manifestID = manifestStorage.currentManifestID;
            printInfo.manifestDate = manifestStorage.currentManifestDate;
            printInfo.manifestDiscount = manifestStorage.currentManifestDiscount;
            printInfo.eraseAmount = manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected;
            printInfo.manifestRemark = manifestStorage.currentManifestRemark;
            printInfo.contactName = manifestStorage.currentContactsRecord.name;
            printInfo.hasPayed = manifestStorage.hasPayed;
            printInfo.transactionList = currentProductInManifestList;
            [[JCHBluetoothManager shareInstance] printManifest:printInfo showHud:NO];
#endif
        }
#endif
        
    } else if (manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
        
        //出货单或者收款单
        [manifestService preInsertOrUpdateManifest:transactionList
                                      manifestType:manifestStorage.currentManifestType
                                      manifestTime:manifestTime
                                        manifestID:manifestStorage.currentManifestID
                                  manifestDiscount:manifestStorage.currentManifestDiscount
                                    manifestRemark:manifestStorage.currentManifestRemark
                                       eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                                      counterParty:counterPartyUUID
                                paymentAccountUUID:[manifestService getPreInsertManifestAccountUUID]
                                        operatorID:[[[JCHSyncStatusManager shareInstance] userID] integerValue]
                                           tableID:-1];
        
        manifestStorage.hasPayed = YES;
        
        //蓝牙打印
#if !TARGET_OS_SIMULATOR
        JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
        
        if ((bluetoothManager.canPrintInShipment && manifestStorage.currentManifestType == kJCHOrderShipment) ||
            (bluetoothManager.canPrintInPurchase && manifestStorage.currentManifestType == kJCHOrderPurchases)) {
            
#if !TARGET_OS_SIMULATOR
            JCHPrintInfoModel *printInfo = [[[JCHPrintInfoModel alloc] init] autorelease];
            printInfo.manifestType = manifestStorage.currentManifestType;
            printInfo.manifestID = manifestStorage.currentManifestID;
            printInfo.manifestDate = manifestStorage.currentManifestDate;
            printInfo.manifestDiscount = manifestStorage.currentManifestDiscount;
            printInfo.eraseAmount = manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected;
            printInfo.manifestRemark = manifestStorage.currentManifestRemark;
            printInfo.contactName = manifestStorage.currentContactsRecord.name;
            printInfo.hasPayed = manifestStorage.hasPayed;
            printInfo.transactionList = currentProductInManifestList;
            [[JCHBluetoothManager shareInstance] printManifest:printInfo showHud:NO];
#endif
        }
#endif
        
    } else if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
        
        NSInteger operatorID = [[[JCHSyncStatusManager shareInstance] userID] integerValue];
        [manifestService rechargeCard:manifestStorage.currentManifestID
                         manifestTime:manifestTime
                           customUUID:manifestStorage.currentContactsRecord.contactUUID
                   paymentAccountUUID:paymentAccountUUID
                               amount:manifestStorage.savingCardRechargeAmount
                           operatorID:(int)operatorID
                     operateTimestamp:manifestTime];
    }
    
    // 关闭扫码界面
    if (nil != self.presentedViewController) {
        [(JCHPayCodeViewController *)self.presentedViewController handleDissmiss];
    }
    
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
}

#pragma mark -
#pragma mark 扫描支付宝二维码
- (void)handleFinishScanBarAlipayBarCode:(NSString *)qrCode
{
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager handleFinishScanBarAlipayBarCode:qrCode];
}

#pragma mark -
#pragma mark 扫描微信二维码
- (void)handleFinishScanWeiXinBarCode:(NSString *)qrCode
{
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager handleFinishScanWeiXinBarCode:qrCode];
}

- (void)restartQueryPayStatus
{
    // 停掉之前的查询定时器
    [self stopQueryPayStatusTimer];
    
    // 重新启动定时器
    [self startQueryPayStatusTimer];
}


- (void)queryPayStatusStatus
{
    queryPayStatusUsedTime += kQueryCMBCPayStatusTime;
    if (queryPayStatusUsedTime >= kQueryCMBCPayStatusTimeOut) {
        [self stopQueryPayStatusTimer];
        [self dismissViewControllerAnimated:YES completion:nil];
        [MBProgressHUD hideAllHudsForWindow];
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"查询支付状态超时"
                               duration:3.0
                                   mode:MBProgressHUDModeText
                             completion:nil];
        return;
    }
    
    WeakSelf;
    JCHSettlementManager *settlementManager = [JCHSettlementManager sharedInstance];
    [settlementManager queryPayStatusStatus:^{
        // 停止支付状态查询
        [weakSelf stopQueryPayStatusTimer];
        
        // 保存货单
        [weakSelf saveOrderList:weakSelf.onlinePayAccountUUID];
    }];
}

#pragma mark -
#pragma mark 启动支付结果查询定时器
- (void)startQueryPayStatusTimer
{
    queryPayStatusUsedTime = 0;
    [self stopQueryPayStatusTimer];
    
    self.payStatusTimer = [MSWeakTimer scheduledTimerWithTimeInterval:kQueryCMBCPayStatusTime
                                                               target:self
                                                             selector:@selector(queryPayStatusStatus)
                                                             userInfo:nil
                                                              repeats:YES
                                                        dispatchQueue:dispatch_get_main_queue()];
}

#pragma mark -
#pragma mark 停止支付状态查询定时器
- (void)stopQueryPayStatusTimer
{
    [self.payStatusTimer invalidate];
    self.payStatusTimer = nil;
}

@end
