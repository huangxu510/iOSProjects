//
//  JCHSavingCardTransactionDetailViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardTransactionDetailViewController.h"
#import "CommonHeader.h"

@interface JCHSavingCardTransactionDetailViewController ()
{
    JCHTitleDetailLabel *_amountLabel;
    JCHTitleDetailLabel *_transactionTypeLabel;
    JCHTitleDetailLabel *_memberLabel;
    JCHTitleDetailLabel *_operatorLabel;
    JCHTitleDetailLabel *_payWayLabel;
    JCHTitleDetailLabel *_dateLabel;
}
@property (nonatomic, retain) CardRechargeRecord4Cocoa *cardRechargeRecord;
@end

@implementation JCHSavingCardTransactionDetailViewController

- (instancetype)initWithCardRechargeRecord:(CardRechargeRecord4Cocoa *)record
{
    self = [super init];
    if (self) {
        
        self.cardRechargeRecord = record;
        if (record.manifestType == kJCHManifestCardRecharge) {
            self.title = @"充值明细";
        } else if (record.manifestType == kJCHManifestCardRefund){
            self.title = @"退卡";
        } else if (record.manifestType == kJCHOrderShipment) { //出货单
            self.title = @"消费明细";
        } else if (record.manifestType == kJCHOrderShipmentReject) { //出货退单
            self.title = @"退单明细";
        } else {
            //pass
        }
    }
    return self;
}

- (void)dealloc
{
    self.cardRechargeRecord = nil;
    
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
    CGFloat topItemHeight = 84.0f;
    CGFloat bottomItemHeigt = 36.0f;
    
    _amountLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"出账金额"
                                                          font:JCHFont(15)
                                                     textColor:JCHColorAuxiliary
                                                        detail:@""
                                              bottomLineHidden:NO] autorelease];
    _amountLabel.detailLabel.font = JCHFont(24.0f);
    _amountLabel.detailLabel.textColor = JCHColorMainBody;
    [self.view addSubview:_amountLabel];
    
    [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(topItemHeight);
    }];
    
    _transactionTypeLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"类型"
                                                                   font:JCHFont(15)
                                                              textColor:JCHColorAuxiliary
                                                                 detail:@""
                                                       bottomLineHidden:YES] autorelease];
    [self.view addSubview:_transactionTypeLabel];
    
    [_transactionTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_amountLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _memberLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"会员"
                                                          font:JCHFont(15)
                                                     textColor:JCHColorAuxiliary
                                                        detail:@""
                                              bottomLineHidden:YES] autorelease];
    [self.view addSubview:_memberLabel];
    
    [_memberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_transactionTypeLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _operatorLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"操作人"
                                                            font:JCHFont(15)
                                                       textColor:JCHColorAuxiliary
                                                          detail:@""
                                                bottomLineHidden:YES] autorelease];
    [self.view addSubview:_operatorLabel];
    
    [_operatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_memberLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _payWayLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"支付方式"
                                                          font:JCHFont(15)
                                                     textColor:JCHColorAuxiliary
                                                        detail:@""
                                              bottomLineHidden:YES] autorelease];
    [self.view addSubview:_payWayLabel];
    
    [_payWayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_operatorLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _dateLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"时间"
                                                        font:JCHFont(15)
                                                   textColor:JCHColorAuxiliary
                                                      detail:@""
                                            bottomLineHidden:YES] autorelease];
    [self.view addSubview:_dateLabel];
    
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_payWayLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
}

- (void)loadData
{
    if (self.cardRechargeRecord.manifestType == kJCHManifestCardRecharge ||
        self.cardRechargeRecord.manifestType == kJCHOrderShipmentReject) { //充值单 或 出货退单
        
        _amountLabel.detailLabel.text = [NSString stringWithFormat:@"+ ¥%.2f",  self.cardRechargeRecord.amount];
        _amountLabel.detailLabel.textColor = JCHColorHeaderBackground;
    } else {
        _amountLabel.detailLabel.text = [NSString stringWithFormat:@"- ¥%.2f", self.cardRechargeRecord.amount];
        _amountLabel.detailLabel.textColor = JCHColorMainBody;
    }
    
    if (self.cardRechargeRecord.manifestType == kJCHManifestCardRecharge) {
        _transactionTypeLabel.detailLabel.text = @"充值";
    } else if (self.cardRechargeRecord.manifestType == kJCHManifestCardRefund){
        _transactionTypeLabel.detailLabel.text = @"退卡";
    } else if (self.cardRechargeRecord.manifestType == kJCHOrderShipment) { //出货单
        _transactionTypeLabel.detailLabel.text = @"消费";
    } else if (self.cardRechargeRecord.manifestType == kJCHOrderShipmentReject) { //出货退单
        _transactionTypeLabel.detailLabel.text = @"退单";
    }
    
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactRecord = [contactsService queryContacts:self.cardRechargeRecord.customUUID];
    _memberLabel.detailLabel.text = [NSString stringWithFormat:@"%@/%@", contactRecord.name, contactRecord.phone];
    _operatorLabel.detailLabel.text = self.cardRechargeRecord.operatorName;
    _payWayLabel.detailLabel.text = self.cardRechargeRecord.paymentMethod;
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.cardRechargeRecord.manifestTimestamp];
    _dateLabel.detailLabel.text = [dateFormatter stringFromDate:date];
}
@end
