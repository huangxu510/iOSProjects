//
//  JCHRechargeSavingCardViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRechargeSavingCardViewController.h"
#import "JCHSavingCardSetAmountViewController.h"
#import "JCHCheckoutViewController.h"
#import "JCHSavingCardTransactionViewController.h"
#import "CommonHeader.h"

@interface JCHRechargeSavingCardViewController () <UITextFieldDelegate>
{
    JCHArrowTapView *_balanceView;
    UILabel *_discountInfoLabel;
    JCHArrowTapView *_rechargeView;
    JCHTitleTextField *_savingCardNumberView;
}
@property (nonatomic, retain) ContactsRecord4Cocoa *contactRecord;
@end

@implementation JCHRechargeSavingCardViewController

- (instancetype)initWithContanctRecord:(ContactsRecord4Cocoa *)contactRecord
{
    self = [super init];
    if (self) {
        self.title = @"储值卡管理";
        self.contactRecord = contactRecord;
    }
    return self;
}

- (void)dealloc
{
    self.contactRecord = nil;
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
    _balanceView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _balanceView.titleLabel.text = @"储值卡余额";
    _balanceView.detailLabel.text = @"¥100.00";
    _balanceView.detailLabel.font = [UIFont boldSystemFontOfSize:30.0f];
    [_balanceView addSeparateLineWithMasonryTop:YES bottom:NO];
    [_balanceView.button addTarget:self action:@selector(handleBalanceDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_balanceView];
    
    [_balanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(100);
    }];

    _discountInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"折扣"
                                              font:JCHFont(13)
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentRight];
    [_balanceView addSubview:_discountInfoLabel];
    
    [_discountInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.bottom.equalTo(_balanceView);
        make.left.right.equalTo(_balanceView.detailLabel);
    }];
    
    _rechargeView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _rechargeView.titleLabel.text = @"储值卡充值";
    _rechargeView.bottomLine.hidden = YES;
    [_rechargeView.button addTarget:self action:@selector(handleRecharge) forControlEvents:UIControlEventTouchUpInside];
    [_rechargeView addSeparateLineWithMasonryTop:NO bottom:YES];
    [self.backgroundScrollView addSubview:_rechargeView];
    
    [_rechargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_balanceView.mas_bottom);
        make.left.right.equalTo(_balanceView);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _savingCardNumberView = [[JCHTitleTextField alloc] initWithTitle:@"储值卡卡号"
                                                                font:JCHFontStandard
                                                         placeholder:@"仅用于查询实体卡(可不填)"
                                                           textColor:JCHColorMainBody];
    [_savingCardNumberView addSeparateLineWithMasonryTop:YES bottom:YES];
    _savingCardNumberView.textField.delegate = self;
    _savingCardNumberView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.backgroundScrollView addSubview:_savingCardNumberView];
    
    [_savingCardNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_rechargeView.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.left.and.right.equalTo(_balanceView);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    UIButton *_retreatCardButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleRetreatCard)
                                         title:@"退卡"
                                    titleColor:JCHColorMainBody
                               backgroundColor:[UIColor whiteColor]];
    _retreatCardButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.backgroundScrollView addSubview:_retreatCardButton];
    
    [_retreatCardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_savingCardNumberView.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(kStandardButtonHeight);
    }];
    [_retreatCardButton addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_retreatCardButton).with.offset(kStandardSeparateViewHeight);
    }];
}

#pragma mark - LoadData
- (void)loadData
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    CGFloat balance = [manifestService queryCardBalance:self.contactRecord.contactUUID];
    
    _balanceView.detailLabel.text = [NSString stringWithFormat:@"¥ %.2f", balance];
    _savingCardNumberView.textField.text = self.contactRecord.cardID;
    
    CGFloat discount = self.contactRecord.cardDiscount;
    NSString *discountString = nil;
    if (discount == 1 || discount == 0) {
        discountString = @"不享受折扣优惠";
    } else {
        discountString = [JCHTransactionUtility getOrderDiscountFromFloat:discount];
        discountString = [NSString stringWithFormat:@"可享受%@优惠", discountString];
    }
    _discountInfoLabel.text = discountString;
    
    //余额为0，不显示折扣信息
    if (balance == 0) {

        _discountInfoLabel.hidden = YES;
    } else {
        _discountInfoLabel.hidden = NO;
    }
}

#pragma mark - 充值详情
- (void)handleBalanceDetail
{
    JCHSavingCardTransactionViewController *savingCardTransactionDetailVC = [[[JCHSavingCardTransactionViewController alloc] initWithContanctRecord:self.contactRecord] autorelease];
    [self.navigationController pushViewController:savingCardTransactionDetailVC animated:YES];
}

#pragma mark - 充值
- (void)handleRecharge
{    
    JCHSavingCardSetAmountViewController *savingCaredSetAmountVC = [[[JCHSavingCardSetAmountViewController alloc] initWithContanctRecord:self.contactRecord] autorelease];
    [self.navigationController pushViewController:savingCaredSetAmountVC animated:YES];
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    appDelegate.switchToTargetController = self;
}

#pragma mark - 退卡
- (void)handleRetreatCard
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    CGFloat balance = [manifestService queryCardBalance:self.contactRecord.contactUUID];
    if (balance == 0) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"储值卡余额为0.00，无需退卡"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    
    manifestStorage.currentManifestType = kJCHManifestCardRefund;
    manifestStorage.currentContactsRecord = self.contactRecord;
    manifestStorage.currentManifestDate = dateString;
    manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestCardRefund];
    
    JCHCheckoutViewController *checkoutVC = [[[JCHCheckoutViewController alloc] initWithPayWay:kJCHCheckoutPayWayCash] autorelease];
    [self.navigationController pushViewController:checkoutVC animated:YES];
    AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
    appDelegate.switchToTargetController = self;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    self.contactRecord.cardID = textField.text;
    [contactsService updateAccount:self.contactRecord];
}

@end

