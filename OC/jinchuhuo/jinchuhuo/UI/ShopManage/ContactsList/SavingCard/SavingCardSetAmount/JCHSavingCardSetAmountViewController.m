//
//  JCHSavingCardSetAmountViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardSetAmountViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHCheckoutBottomMenuView.h"
#import "CommonHeader.h"

@interface JCHSavingCardSetAmountViewController () <UITextFieldDelegate>
{
    UILabel *_balanceLabel;
    UILabel *_discountBeforeRechargeLabel;
    UILabel *_rechargeAmountLabel;
    UITextField *_otherAmountTextField;
    JCHLabel *_discountAfterRechargeLabel;
    
    CGFloat _balance;
}
@property (nonatomic, retain) ContactsRecord4Cocoa *contactRecord;
@property (nonatomic, retain) UIButton *selectedButton;
@property (nonatomic, retain) NSArray *cardDiscountRecordArray;

@end

@implementation JCHSavingCardSetAmountViewController

- (instancetype)initWithContanctRecord:(ContactsRecord4Cocoa *)contactRecord
{
    self = [super init];
    if (self) {
        self.title = @"选择充值金额";
        self.contactRecord = contactRecord;
    }
    return self;
}
- (void)dealloc
{
    self.contactRecord = nil;
    self.selectedButton = nil;
    self.cardDiscountRecordArray = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    [self loadData];
}

- (void)createUI
{
    UIView *balanceContentView = [[[UIView alloc] init] autorelease];
    balanceContentView.backgroundColor = [UIColor whiteColor];
    [balanceContentView addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.backgroundScrollView addSubview:balanceContentView];
    
    [balanceContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(100);
    }];
    
    
    UILabel *balanceTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"账户余额"
                                                      font:JCHFont(15)
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentLeft];
    [balanceContentView addSubview:balanceTitleLabel];
    
    CGSize fitSize = [balanceTitleLabel sizeThatFits:CGSizeZero];
    [balanceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(balanceContentView).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(balanceContentView);
        make.width.mas_equalTo(fitSize.width + 10);
    }];
    
    
    
    _balanceLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"¥100"
                                         font:JCHFont(25)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentRight];
    [balanceContentView addSubview:_balanceLabel];
    fitSize = [_balanceLabel sizeThatFits:CGSizeZero];
    [_balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(balanceContentView).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(balanceContentView.mas_centerY);
        make.height.mas_equalTo(fitSize.height);
        make.left.equalTo(balanceTitleLabel.mas_right).with.offset(kStandardLeftMargin);
    }];
    
    _discountBeforeRechargeLabel = [JCHUIFactory createLabel:CGRectZero
                                                       title:@"可享受98折优惠"
                                                        font:JCHFont(13)
                                                   textColor:JCHColorMainBody
                                                      aligin:NSTextAlignmentRight];
    [balanceContentView addSubview:_discountBeforeRechargeLabel];
    fitSize = [_discountBeforeRechargeLabel sizeThatFits:CGSizeZero];
    
    [_discountBeforeRechargeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(_balanceLabel);
        make.top.equalTo(_balanceLabel.mas_bottom);
        make.height.mas_equalTo(fitSize.height + 5);
    }];
    
    
    
    UIView *amountContentView = [[[UIView alloc] init] autorelease];
    amountContentView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:amountContentView];
    
    [amountContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(balanceContentView.mas_bottom);
        make.left.right.equalTo(balanceContentView);
    }];
    
    CGFloat amountTitleLabelHeight = 40;
    UILabel *amountTitleLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth - 2 * kStandardLeftMargin, amountTitleLabelHeight)
                                                    title:@"选择充值金额"
                                                     font:JCHFont(15)
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentLeft];
    [amountContentView addSubview:amountTitleLabel];
    
    NSArray *amountArray = @[@"¥200.00", @"¥500.00", @"¥1000.00"];
    
    CGFloat buttonWidth = (kScreenWidth - 4 * kStandardLeftMargin) / 3;
    CGFloat buttonHeight = buttonWidth * 13 / 21;
    for (NSInteger i = 0; i < 3; i++) {
        CGRect frame = CGRectMake((kStandardLeftMargin + buttonWidth) * i + kStandardLeftMargin, amountTitleLabelHeight, buttonWidth, buttonHeight);
        UIButton *amountButton = [JCHUIFactory createButton:frame
                                                     target:self
                                                     action:@selector(amountButtonSelect:)
                                                      title:amountArray[i]
                                                 titleColor:JCHColorMainBody
                                            backgroundColor:[UIColor whiteColor]];
        amountButton.layer.cornerRadius = 5;
        amountButton.clipsToBounds = YES;
        amountButton.titleLabel.font = JCHFont(15.0);
        amountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        amountButton.layer.borderColor = JCHColorBorder.CGColor;
        amountButton.layer.borderWidth = kSeparateLineWidth;
        [amountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [amountButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [amountButton setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateSelected];
        [amountContentView addSubview:amountButton];
    }
    _otherAmountTextField = [JCHUIFactory createTextField:CGRectZero
                                              placeHolder:@"其他金额"
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    _otherAmountTextField.backgroundColor = [UIColor whiteColor];
    _otherAmountTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)] autorelease];
    _otherAmountTextField.leftViewMode = UITextFieldViewModeAlways;
    _otherAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
    _otherAmountTextField.layer.borderWidth = kSeparateLineWidth;
    _otherAmountTextField.layer.borderColor = JCHColorBorder.CGColor;
    _otherAmountTextField.layer.cornerRadius = 5;
    _otherAmountTextField.delegate = self;
    _otherAmountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_otherAmountTextField addTarget:self action:@selector(textFieldEditingChaged:) forControlEvents:UIControlEventEditingChanged];
    [amountContentView addSubview:_otherAmountTextField];
    
    [_otherAmountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(amountContentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(amountContentView).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(50);
        make.top.equalTo(amountTitleLabel.mas_bottom).with.offset(buttonHeight + kStandardLeftMargin);
    }];
    
    [amountContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_otherAmountTextField.mas_bottom);
    }];
    
    UILabel *rechargeAmountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                            title:@"充值金额"
                                                             font:JCHFont(15)
                                                        textColor:JCHColorMainBody
                                                           aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:rechargeAmountTitleLabel];
    
    fitSize = [rechargeAmountTitleLabel sizeThatFits:CGSizeZero];
    
    [rechargeAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width + 10);
        make.top.equalTo(amountContentView.mas_bottom).with.offset(20);
        make.height.mas_equalTo(30);
    }];
    
    _rechargeAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"¥0.00"
                                                font:JCHFont(15)
                                           textColor:JCHColorHeaderBackground
                                              aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:_rechargeAmountLabel];
    
    [_rechargeAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rechargeAmountTitleLabel.mas_right);
        make.right.equalTo(balanceContentView).with.offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(rechargeAmountTitleLabel);
    }];
    
    
    _discountAfterRechargeLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                title:@""
                                                 font:JCHFont(13)
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
    _discountAfterRechargeLabel.verticalAlignment = kVerticalAlignmentTop;
    _discountAfterRechargeLabel.numberOfLines = 0;
    [self.backgroundScrollView addSubview:_discountAfterRechargeLabel];
    
    [_discountAfterRechargeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_rechargeAmountLabel.mas_bottom);
        make.height.mas_equalTo(40);
        make.left.equalTo(rechargeAmountTitleLabel);
        make.right.equalTo(balanceContentView).with.offset(kStandardLeftMargin);
    }];
    
    UIButton *rechargeButton = [JCHUIFactory createButton:CGRectZero
                                                   target:self
                                                   action:@selector(handleRecharge)
                                                    title:@"立即充值"
                                               titleColor:[UIColor whiteColor]
                                          backgroundColor:JCHColorHeaderBackground];
    rechargeButton.layer.cornerRadius = 5;
    rechargeButton.clipsToBounds = YES;
    [rechargeButton setBackgroundImage:[UIImage imageWithColor:JCHColorRedButtonHeighlighted] forState:UIControlStateHighlighted];
    [self.backgroundScrollView addSubview:rechargeButton];
    
    [rechargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_otherAmountTextField);
        make.top.equalTo(_discountAfterRechargeLabel.mas_bottom);
        make.height.mas_equalTo(kStandardButtonHeight);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(rechargeButton);
    }];
}

- (void)loadData
{
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    _balance = [manifestService queryCardBalance:self.contactRecord.contactUUID];
    _balanceLabel.text = [NSString stringWithFormat:@"¥%.2f", _balance];
    
    id <CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
    NSArray *cardDiscountRecordArray = [cardDiscountService queryAllCardDiscount];
    self.cardDiscountRecordArray = cardDiscountRecordArray;
    
    [self refreshDiscountData:0 afterRecharge:NO];
}

- (void)amountButtonSelect:(UIButton *)sender
{
    [_otherAmountTextField endEditing:YES];
    _otherAmountTextField.text = @"";
    _rechargeAmountLabel.text = [NSString stringWithFormat:@"%@", sender.currentTitle];
    sender.selected = YES;
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    
    CGFloat amount = [[sender.currentTitle stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
    [self refreshDiscountData:amount afterRecharge:YES];
}

#pragma mark - 充值
- (void)handleRecharge
{
    NSString *amountString = [_rechargeAmountLabel.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    CGFloat amount = [amountString doubleValue];

    CardDiscountRecord4Cocoa *firstRecord = [self.cardDiscountRecordArray firstObject];
    
    //当折扣规则为统一折扣时，充值金额不得低于充值下限，阶梯折扣暂不限制充值下限
    if (amount < firstRecord.amountLower && self.cardDiscountRecordArray.count == 1) {
        NSString *message = [NSString stringWithFormat:@"最低充值金额为%.2f，请重新输入", firstRecord.amountLower];
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    CardDiscountRecord4Cocoa *lastRecord = [self.cardDiscountRecordArray lastObject];
    if (amount >= lastRecord.amountUpper) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"充值金额过大，请重新输入"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    
    JCHManifestMemoryStorage *manifestStorage = [JCHManifestMemoryStorage sharedInstance];
    [manifestStorage clearData];
    
    manifestStorage.currentManifestType = kJCHManifestCardRecharge;
    manifestStorage.currentContactsRecord = self.contactRecord;
    manifestStorage.currentManifestDate = dateString;
    manifestStorage.currentManifestID = [manifestService createManifestID:kJCHManifestCardRecharge];
    manifestStorage.savingCardRechargeAmount = amount;
    
    JCHSettleAccountsViewController *settleAccount = [[[JCHSettleAccountsViewController alloc] initWithPayWayShow:YES enabledButtonTags:@[@(kJCHPayWayCachTag), @(kJCHPayWayWeChatTag)]] autorelease];
    [self.navigationController pushViewController:settleAccount animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.selectedButton.selected = NO;
    self.selectedButton = nil;
    
    CGFloat amount = [textField.text doubleValue];
    [self refreshDiscountData:amount afterRecharge:YES];
}

- (void)textFieldEditingChaged:(UITextField *)textField
{
    self.selectedButton.selected = NO;
    self.selectedButton = nil;
    
    CGFloat amount = [textField.text doubleValue];
    [self refreshDiscountData:amount afterRecharge:YES];
}

- (void)refreshDiscountData:(CGFloat)amount afterRecharge:(BOOL)afterRecharge
{
    _rechargeAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", amount];
    
    NSString *text = nil;
    CGFloat discount = 1.0;
    CGFloat totalAmount = amount + _balance;
    if (afterRecharge) {
        CardDiscountRecord4Cocoa *cardDiscountRecord = nil;
        if (self.cardDiscountRecordArray.count == 1) {
            cardDiscountRecord = [self.cardDiscountRecordArray firstObject];
        } else {
            for (CardDiscountRecord4Cocoa *record in self.cardDiscountRecordArray) {
                if (totalAmount >= record.amountLower && totalAmount < record.amountUpper) {
                    cardDiscountRecord = record;
                    break;
                }
            }
        }
        text = @"充值后账户余额调整为";
        if (cardDiscountRecord) {
            discount = cardDiscountRecord.discount;
        }
    } else {
        text = @"当前账户余额为";
        discount = self.contactRecord.cardDiscount;
    }
   
    NSString *info = @"";
    NSString *discountString = nil;
    if (discount == 1 || discount == 0) {
        discountString = @"不享受折扣优惠";
    } else {
        discountString = [JCHTransactionUtility getOrderDiscountFromFloat:discount];
        discountString = [NSString stringWithFormat:@"可享受%@优惠", discountString];
    }
    info = [NSString stringWithFormat:@"%@ ¥%.2f，%@", text, totalAmount, discountString];
    _discountAfterRechargeLabel.text = info;
    
    
    if (!afterRecharge) {
        _discountBeforeRechargeLabel.text = discountString;
    }
}

@end
