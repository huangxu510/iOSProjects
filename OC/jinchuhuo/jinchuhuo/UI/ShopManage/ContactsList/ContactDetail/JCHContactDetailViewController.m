//
//  JCHContactDetailViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHContactDetailViewController.h"
#import "JCHAddContactsViewController.h"
#import "JCHRechargeSavingCardViewController.h"
#import "CommonHeader.h"

#import "ServiceFactory.h"

#import <Masonry.h>

@interface JCHContactDetailViewController ()

@property (nonatomic, retain) NSString *contactUUID;
@property (nonatomic, retain) ContactsRecord4Cocoa *contactRecord;

@end

@implementation JCHContactDetailViewController
{
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    UIView *_headImageBottomLine;
    JCHArrowTapView *_savingCardView;
    JCHTitleDetailLabel *_phoneNumberLabel;
    JCHTitleDetailLabel *_clientRelationLabel;
    JCHTitleDetailLabel *_genderLabel;
    JCHTitleDetailLabel *_birthdayLabel;
    JCHTitleDetailLabel *_relationLabel;
    JCHTitleDetailLabel *_companyNameLabel;
    JCHTitleDetailLabel *_companyAddressLabel;
    JCHTitleDetailLabel *_addressLabel;
    UIButton *_sendMessageButton;
    UIButton *_callUpButton;

    UILabel *_remarkLabel;
    UIButton *_deleteButton;
}

- (instancetype)initWithContactUUID:(NSString *)contactUUID
{
    self = [super init];
    if (self) {
        self.contactUUID = contactUUID;
    }
    return self;
}

- (void)dealloc
{
    self.contactUUID = nil;
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
    self.backgroundScrollView.backgroundColor = JCHColorGlobalBackground;
    
#if 1
    UIButton *editButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                               target:self
                                               action:@selector(handleEditContact)
                                                title:@"编辑"
                                           titleColor:nil
                                      backgroundColor:nil];
    [editButton setTitle:@"取消" forState:UIControlStateSelected];
    editButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:editButton] autorelease];
    
    UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    flexSpacer.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[flexSpacer, editButtonItem];
    
    CGFloat headImageViewWidth = 65.0f;
    
    UIView *topContentView = [[[UIView alloc] init] autorelease];
    topContentView.backgroundColor = [UIColor whiteColor];
    [topContentView addSeparateLineWithMasonryTop:YES bottom:NO];
    [self.backgroundScrollView addSubview:topContentView];
    [topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(headImageViewWidth + 2 * kStandardLeftMargin);
    }];
    
    _headImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homepage_avatar_default"]] autorelease];
    _headImageView.layer.cornerRadius = headImageViewWidth / 2;
    _headImageView.clipsToBounds = YES;
    [topContentView addSubview:_headImageView];
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topContentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(topContentView).with.offset(kStandardLeftMargin);
        make.width.and.height.mas_equalTo(headImageViewWidth);
    }];
    
    _nameLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"张小姐"
                                      font:[UIFont systemFontOfSize:17.0f]
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [topContentView addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(80);
        make.bottom.equalTo(_headImageView.mas_centerY);
        make.height.mas_equalTo(headImageViewWidth / 3);
    }];
    
    
    _sendMessageButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(handleSendMessage)
                                              title:@"发送短信"
                                         titleColor:JCHColorMainBody
                                    backgroundColor:nil];
    _sendMessageButton.titleLabel.font = JCHFont(13);
    _sendMessageButton.titleLabel.textColor = JCHColorAuxiliary;
    [_sendMessageButton setImage:[UIImage imageNamed:@"icon_maillist_contact_message"] forState:UIControlStateNormal];
    [topContentView addSubview:_sendMessageButton];
    
    [_sendMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(90);
        make.top.equalTo(_nameLabel.mas_bottom);
    }];

    _callUpButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleCallUp)
                                         title:@"拨打电话"
                                    titleColor:JCHColorMainBody
                               backgroundColor:nil];
    //[_callUpButton setImage:[UIImage imageNamed:@"contact_phone"] forState:UIControlStateNormal];
    _callUpButton.titleLabel.font = JCHFont(13);
    _callUpButton.titleLabel.textColor = JCHColorAuxiliary;
    [_callUpButton setImage:[UIImage imageNamed:@"icon_maillist_contact_phone"] forState:UIControlStateNormal];
    [topContentView addSubview:_callUpButton];
    
    [_callUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_sendMessageButton.mas_right);
        make.top.and.width.and.height.equalTo(_sendMessageButton);
    }];
    
    {
        UIView *verticalLine = [[[UIView alloc] init] autorelease];
        verticalLine.backgroundColor = JCHColorSeparateLine;
        [topContentView addSubview:verticalLine];
        
        [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_sendMessageButton.mas_right);
            make.centerY.equalTo(_sendMessageButton);
            make.width.mas_equalTo(kSeparateLineWidth);
            make.height.mas_equalTo(15);
        }];
    }

    
    _headImageBottomLine = [[[UIView alloc] init] autorelease];
    _headImageBottomLine.backgroundColor = JCHColorSeparateLine;
    [self.backgroundScrollView addSubview:_headImageBottomLine];
    
    [_headImageBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(kScreenWidth - kStandardLeftMargin);
        make.bottom.equalTo(topContentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _savingCardView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _savingCardView.titleLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    _savingCardView.titleLabel.text = @"0.00";
    _savingCardView.detailLabel.text = @"储值卡充值";
    _savingCardView.detailLabel.textColor = JCHColorAuxiliary;
    [_savingCardView addSeparateLineWithMasonryTop:NO bottom:YES];
    _savingCardView.clipsToBounds = YES;
    [_savingCardView.button addTarget:self action:@selector(rechargeSavingCard) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_savingCardView];
    
    [_savingCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.top.equalTo(_headImageView.mas_bottom).with.offset(kStandardLeftMargin);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(kScreenWidth);
    }];

    _phoneNumberLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"电话号码"
                                                              font:JCHFontStandard
                                                         textColor:JCHColorMainBody
                                                            detail:@""
                                                  bottomLineHidden:YES];
    [_phoneNumberLabel addSeparateLineWithMasonryTop:YES bottom:YES];
    [self.backgroundScrollView addSubview:_phoneNumberLabel];
    
    [_phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_savingCardView.mas_bottom).with.offset(kStandardSeparateViewHeight);
    }];
    
    _relationLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"关系"
                                                           font:JCHFontStandard
                                                      textColor:JCHColorMainBody
                                                         detail:@""
                                               bottomLineHidden:NO];
    [self.backgroundScrollView addSubview:_relationLabel];
    
    [_relationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_phoneNumberLabel.mas_bottom).with.offset(kStandardSeparateViewHeight);
    }];
    
    _genderLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"性别"
                                                         font:JCHFontStandard
                                                    textColor:JCHColorMainBody
                                                       detail:@""
                                             bottomLineHidden:NO];
    [self.backgroundScrollView addSubview:_genderLabel];
    
    [_genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_relationLabel.mas_bottom);
    }];
    
    _birthdayLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"生日"
                                                           font:JCHFontStandard
                                                      textColor:JCHColorMainBody
                                                         detail:@""
                                               bottomLineHidden:YES];
    [self.backgroundScrollView addSubview:_birthdayLabel];
    
    [_birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_genderLabel.mas_bottom);
    }];
    
    
    
    _companyNameLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"公司名称"
                                                              font:JCHFontStandard
                                                         textColor:JCHColorMainBody
                                                            detail:@""
                                                  bottomLineHidden:NO];
    [self.backgroundScrollView addSubview:_companyNameLabel];
    
    [_companyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_birthdayLabel.mas_bottom).with.offset(kStandardSeparateViewHeight);
    }];
    
    _companyAddressLabel = [[JCHTitleDetailLabel alloc] initWithTitle:@"公司地址"
                                                                 font:JCHFontStandard
                                                            textColor:JCHColorMainBody
                                                               detail:@""
                                                     bottomLineHidden:YES];
    [self.backgroundScrollView addSubview:_companyAddressLabel];
    
    [_companyAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_companyNameLabel.mas_bottom);
    }];
    
    _addressLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"联系地址"
                                                           font:JCHFontStandard
                                                      textColor:JCHColorMainBody
                                                         detail:@"" bottomLineHidden:YES] autorelease];
    _companyAddressLabel.bottomLine.hidden = NO;
    _addressLabel.detailLabel.numberOfLines = 0;
    _addressLabel.detailLabel.adjustsFontSizeToFitWidth = YES;
    [self.backgroundScrollView addSubview:_addressLabel];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(_companyAddressLabel.mas_bottom);
    }];
    

    _remarkLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:[UIFont systemFontOfSize:15.0f]
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    _remarkLabel.backgroundColor = [UIColor whiteColor];
    [self.backgroundScrollView addSubview:_remarkLabel];
    _remarkLabel.numberOfLines = 0;
    //_remarkLabel.verticalAlignment = kVerticalAlignmentTop;
    _remarkLabel.clipsToBounds = YES;
    CGFloat minRemarkLabelHeight = 80.0f;
    
    [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_addressLabel.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(minRemarkLabelHeight);
    }];

    {
        UIView *topLine = [[[UIView alloc] init] autorelease];
        topLine.backgroundColor = JCHColorSeparateLine;
        [_remarkLabel addSubview:topLine];
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(_remarkLabel);
            make.top.equalTo(_remarkLabel.mas_top);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        UIView *bottomLine = [[[UIView alloc] init] autorelease];
        bottomLine.backgroundColor = JCHColorSeparateLine;
        [_remarkLabel addSubview:bottomLine];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.and.right.equalTo(_remarkLabel);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }

    _deleteButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(deleteContact)
                                         title:@"删除"
                                    titleColor:JCHColorMainBody
                               backgroundColor:[UIColor whiteColor]];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.backgroundScrollView addSubview:_deleteButton];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_remarkLabel.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(kStandardButtonHeight);
    }];


    [_deleteButton addSeparateLineWithMasonryTop:NO bottom:YES];
    {
    
    }
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_deleteButton).with.offset(kStandardSeparateViewHeight);
    }];

    {
        UIView *separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.backgroundScrollView addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_savingCardView);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.top.equalTo(_relationLabel.mas_top);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.backgroundScrollView addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_savingCardView);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.bottom.equalTo(_birthdayLabel.mas_bottom);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.backgroundScrollView addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_savingCardView);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.top.equalTo(_companyNameLabel.mas_top);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [self.backgroundScrollView addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_savingCardView);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.bottom.equalTo(_addressLabel.mas_bottom);
        }];
        
        separateLine = [[[UIView alloc] init] autorelease];
        separateLine.backgroundColor = JCHColorSeparateLine;
        [_deleteButton addSubview:separateLine];
        
        [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_savingCardView);
            make.height.mas_equalTo(kSeparateLineWidth);
            make.bottom.equalTo(_deleteButton.mas_top);
        }];
    }

#endif
}

- (void)loadData
{
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    ContactsRecord4Cocoa *contactsRecord = [contactsService queryContacts:self.contactUUID];
    self.contactRecord = contactsRecord;
    
    id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
    CGFloat balance = [manifestService queryCardBalance:contactsRecord.contactUUID];
    _savingCardView.titleLabel.text = [NSString stringWithFormat:@"¥ %.2f", balance];
    
    _nameLabel.text = contactsRecord.name;
    
    CGSize size = [_nameLabel sizeThatFits:CGSizeZero];
    [_nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    
    self.title = contactsRecord.name;
    NSString *gender = @"";
    if (contactsRecord.gender == 1) {
        gender = @"女 ";
    } else if (contactsRecord.gender == 0){
        gender = @"男 ";
    }
    
    _headImageView.image = [UIImage imageWithColor:nil
                                              size:_headImageView.frame.size
                                              text:contactsRecord.name
                                              font:[UIFont jchSystemFontOfSize:27.0f]];
    
    NSTimeInterval birthdayTime = contactsRecord.birthday;
    NSString *birthdayString = @"";
    
    // birthdayTime为0不显示生日    ***之前保存联系人时，未填生日默认给INT_MAX，所以在此要判断一下***
    if (birthdayTime != INT_MAX && birthdayTime != 0) {
        birthdayString = [NSString stringFromSeconds:birthdayTime dateStringType:kJCHDateStringType1];
    }

    NSMutableString *relationStr = [NSMutableString string];
    for (NSString *relation in contactsRecord.relationshipVector) {
        if (relation == [contactsRecord.relationshipVector firstObject]) {
            [relationStr appendString:relation];
        } else {
            [relationStr appendString:[NSString stringWithFormat:@"/%@", relation]];
        }
    }
    
    if (![contactsRecord.relationshipVector containsObject:@"客户"]) {
        [_savingCardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [_headImageBottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
        }];
    } else {
        [_savingCardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(50);
        }];
        [_headImageBottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(_headImageView);
        }];
    }
    
    _phoneNumberLabel.detailLabel.text = contactsRecord.phone;
    _relationLabel.detailLabel.text = relationStr;
    _genderLabel.detailLabel.text = gender;
    
    if ([gender isEmptyString]) {
        [_genderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        [_genderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    _birthdayLabel.detailLabel.text = birthdayString;
    if ([birthdayString isEmptyString]) {
        [_birthdayLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        [_birthdayLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    _companyNameLabel.detailLabel.text = contactsRecord.company;
    if ([contactsRecord.company isEmptyString]) {
        [_companyNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        [_companyNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    _companyAddressLabel.detailLabel.text = contactsRecord.companyAddr;
    if ([contactsRecord.companyAddr isEmptyString]) {
        [_companyAddressLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        [_companyAddressLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    _addressLabel.detailLabel.text = contactsRecord.address;
    if ([contactsRecord.address isEmptyString]) {
        [_addressLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        [_addressLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }

    if ([contactsRecord.company isEmptyString] && [contactsRecord.companyAddr isEmptyString] && [contactsRecord.address isEmptyString]) {
        [_remarkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addressLabel.mas_bottom);
        }];
    } else {
        [_remarkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addressLabel.mas_bottom).with.offset(kStandardSeparateViewHeight);
        }];
    }

    if ([contactsRecord.memo isEmptyString]) {
        [_remarkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    
        [_deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_remarkLabel.mas_bottom);
        }];
        [self.backgroundScrollView bringSubviewToFront:_deleteButton];
    } else {
        [self setRemark:contactsRecord.memo];
    }
}

- (void)deleteContact
{
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    
    WeakSelf;
    
    if ([contactsService isContactsCanBeDeleted:self.contactUUID]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                 message:@"确定删除该联系人?"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf makeSureDeleteContact];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:alertAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        CGFloat balance = [manifestService queryCardBalance:self.contactUUID];
        NSString *message = nil;
        if (balance > 0) {
            message = @"该联系人储值卡有余额，不能删除";
        } else {
            message = @"该联系人已被货单使用，不能删除";
        }
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles: nil] autorelease];
        [alertView show];
        return;
    }
}

- (void)makeSureDeleteContact
{
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    [contactsService deleteAccount:self.contactUUID];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - 拨打电话
- (void)handleCallUp
{
    if ([self.contactRecord.phone isEmptyString]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请先填写联系人电话"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    NSString * str = [NSString stringWithFormat:@"telprompt://%@",_phoneNumberLabel.detailLabel.text];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

#pragma mark - 发送短信
- (void)handleSendMessage
{
    if ([self.contactRecord.phone isEmptyString]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请先填写联系人电话"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    NSString * str = [NSString stringWithFormat:@"sms://%@",_phoneNumberLabel.detailLabel.text];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

- (void)handleEditContact
{
    JCHAddContactsViewController *addContactsViewController = [[[JCHAddContactsViewController alloc] initWithContactsUUID:self.contactUUID relationship:nil] autorelease];
    [self.navigationController pushViewController:addContactsViewController animated:YES];
}

- (void)setRemark:(NSString *)text
{
    CGFloat remarkLabelMinHeight = 80.0f;
    NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.maximumLineHeight = 60;  //最大的行高
    paragraphStyle.lineSpacing = 5;         //行间距
    paragraphStyle.headIndent = 14;
    paragraphStyle.tailIndent = -14;
    paragraphStyle.firstLineHeadIndent = 14;
    //paragraphStyle.paragraphSpacingBefore = 20;
    //paragraphStyle.paragraphSpacing = 50;
    //paragraphStyle.tailIndent = 14;
    //[paragraphStyle setFirstLineHeadIndent:44];//首行缩进
    //[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    [attributedString addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : _remarkLabel.font} range:NSMakeRange(0, text.length)];
    _remarkLabel.attributedText = attributedString;
    CGRect resultFrame = [attributedString boundingRectWithSize:CGSizeMake(kScreenWidth - 4 * kStandardLeftMargin, 1000)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                        context:nil];
    CGFloat height = MAX(remarkLabelMinHeight, resultFrame.size.height);
    [_remarkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [_deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_remarkLabel.mas_bottom).with.offset(kStandardSeparateViewHeight);
    }];
}

#pragma mark - 充值卡充值
- (void)rechargeSavingCard
{
    id <CardDiscountService> cardDiscountService = [[ServiceFactory sharedInstance] cardDiscountService];
    NSArray *cardDiscountRecordArray = [cardDiscountService queryAllCardDiscount];
    if (cardDiscountRecordArray.count == 0) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"储值卡充值前必须由店主设置储值卡折扣规则"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if ([self.contactRecord.phone isEmptyString]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请先填写联系人电话"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    JCHRechargeSavingCardViewController *rechargeViewController = [[[JCHRechargeSavingCardViewController alloc] initWithContanctRecord:self.contactRecord] autorelease];
    [self.navigationController pushViewController:rechargeViewController animated:YES];
}


@end
