//
//  JCHCheckoutByCashViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCheckoutViewController.h"
#import "JCHReceivePartAmountAlertView.h"
#import "JCHAccountBookViewController.h"
#import "JCHChargeAccountDetailViewController.h"
#import "JCHChargeAccountViewController.h"
#import "JCHAddProductMainViewController.h"
#import "JCHSettleAccountsKeyboardView.h"
#import "JCHRestaurantManifestUtility.h"
#import "JCHSyncStatusManager.h"
#import "CommonHeader.h"
#import "JCHManifestMemoryStorage.h"
#import "ServiceFactory.h"
#import "MBProgressHUD+JCHHud.h"
#import "JCHBluetoothManager.h"
#import <Masonry.h>
#import <KLCPopup.h>

@interface JCHCheckoutViewController () <JCHSettleAccountsKeyboardViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    JCHLabel *_receivableAmountLabel;
//    UITextField *_actualMoneyTextField;
    JCHLengthLimitTextField *_actualMoneyTextField;
    UILabel *_changeMoneyLabel;
    JCHSettleAccountsKeyboardView *_keyboard;
    JCHCheckoutPayWay _currentPayWay;
    BOOL _isObserverActualMoneyTextField;
    UILabel *_discountLabel;
    UILabel *_balanceLabel;
    UILabel *_infoLabel;
}
@end

@implementation JCHCheckoutViewController

- (instancetype)initWithPayWay:(JCHCheckoutPayWay)payWay
{
    self = [super init];
    if (self) {
        _currentPayWay = payWay;
        
        if (_currentPayWay == kJCHCheckoutPayWaySavingCard) {
            self.title = @"储值卡付款";
        } else if (_currentPayWay == kJCHCheckoutPayWayCash){
            JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
            
            if (manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHOrderPayment) {
                self.title = @"现金付款";
            } else if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderReceipt) {
                self.title = @"现金收银";
            }
        } else {
            //pass
        }
    }
    return self;
}

- (void)dealloc
{
    if (_isObserverActualMoneyTextField) {
        [_actualMoneyTextField removeObserver:self forKeyPath:@"text"];
    }
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    self.view.clipsToBounds = YES;
    
    //UIBarButtonItem *rechargeButton = [[[UIBarButtonItem alloc] initWithTitle:@"充值"
    //style:UIBarButtonItemStylePlain
    //target:self
    //action:@selector(recharge)] autorelease];
    
    //self.navigationItem.rightBarButtonItem = rechargeButton;
    
    CGFloat topContainerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:150.0f];
    CGFloat actualContainerViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:75.0f];
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
                                                    title:@"¥ 234.50"
                                                     font:[UIFont jchSystemFontOfSize:42.0f]
                                                textColor:[UIColor whiteColor]
                                                   aligin:NSTextAlignmentLeft];
    _receivableAmountLabel.verticalAlignment = kVerticalAlignmentTop;
    [topContainerView addSubview:_receivableAmountLabel];
    
    
    [_receivableAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topContainerView).with.offset(2 * kStandardLeftMargin);
        make.top.equalTo(amountTitleLabel.mas_bottom);
        make.height.mas_equalTo(topContainerViewHeight / 2);
    }];
    
    _discountLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(14)
                                     textColor:[UIColor whiteColor]
                                        aligin:NSTextAlignmentLeft];
    [topContainerView addSubview:_discountLabel];
    
    [_discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_receivableAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        make.height.equalTo(_receivableAmountLabel);
        make.centerY.equalTo(_receivableAmountLabel);
    }];
    
    UIView *actualContainerView = [[[UIView alloc] init] autorelease];
    actualContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:actualContainerView];
    
    [actualContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContainerView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(actualContainerViewHeight);
    }];
    
    [actualContainerView addSeparateLineWithMasonryTop:NO bottom:YES];
    
    UILabel *actualMoneyTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                         title:@"实收金额"
                                                          font:[UIFont systemFontOfSize:14.0f]
                                                     textColor:JCHColorMainBody
                                                        aligin:NSTextAlignmentLeft];
    [actualContainerView addSubview:actualMoneyTitleLabel];
    
    CGSize fitSize = [actualMoneyTitleLabel.text sizeWithAttributes:@{NSFontAttributeName : actualMoneyTitleLabel.font}];
    
    [actualMoneyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(actualContainerView).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(actualContainerView);
        make.width.mas_equalTo(fitSize.width + 10);
    }];
    
    _actualMoneyTextField = [JCHUIFactory createLengthLimitTextField:CGRectZero
                                                         placeHolder:@""
                                                           textColor:JCHColorMainBody
                                                              aligin:NSTextAlignmentRight];
    _actualMoneyTextField.keyboardType = UIKeyboardTypeNumberPad;
    _actualMoneyTextField.inputAccessoryView = nil;
    _actualMoneyTextField.font = [UIFont systemFontOfSize:24.0f];
    _actualMoneyTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"请输入金额" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : [UIFont systemFontOfSize:20.0f]}] autorelease];
    [_actualMoneyTextField becomeFirstResponder];
    [actualContainerView addSubview:_actualMoneyTextField];
    
    [_actualMoneyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(actualContainerView).with.offset(-kStandardLeftMargin);
        make.top.and.bottom.equalTo(actualContainerView);
        make.left.equalTo(actualMoneyTitleLabel.mas_right).with.offset(kStandardLeftMargin);
    }];
    
    UILabel *changeMoneyLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"找零"
                                                     font:[UIFont systemFontOfSize:14.0f]
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [self.view addSubview:changeMoneyLabel];
    
    [changeMoneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width + 10);
        make.top.equalTo(actualContainerView.mas_bottom);
        make.height.mas_equalTo(actualContainerViewHeight);
    }];
    
    _changeMoneyLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"¥ 0.00"
                                             font:[UIFont systemFontOfSize:24.0f]
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentRight];
    [self.view addSubview:_changeMoneyLabel];
    
    [_changeMoneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(changeMoneyLabel.mas_right).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(changeMoneyLabel);
        make.right.equalTo(self.view).with.offset(-kStandardLeftMargin);
    }];
    
    _keyboard = [[[JCHSettleAccountsKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, keyboardViewHeight)
                                                       keyboardHeight:keyboardViewHeight
                                                              topView:nil
                                               topContainerViewHeight:0] autorelease];
    _keyboard.delegate = self;
    _actualMoneyTextField.inputView = _keyboard;
    
    _balanceLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"余额"
                                         font:JCHFont(16)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    _balanceLabel.hidden = YES;
    [actualContainerView addSubview:_balanceLabel];
    
    [_balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(actualMoneyTitleLabel);
        make.right.equalTo(actualContainerView.mas_right).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(actualContainerView.mas_centerY);
        make.top.equalTo(actualContainerView).with.offset(kStandardLeftMargin);
    }];
    _infoLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"整单折扣会优先使用储值卡折扣"
                                      font:JCHFont(12)
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    _infoLabel.hidden = YES;
    [actualContainerView addSubview:_infoLabel];
    
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_balanceLabel);
        make.top.equalTo(_balanceLabel.mas_bottom);
        make.bottom.equalTo(actualContainerView).with.offset(-kStandardLeftMargin / 2);
    }];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    //! @note 根据各种货单对UI进行调整
    if (manifestStorage.currentManifestType == kJCHOrderShipment) {//出货单
        amountTitleLabel.text = @"应收金额";
        actualMoneyTitleLabel.text = @"实收金额";
        if (_currentPayWay == kJCHCheckoutPayWaySavingCard) {//储值卡支付
            changeMoneyLabel.hidden = YES;
            _changeMoneyLabel.hidden = YES;
            actualMoneyTitleLabel.hidden = YES;
            _actualMoneyTextField.hidden = YES;
            _balanceLabel.hidden = NO;
            _infoLabel.hidden = NO;
        }
    } else if (manifestStorage.currentManifestType == kJCHOrderPurchases) { //进货单
        amountTitleLabel.text = @"应付金额";
        actualMoneyTitleLabel.text = @"实付金额";
    } else if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) { //储值卡充值
        amountTitleLabel.text = @"充值金额";
        actualMoneyTitleLabel.text = @"充值金额";
        changeMoneyLabel.hidden = YES;
        _changeMoneyLabel.hidden = YES;
    } else if (manifestStorage.currentManifestType == kJCHManifestCardRefund) { //储值卡退卡
        amountTitleLabel.text = @"退款金额";
        actualMoneyTitleLabel.text = @"退款金额";
        changeMoneyLabel.hidden = YES;
        _changeMoneyLabel.hidden = YES;
    } else {
        //pass
    }
}

//使用储值卡支付， 更新余额、折扣信息
- (void)updateBalanceLabel
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    CGFloat balance = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
    CGFloat discount = manifestStorage.currentContactsRecord.cardDiscount;
    NSString *discountTopString = @"";
    if (discount < 1 && discount > 0) {
        NSString *discountString = [JCHTransactionUtility getOrderDiscountFromFloat:discount];
        discountTopString = [NSString stringWithFormat:@"（%@后）", discountString];
        _balanceLabel.text = [NSString stringWithFormat:@"余额：¥%.2f（%@优惠）", balance, discountString];
    } else {
        _balanceLabel.text = [NSString stringWithFormat:@"余额：¥%.2f（无折扣）", balance];
    }
    if (balance < manifestStorage.receivableAmount) {
        _balanceLabel.textColor = JCHColorAuxiliary;
        _infoLabel.textColor = JCHColorHeaderBackground;
        _infoLabel.text = @"余额不足，请充值或选择其他支付方式";
    }
    
    _discountLabel.text = discountTopString;
}

- (void)setUpObserver
{
    [_actualMoneyTextField addObserver:self
                            forKeyPath:@"text"
                               options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                               context:NULL];
    _isObserverActualMoneyTextField = YES;
}

#pragma mark - LoadData

- (void)loadData
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    //现金付款
    if (_currentPayWay == kJCHCheckoutPayWayCash) {
        
        //储值卡退款
        if (manifestStorage.currentManifestType == kJCHManifestCardRefund) {
            id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
            CGFloat amount = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
            _receivableAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", amount];
            _actualMoneyTextField.text = _receivableAmountLabel.text;
            [self setUpObserver];
            
        } else if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
            //储值卡充值
            _receivableAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.savingCardRechargeAmount];
            _actualMoneyTextField.text = _receivableAmountLabel.text;
            [self setUpObserver];
        } else {
            _receivableAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.receivableAmount];
        }
    } else if (_currentPayWay == kJCHCheckoutPayWaySavingCard){
        
        _receivableAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.receivableAmount];
        if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
            NSLog(@"货单类型错误");
        } else {//储值卡付款
            //选择储值卡付款后，应收金额应该是之前的总金额乘以 该联系人的折扣
            CGFloat receivableAmount = manifestStorage.receivableAmount / manifestStorage.currentManifestDiscount * manifestStorage.currentContactsRecord.cardDiscount;
            manifestStorage.receivableAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:receivableAmount];
            _receivableAmountLabel.text = [NSString stringWithFormat:@" %.2f", manifestStorage.receivableAmount];
            _actualMoneyTextField.text = _receivableAmountLabel.text;
            manifestStorage.currentManifestDiscount = 1.0;
            //使用储值卡支付，取消抹零
            manifestStorage.isRejected = NO;
            [self setUpObserver];
            [self updateBalanceLabel];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _actualMoneyTextField) {
        if ([keyPath isEqualToString:@"text"]) {
            
            //NSString *newText = change[NSKeyValueChangeNewKey];
            NSString *oldText = change[NSKeyValueChangeOldKey];
            
            if ([oldText isEmptyString]) {
                return;
            }
            [_actualMoneyTextField removeObserver:self forKeyPath:@"text"];
            _actualMoneyTextField.text = oldText;
            [_actualMoneyTextField addObserver:self forKeyPath:@"text" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        }
    }
}

#pragma mark - 储值卡储值
- (void)recharge
{
    
}

#pragma mark - JCHSettleAccountsKeyboardViewDelegate

- (void)keyboardViewInputNumber:(NSString *)number
{
    NSString *text = [_actualMoneyTextField.text stringByReplacingOccurrencesOfString:@"¥ " withString:@""];
    _actualMoneyTextField.text = [NSString stringWithFormat:@"¥ %@", [text stringByAppendingString:number]];
    
    [self calculateChangeMoneyWithInputText:_actualMoneyTextField.text];
}

- (void)calculateChangeMoneyWithInputText:(NSString *)inputText
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    NSString *text = [inputText stringByReplacingOccurrencesOfString:@"¥ " withString:@""];
    CGFloat actualMoney = [text doubleValue];
    CGFloat changeMoney = actualMoney - manifestStorage.receivableAmount;
    changeMoney = MAX(changeMoney, 0);
    
    _changeMoneyLabel.text = [NSString stringWithFormat:@"¥ %.2f", changeMoney];
}

- (void)keyboardViewFunctionButtonClick:(NSInteger)buttonTag;
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    NSString *text = [_actualMoneyTextField.text stringByReplacingOccurrencesOfString:@"¥ " withString:@""];
    
    switch (buttonTag) {
        case kJCHSettleAccountsKeyboardViewButtonTagDot:
        {
            _actualMoneyTextField.text = [NSString stringWithFormat:@"¥ %@", [text stringByAppendingString:@"."]];
        }
            break;
        case kJCHSettleAccountsKeyboardViewButtonTagBackSpace:
        {
            if (text.length == 0) {
                return;
            }
            if (text.length != 1) {
                _actualMoneyTextField.text = [NSString stringWithFormat:@"¥ %@", [text substringToIndex:text.length - 1]];
                [self calculateChangeMoneyWithInputText:_actualMoneyTextField.text];
            } else {
                _actualMoneyTextField.text = @"";
            }
            [self calculateChangeMoneyWithInputText:_actualMoneyTextField.text];
        }
            break;
        case kJCHSettleAccountsKeyboardViewButtonTagClear:
        {
            _actualMoneyTextField.text = @"";
            [self calculateChangeMoneyWithInputText:_actualMoneyTextField.text];
        }
            break;
        case kJCHSettleAccountsKeyboardViewButtonTagOK:
        {
            CGFloat actualMoney = [text doubleValue];
            
            //对receivableAmount进行保留两位小数在进行比较
            CGFloat receivableAmount = [JCHFinanceCalculateUtility roundDownFloatNumber:manifestStorage.receivableAmount];
            
            if ([JCHFinanceCalculateUtility compareFloatNumber:actualMoney with:receivableAmount] == kJCHCompareFloatNumberResultLess) {
                
                //暂时去掉少付功能   || manifestStorage.currentManifestType == kJCHOrderPayment
                if (manifestStorage.currentManifestType == kJCHOrderReceipt) {
                    //收款单或付款单进行少收少付
                    _changeMoneyLabel.text = @"¥ 0.00";
                    CGFloat actualTotalAmount = [[_actualMoneyTextField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
                    if (actualTotalAmount == 0) {
                        _actualMoneyTextField.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.receivableAmount];
                    } else {
                        JCHReceivePartAmountAlertView *alertView = [[[JCHReceivePartAmountAlertView alloc] initWithFrame:CGRectMake(0, 0, 250, 200)] autorelease];
                        alertView.layer.cornerRadius = 5;
                        alertView.clipsToBounds = YES;
                        
                        JCHReceivePartAmountAlertViewData *data = [[[JCHReceivePartAmountAlertViewData alloc] init] autorelease];
                        data.manifetType = manifestStorage.currentManifestType;
                        data.manifestARAPAmount = receivableAmount;
                        data.manifestRealPayAmount = actualTotalAmount;
                        
                        [alertView setViewData:data];
                        
                        KLCPopup *popupView = [KLCPopup popupWithContentView:alertView
                                                                    showType:KLCPopupShowTypeGrowIn
                                                                 dismissType:KLCPopupDismissTypeFadeOut
                                                                    maskType:KLCPopupMaskTypeDimmed
                                                    dismissOnBackgroundTouch:NO
                                                       dismissOnContentTouch:NO];
                        
                        [popupView show];
                        [_actualMoneyTextField resignFirstResponder];
                        WeakSelf;
                        alertView.determineAction = ^{
                            [popupView dismiss:YES];
                            [weakSelf manifestPreferential:actualTotalAmount];
                        };
                        alertView.cancleAction = ^{
                            [popupView dismiss:YES];
                            [_actualMoneyTextField becomeFirstResponder];
                        };
                    }
                } else {
                    //其它单补齐金额
                    _changeMoneyLabel.text = @"¥ 0.00";
                    _actualMoneyTextField.text = [NSString stringWithFormat:@"¥ %.2f", manifestStorage.receivableAmount];
                }

            } else {
                
                //储值卡充值或者退卡时提示用户即将充值(退)多钱
                WeakSelf;
                if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
                    
                    NSString *message = [NSString stringWithFormat:@"确定充值%.2f元?", manifestStorage.savingCardRechargeAmount];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                             message:message
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf saveOrderList];
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [alertController addAction:alertAction];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;
                } else if (manifestStorage.currentManifestType == kJCHManifestCardRefund) {
                    id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
                    CGFloat amount = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
                    NSString *message = [NSString stringWithFormat:@"确定退款%.2f元?", amount];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                             message:message
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf saveOrderList];
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [alertController addAction:alertAction];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                    //保存订单
                    [self saveOrderList];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

//少收少付
- (void)manifestPreferential:(CGFloat)realAmount
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.manifestARAPList.count > 0) {
        ManifestARAPRecord4Cocoa *arapRecord = [manifestStorage.manifestARAPList firstObject];
        arapRecord.manifestRealPayAmount = realAmount;
        
        [self saveOrderList];
    }
}


- (void)saveOrderList
{
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    
    if (manifestStorage.currentManifestDiscount < 0 || manifestStorage.currentManifestDiscount > 1) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"折扣信息异常"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
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
    NSString *paymentAccountUUID = @"";
    
    //折扣 当选择储值卡时为联系人的折扣信息，
    CGFloat manifestDiscount = manifestStorage.currentManifestDiscount;
    
    //现金付款 paymentAccountUUID 为默认现金账户UUID
    if (_currentPayWay == kJCHCheckoutPayWayCash) {
        paymentAccountUUID = [manifestService getDefaultCashRMBAccountUUID];
        
        //counterPartyUUID 添加了客户或者供应商 则为客户或者供应商的UUID，没添加则为默认客户或者供应商的UUID
        if (kJCHOrderShipment == manifestStorage.currentManifestType) {
            counterPartyUUID = [manifestService getDefaultCustomUUID];
        } else if (kJCHOrderPurchases == manifestStorage.currentManifestType) {
            counterPartyUUID = [manifestService getDefaultSupplierUUID];
        }
        
        if (manifestStorage.currentContactsRecord.contactUUID) {
            counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
        }
    } else if (_currentPayWay == kJCHCheckoutPayWaySavingCard) {
        CGFloat balance = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
        if (balance < manifestStorage.receivableAmount) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:@"该储值卡余额不足，请充值"
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        //储值卡付款 paymentAccountUUID 为默认储值卡账户UUID
        paymentAccountUUID = [manifestService getCardAccountUUID];
        
        //counterPartyUUID 为客户的UUID
        counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
        
        //当选择储值卡时为联系人的折扣信息
        manifestDiscount = manifestStorage.currentContactsRecord.cardDiscount;
        manifestStorage.currentManifestDiscount = 1.0;
    } else {
        //pass
    }
    
    if (kJCHOrderShipment == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultCustomUUID];
    } else if (kJCHOrderPurchases == manifestStorage.currentManifestType) {
        counterPartyUUID = [manifestService getDefaultSupplierUUID];
    }
    
    if (manifestStorage.currentContactsRecord.contactUUID) {
        counterPartyUUID = manifestStorage.currentContactsRecord.contactUUID;
    }
    
    NSInteger operatorID = [[[JCHSyncStatusManager shareInstance] userID] integerValue];
    int status = 1;
    
    //应收应付货单
    if (manifestStorage.currentManifestType == kJCHOrderReceipt || manifestStorage.currentManifestType == kJCHOrderPayment) {
        TICK;
        status = [manifestService manifestARAP:manifestStorage.currentContactsRecord.contactUUID
                                   accountUUID:paymentAccountUUID
                                    operatorID:operatorID
                              manifestARAPList:manifestStorage.manifestARAPList];
        TOCK(@"manifestARAP");
    } else if (manifestStorage.currentManifestType == kJCHOrderShipment || manifestStorage.currentManifestType == kJCHOrderPurchases || manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable){
        //进货单 出货单
        
        //新增货单 / 复制货单
        if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew || manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
#if !MMR_RESTAURANT_VERSION
            
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
            
            
            status = [manifestService insertManifest:manifestInfoRecord
                                     transactionList:transactionList
                                    manifestDiscount:manifestStorage.currentManifestDiscount
                                         eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                                        counterParty:counterPartyUUID
                                  paymentAccountUUID:paymentAccountUUID
                                          operatorID:operatorID
                                       feeRecordList:nil];
            
#else
            if (manifestStorage.currentManifestType == kJCHOrderShipment ||
                manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
                status = 0;
                id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
                DiningTableRecord4Cocoa *tableRecord = [diningTableService qeryDiningTable:manifestStorage.tableID];
                ManifestRecord4Cocoa *manifestRecord = [[[ManifestRecord4Cocoa alloc] init] autorelease];
                manifestRecord.manifestDiscount = 1.0;
                manifestRecord.eraseAmount = 0.0;
                manifestRecord.manifestID = manifestStorage.currentManifestID;
                manifestRecord.manifestTimestamp = [[NSDate date] timeIntervalSince1970];
                manifestRecord.manifestType = kJCHOrderShipment;
                manifestRecord.manifestRemark = @"手机开台测试";
                manifestRecord.manifestTransactionArray = transactionList;
                [JCHRestaurantManifestUtility restaurantOpenTable:(ManifestRecord4Cocoa *)manifestRecord
                                                          tableID:manifestStorage.tableID
                                                        tableName:tableRecord.tableName
                                               oldTransactionList:manifestStorage.restaurantPreInsertManifestArray
                                             navigationController:self.navigationController];
            } else {
                
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
                
                status = [manifestService insertManifest:manifestInfoRecord
                                         transactionList:transactionList
                                        manifestDiscount:manifestStorage.currentManifestDiscount
                                             eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                                            counterParty:counterPartyUUID
                                      paymentAccountUUID:paymentAccountUUID
                                              operatorID:operatorID
                                           feeRecordList:nil];
            }
#endif

        } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
#if !MMR_RESTAURANT_VERSION
            //编辑货单
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
            
            status = [manifestService updateManifest:manifestInfoRecord
                                     transactionList:transactionList
                                    manifestDiscount:manifestStorage.currentManifestDiscount
                                         eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                                        counterParty:counterPartyUUID
                                  paymentAccountUUID:paymentAccountUUID
                                          operatorID:operatorID
                                       feeRecordList:nil];
#else
            if (manifestStorage.currentManifestType == kJCHOrderShipment ||
                manifestStorage.currentManifestType == kJCHRestaurntManifestOpenTable) {
                status = 0;
                id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
                DiningTableRecord4Cocoa *tableRecord = [diningTableService qeryDiningTable:manifestStorage.tableID];
                ManifestRecord4Cocoa *manifestRecord = [[[ManifestRecord4Cocoa alloc] init] autorelease];
                manifestRecord.manifestDiscount = 1.0;
                manifestRecord.eraseAmount = 0.0;
                manifestRecord.manifestID = manifestStorage.currentManifestID;
                manifestRecord.manifestTimestamp = [[NSDate date] timeIntervalSince1970];
                manifestRecord.manifestType = kJCHOrderShipment;
                manifestRecord.manifestRemark = @"手机开台测试";
                manifestRecord.manifestTransactionArray = transactionList;
                [JCHRestaurantManifestUtility restaurantOpenTable:(ManifestRecord4Cocoa *)manifestRecord
                                                          tableID:manifestStorage.tableID
                                                        tableName:tableRecord.tableName
                                               oldTransactionList:manifestStorage.restaurantPreInsertManifestArray
                                             navigationController:self.navigationController];
            } else {
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
                
                status = [manifestService updateManifest:manifestInfoRecord
                                         transactionList:transactionList
                                        manifestDiscount:manifestStorage.currentManifestDiscount
                                             eraseAmount:manifestStorage.currentManifestEraseAmount * manifestStorage.isRejected
                                            counterParty:counterPartyUUID
                                      paymentAccountUUID:paymentAccountUUID
                                              operatorID:operatorID
                                           feeRecordList:nil];
            }
#endif
        } else {
            //pass
        }
        
        manifestStorage.hasPayed = YES;
        
        //蓝牙打印
//#if !TARGET_OS_SIMULATOR
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
//#endif
    } else if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
        //储值卡充值
        status = [manifestService rechargeCard:manifestStorage.currentManifestID
                                  manifestTime:manifestTime
                                    customUUID:manifestStorage.currentContactsRecord.contactUUID
                            paymentAccountUUID:paymentAccountUUID
                                        amount:manifestStorage.savingCardRechargeAmount
                                    operatorID:(int)operatorID
                              operateTimestamp:manifestTime];
        //充值完成后更新联系人的折扣信息
        [self updateContactRecordDiscountAfterRecharge];
    } else if (manifestStorage.currentManifestType == kJCHManifestCardRefund) {
        //储值卡退卡
        CGFloat amount = [manifestService queryCardBalance:manifestStorage.currentContactsRecord.contactUUID];
        
        status = [manifestService refundCard:manifestStorage.currentManifestID
                                manifestTime:manifestTime
                                  customUUID:manifestStorage.currentContactsRecord.contactUUID
                          paymentAccountUUID:paymentAccountUUID
                                      amount:amount
                                  operatorID:(int)operatorID
                            operateTimestamp:manifestTime];
    }
    
    
    NSString *detailTextSuccess = nil;
    NSString *detailTextFailed = nil;
    
    
    if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeEdit) {
        detailTextSuccess = @"订单修改成功";
        detailTextFailed = @"订单修改失败";
        
    } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeCopy) {
        detailTextSuccess = @"订单复制成功";
        detailTextFailed = @"订单复制失败";
    } else if (manifestStorage.manifestMemoryType == kJCHManifestMemoryTypeNew) {
        
        if (manifestStorage.currentManifestType == kJCHOrderPurchases ||
            manifestStorage.currentManifestType == kJCHOrderPayment) {
            detailTextSuccess = @"付款成功";
            detailTextFailed = @"付款失败";
        } else if (manifestStorage.currentManifestType == kJCHOrderShipment ||
                   manifestStorage.currentManifestType == kJCHOrderReceipt) {
            detailTextSuccess = @"收款成功";
            detailTextFailed = @"收款失败";
        } else if (manifestStorage.currentManifestType == kJCHManifestCardRecharge) {
            detailTextSuccess = @"充值成功";
            detailTextFailed = @"充值失败";
        } else if (manifestStorage.currentManifestType == kJCHManifestCardRefund) {
            detailTextSuccess = @"退款成功";
            detailTextFailed = @"退款失败";
        }
    } else {
        //pass
    }
    
    
    
    if (status == 0) {
        if (detailTextSuccess) {
            [MBProgressHUD showHUDWithTitle:detailTextSuccess
                                     detail:nil
                                   duration:kJCHDefaultShowHudTime
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
    } else {
        if (detailTextFailed) {
            [MBProgressHUD showHUDWithTitle:detailTextFailed
                                     detail:nil
                                   duration:kJCHDefaultShowHudTime
                                       mode:MBProgressHUDModeText
                                 completion:nil];
        }
    }
    
    
    if (manifestStorage.currentManifestType == kJCHOrderReceipt || manifestStorage.currentManifestType == kJCHOrderPayment) {
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        
        JCHChargeAccountDetailViewController *chargeAccountDetailVC = nil;
        JCHChargeAccountViewController *chargeAccountVC = nil;
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:[JCHChargeAccountDetailViewController class]]) {
                chargeAccountDetailVC = (JCHChargeAccountDetailViewController *)viewController;
                
                //应收应付结完帐后标记该页面需要刷新
                chargeAccountDetailVC.isNeedReloadAllData = YES;
            }
            if ([viewController isKindOfClass:[JCHChargeAccountViewController class]]) {
                chargeAccountVC = (JCHChargeAccountViewController *)viewController;
                chargeAccountVC.isNeedReloadAllData = YES;
            }
            if ([viewController isKindOfClass:[JCHAccountBookViewController class]]) {
                JCHAccountBookViewController *accountBookViewController = (JCHAccountBookViewController *)viewController;
                accountBookViewController.isNeedReloadAllData = YES;
            }
        }
        //如果某个人的应收应付货单列表数量大于1，则返回货单列表，否则返回应收应付首页
        if (chargeAccountDetailVC.allManifest.count > 1) {
            [self.navigationController popToViewController:chargeAccountDetailVC animated:YES];
        } else {
            [self.navigationController popToViewController:chargeAccountVC animated:YES];
        }
    } else {
        AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
        [self.navigationController popToViewController:appDelegate.switchToTargetController animated:YES];
    }
}

//充值完成后更新联系人的折扣信息
- (void)updateContactRecordDiscountAfterRecharge
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    id <CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    ContactsRecord4Cocoa *contactRecord = manifestStorage.currentContactsRecord;
    CGFloat balance = [manifestService queryCardBalance:contactRecord.contactUUID];
    
    
    
    NSArray *cardDiscountRecordArray = [cardDiscountService queryAllCardDiscount];
    if (cardDiscountRecordArray.count == 0) {
        return;
    }
    CardDiscountRecord4Cocoa *cardDiscountRecord = nil;
    if (cardDiscountRecordArray.count == 1) {
        cardDiscountRecord = [cardDiscountRecordArray firstObject];
    } else {
        for (CardDiscountRecord4Cocoa *record in cardDiscountRecordArray) {
            if (balance >= record.amountLower && balance < record.amountUpper) {
                cardDiscountRecord = record;
                break;
            }
        }
        
        //如果未在阶梯折扣里面找到，并且余额大于最后一个阶梯的余额上限，则使用该阶梯的折扣
        if (cardDiscountRecord == nil || balance >= [[cardDiscountRecordArray lastObject] amountUpper]) {
            cardDiscountRecord = [cardDiscountRecordArray lastObject];
        }
    }
    
    if (cardDiscountRecord) {
        contactRecord.cardDiscount = cardDiscountRecord.discount;
        
    } else {
        contactRecord.cardDiscount = 1.0f;
    }
    [contactsService updateAccount:contactRecord];
}

#pragma - mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self saveOrderList];
    }
}

@end
