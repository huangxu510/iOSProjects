//
//  JCHSavingCardTransactionDetailViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHJournalAccountDetailViewController.h"
#import "CommonHeader.h"

@interface JCHJournalAccountDetailViewController ()
{
    JCHTitleDetailLabel *_amountLabel;
    JCHTitleDetailLabel *_transactionTypeLabel;
    JCHTitleDetailLabel *_tradeInfoLabel;
    JCHTitleDetailLabel *_operatorLabel;
    JCHTitleDetailLabel *_dateLabel;
    JCHTextView *_remarkTextView;
}
@property (nonatomic, retain) AccountTransactionRecord4Cocoa *accountTransactionRecord;

@end

@implementation JCHJournalAccountDetailViewController

- (instancetype)initWithAccountTransactionRecord:(AccountTransactionRecord4Cocoa *)record
{
    self = [super init];
    if (self) {
        
        self.title = @"现金明细";
        self.accountTransactionRecord = record;
    }
    return self;
}

- (void)dealloc
{
    self.accountTransactionRecord = nil;
    
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
    
    _amountLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"金额"
                                                          font:JCHFont(15)
                                                     textColor:JCHColorMainBody
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
                                                              textColor:JCHColorMainBody
                                                                 detail:@""
                                                       bottomLineHidden:YES] autorelease];
    [self.view addSubview:_transactionTypeLabel];
    
    [_transactionTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_amountLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _tradeInfoLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"交易方"
                                                          font:JCHFont(15)
                                                     textColor:JCHColorMainBody
                                                        detail:@""
                                              bottomLineHidden:YES] autorelease];
    [self.view addSubview:_tradeInfoLabel];
    
    [_tradeInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_transactionTypeLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _operatorLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"操作人"
                                                            font:JCHFont(15)
                                                       textColor:JCHColorMainBody
                                                          detail:@""
                                                bottomLineHidden:YES] autorelease];
    [self.view addSubview:_operatorLabel];
    
    [_operatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_tradeInfoLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    
    _dateLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"时间"
                                                        font:JCHFont(15)
                                                   textColor:JCHColorMainBody
                                                      detail:@""
                                            bottomLineHidden:YES] autorelease];
    [self.view addSubview:_dateLabel];
    
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_operatorLabel.mas_bottom);
        make.height.mas_equalTo(bottomItemHeigt);
    }];
    
    _remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectZero] autorelease];
    _remarkTextView.isAutoHeight = YES;
    _remarkTextView.minHeight = kStandardItemHeight;
    _remarkTextView.editable = NO;
    [self.view addSubview:_remarkTextView];
    
    [_remarkTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dateLabel.mas_bottom).offset(kStandardSeparateViewHeight);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
}

- (void)loadData
{
    if (self.accountTransactionRecord.amount >= 0) {
        _amountLabel.detailLabel.text = [NSString stringWithFormat:@"¥%.2f", self.accountTransactionRecord.amount];
        _amountLabel.detailLabel.textColor = JCHColorHeaderBackground;
    } else {
        _amountLabel.detailLabel.text = [NSString stringWithFormat:@"-¥%.2f", fabs(self.accountTransactionRecord.amount)];
        _amountLabel.detailLabel.textColor = JCHColorMainBody;
    }
    
    _transactionTypeLabel.detailLabel.text = self.accountTransactionRecord.recordDescription;
    id<ContactsService> contactService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactRecord = [contactService queryContacts:self.accountTransactionRecord.counterPartyUUID];
    
    
    if (contactRecord.phone && ![contactRecord.phone isEmptyString]) {
        _tradeInfoLabel.detailLabel.text = [NSString stringWithFormat:@"%@/%@", contactRecord.name, contactRecord.phone];
    } else {
        _tradeInfoLabel.detailLabel.text = contactRecord.name;
    }
    
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:[NSString stringWithFormat:@"%ld", self.accountTransactionRecord.operatorID]];
    _operatorLabel.detailLabel.text = [JCHDisplayNameUtility getDisplayNickName:bookMemberRecord];;
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.accountTransactionRecord.transTime];
    _dateLabel.detailLabel.text = [dateFormatter stringFromDate:date];
    
    if (self.accountTransactionRecord.remark && ![self.accountTransactionRecord.remark isEmptyString]) {
        _remarkTextView.text = self.accountTransactionRecord.remark;
        _remarkTextView.hidden = NO;
    } else {
        _remarkTextView.hidden = YES;
    }
    
    if (self.accountTransactionRecord.manifestType == kJCHManifestExtraIncome || self.accountTransactionRecord.manifestType == kJCHManifestExtraExpenses) {
        _tradeInfoLabel.hidden = YES;
        [_operatorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_transactionTypeLabel.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(_transactionTypeLabel);
        }];
    }
}
@end
