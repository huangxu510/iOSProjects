//
//  JCHAddContactsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddContactsViewController.h"
#import "JCHContactsRelationSelectViewController.h"
#import "JCHArrowTapView.h"
#import "CommonHeader.h"
#import "JCHPickerView.h"
#import "JCHDatePickerView.h"
#import "ServiceFactory.h"
#import "ContactsService.h"
#import <Masonry.h>

enum
{
    kJCHPickerViewTagSex = 1,
    kJCHPickerViewTagIndustry,
};

@interface JCHAddContactsViewController () <UITextViewDelegate,
                                            JCHPickerViewDelegate,
                                            UIPickerViewDataSource,
                                            UIPickerViewDelegate,
                                            JCHDatePickerViewDelegate>
{
    //UIScrollView *self.backgroundScrollView;
    UIImageView *_headImageView;
    JCHTitleTextField *_nameTitleTextField;
    JCHTitleTextField *_phoneNumberTitleTextField;
    JCHArrowTapView *_relationTapView;
    JCHArrowTapView *_genderTapView;
    JCHArrowTapView *_birthdayTapView;
    JCHArrowTapView *_industryTapView;
    JCHTitleTextField *_companyNameTitleTextField;
    JCHTitleTextField *_companyAddressTitleTextField;
    JCHTitleTextField *_addressTitleTextField;
    JCHTextView *_remarkTextView;
    JCHPickerView *_pickerView;
    JCHDatePickerView *_datePickerView;
    NSTimeInterval _birthdayTime;
    
    BOOL _isNeedLoadCurrentRelationship;
    JCHArrowTapView *_currentEditView;
}

@property (nonatomic, retain) NSArray *pickerViewDataSource;
@property (nonatomic, retain) NSArray *availableRelationship;
@property (nonatomic, retain) NSString *contactUUID;

//保存新建指定关系的联系人的关系
@property (nonatomic, retain) NSString *relationship;

@end

@implementation JCHAddContactsViewController

- (instancetype)initWithContactsUUID:(NSString *)contactsUUID
                        relationship:(NSString *)relationship
{
    self = [super init];
    if (self) {
        self.contactUUID = contactsUUID;
        self.title = @"编辑联系人";
        _birthdayTime = 0;
        _isNeedLoadCurrentRelationship = YES;
        self.relationship = relationship;
    }
    return self;
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

- (void)dealloc
{
    [self.pickerViewDataSource release];
    [self.availableRelationship release];
    [self.currentRelationship release];
    [self.contactUUID release];
    [self.relationship release];
    
    [super dealloc];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    CGFloat headImageViewWidth = 65.0f;
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0f];
    
    UIButton *editButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                               target:self
                                               action:@selector(handleSaveRecord)
                                                title:@"保存"
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

    UIView *topContentView = [[[UIView alloc] init] autorelease];
    topContentView.backgroundColor = [UIColor whiteColor];
    
    [self.backgroundScrollView addSubview:topContentView];
    
    [topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(2 * kStandardItemHeight);
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
    
    _nameTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"联系人"
                                                               font:textFont
                                                        placeholder:@"请输入姓名"
                                                          textColor:JCHColorMainBody] autorelease];
    _nameTitleTextField.bottomLine.hidden = NO;
    [topContentView addSubview:_nameTitleTextField];
    
    [_nameTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right);
        make.width.mas_equalTo(kScreenWidth - headImageViewWidth - kStandardLeftMargin);
        make.top.equalTo(topContentView);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    [topContentView addSeparateLineWithMasonryTop:YES bottom:NO];
    _phoneNumberTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"电话"
                                                                      font:textFont
                                                               placeholder:@"请输入电话"
                                                                 textColor:JCHColorMainBody] autorelease];
    _phoneNumberTitleTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    [topContentView addSubview:_phoneNumberTitleTextField];
    _phoneNumberTitleTextField.bottomLine.hidden = YES;
    [_phoneNumberTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(_nameTitleTextField);
        make.top.equalTo(_nameTitleTextField.mas_bottom);
    }];
    
    _relationTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _relationTapView.titleLabel.text = @"关系";
    [_relationTapView.button addTarget:self action:@selector(selectRelationship) forControlEvents:UIControlEventTouchUpInside];
    _relationTapView.bottomLine.hidden = NO;
    [self.backgroundScrollView addSubview:_relationTapView];
    
    [_relationTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_phoneNumberTitleTextField.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _genderTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _genderTapView.titleLabel.text = @"性别";
    [_genderTapView.button addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    _genderTapView.bottomLine.hidden = NO;
    [self.backgroundScrollView addSubview:_genderTapView];
    
    [_genderTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(_relationTapView);
        make.top.equalTo(_relationTapView.mas_bottom);
    }];
    
    _birthdayTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _birthdayTapView.titleLabel.text = @"生日";
    [_birthdayTapView.button addTarget:self action:@selector(showDatePickerView) forControlEvents:UIControlEventTouchUpInside];
    _birthdayTapView.bottomLine.hidden = YES;
    [self.backgroundScrollView addSubview:_birthdayTapView];
    
    [_birthdayTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(_relationTapView);
        make.top.equalTo(_genderTapView.mas_bottom);
    }];
    
#if 0
    _industryTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    _industryTapView.titleLabel.text = @"所属行业";
    [_industryTapView.button addTarget:self action:@selector(showPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_industryTapView];
    
    [_industryTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.and.height.equalTo(_relationTapView);
        make.top.equalTo(_birthdayTapView.mas_bottom);
    }];
#endif
    _companyNameTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"公司名称"
                                                                      font:textFont
                                                               placeholder:@"请输入公司名称"
                                                                 textColor:JCHColorMainBody] autorelease];
    _companyNameTitleTextField.bottomLine.hidden = NO;
    [self.backgroundScrollView addSubview:_companyNameTitleTextField];
    
    [_companyNameTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_birthdayTapView.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.left.and.width.and.height.equalTo(_relationTapView);
    }];
    
    _companyAddressTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"公司地址"
                                                                       font:textFont
                                                                placeholder:@"请输入公司地址"
                                                                  textColor:JCHColorMainBody] autorelease];
    _companyAddressTitleTextField.bottomLine.hidden = YES;
    [self.backgroundScrollView addSubview:_companyAddressTitleTextField];
    
    [_companyAddressTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_companyNameTitleTextField.mas_bottom);
        make.left.and.width.and.height.equalTo(_relationTapView);
    }];
    
#if MMR_TAKEOUT_VERSION
    _addressTitleTextField = [[[JCHTitleTextField alloc] initWithTitle:@"联系地址"
                                                                  font:textFont
                                                           placeholder:@"请输入地址"
                                                             textColor:JCHColorMainBody] autorelease];
    _companyAddressTitleTextField.bottomLine.hidden = NO;
    _addressTitleTextField.bottomLine.hidden = YES;
    [self.backgroundScrollView addSubview:_addressTitleTextField];
    
    [_addressTitleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_companyAddressTitleTextField.mas_bottom);
        make.left.width.height.equalTo(_relationTapView);
    }];
#endif
    
    
    CGFloat remarkTextViewMinHeight = 80.0f;
    _remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, remarkTextViewMinHeight)] autorelease];
    [self.backgroundScrollView addSubview:_remarkTextView];
    
    _remarkTextView.delegate = self;
    _remarkTextView.textColor = JCHColorMainBody;
    _remarkTextView.font = textFont;
    _remarkTextView.placeholder = @"添加备注信息";
    _remarkTextView.placeholderColor = UIColorFromRGB(0xd5d5d5);
    _remarkTextView.isAutoHeight = YES;
    _remarkTextView.minHeight = remarkTextViewMinHeight;
    
    [_remarkTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView.mas_left);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(remarkTextViewMinHeight);
#if MMR_TAKEOUT_VERSION
        make.top.equalTo(_addressTitleTextField.mas_bottom).with.offset(kStandardSeparateViewHeight);
#else
        make.top.equalTo(_companyAddressTitleTextField.mas_bottom).with.offset(kStandardSeparateViewHeight);
#endif
    }];

    UIView *separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    [separateView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_phoneNumberTitleTextField.mas_bottom);
        make.height.mas_equalTo(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    [separateView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_birthdayTapView.mas_bottom);
        make.height.mas_equalTo(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    [separateView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
#if MMR_TAKEOUT_VERSION
        make.top.equalTo(_addressTitleTextField.mas_bottom);
#else
        make.top.equalTo(_companyAddressTitleTextField.mas_bottom);
#endif
        
        make.height.mas_equalTo(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    separateView = [[[UIView alloc] init] autorelease];
    separateView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView addSubview:separateView];
    [separateView addSeparateLineWithMasonryTop:YES bottom:YES];
    
    [separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_remarkTextView.mas_bottom);
        make.height.mas_equalTo(kScreenHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_remarkTextView.mas_bottom).with.offset(kStandardSeparateViewHeight);
    }];
    
    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"类别" showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
}

#pragma mark - LoadData
- (void)loadData
{
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    self.availableRelationship = [contactsService getAvailableRelationship];
    
    //修改联系人
    if (self.contactUUID) {
        ContactsRecord4Cocoa *contactsRecord = [contactsService queryContacts:self.contactUUID];
        _nameTitleTextField.textField.text = contactsRecord.name;
        _phoneNumberTitleTextField.textField.text = contactsRecord.phone;
        
        if (_isNeedLoadCurrentRelationship) {
            self.currentRelationship = contactsRecord.relationshipVector;
        }
        
        
        if (self.currentRelationship.count > 0) {
            
            NSMutableString *relationshipString = [NSMutableString stringWithString:self.currentRelationship[0]];
            for (NSString *relationship in self.currentRelationship) {
                if (![relationshipString isEqualToString:relationship]) {
                    [relationshipString appendString:[NSString stringWithFormat:@"/%@", relationship]];
                }
            }
            _relationTapView.detailLabel.text = relationshipString;
        }
        
        _headImageView.image = [UIImage imageWithColor:nil
                                                  size:_headImageView.frame.size
                                                  text:contactsRecord.name
                                                  font:[UIFont jchSystemFontOfSize:27.0f]];
        
        NSString *gender = @"";
        if (contactsRecord.gender == 1) {
            gender = @"女 ";
        } else if (contactsRecord.gender == 0){
            gender = @"男 ";
        }
        _genderTapView.detailLabel.text = gender;
        
        NSTimeInterval birthdayTime = contactsRecord.birthday;
        NSString *birthdayString = @"";
        if (birthdayTime != 0) {
            birthdayString = [NSString stringFromSeconds:birthdayTime dateStringType:kJCHDateStringType1];
            _birthdayTime = contactsRecord.birthday;
        }
        
        _birthdayTapView.detailLabel.text = birthdayString;
        _companyNameTitleTextField.textField.text = contactsRecord.company;
        _companyAddressTitleTextField.textField.text = contactsRecord.companyAddr;
        _addressTitleTextField.textField.text = contactsRecord.address;
        _remarkTextView.text = contactsRecord.memo;
    } else {
        //新建联系人
        
        //新建指定关系(不可选)的联系人
        if (self.relationship) {
            
            _relationTapView.enable = NO;
            _relationTapView.detailLabel.text = self.relationship;
            self.currentRelationship = @[self.relationship];
        } else {
            
            //新建可选关系的联系人
            if (self.currentRelationship.count > 0) {
                
                NSMutableString *relationshipString = [NSMutableString stringWithString:self.currentRelationship[0]];
                for (NSString *relationship in self.currentRelationship) {
                    if (![relationshipString isEqualToString:relationship]) {
                        [relationshipString appendString:[NSString stringWithFormat:@"/%@", relationship]];
                    }
                }
                _relationTapView.detailLabel.text = relationshipString;
            }
        }
    }
}

#pragma mark - SaveRecord
- (void)handleSaveRecord
{
    [self.view endEditing:YES];
    NSString *message = nil;
    
    if ([_relationTapView.detailLabel.text isEqualToString:@""]) {
        message = @"请选择关系";
    }
    
    if ([_nameTitleTextField.textField.text isEqualToString:@""]) {
        message = @"请输入联系人姓名";
    }
    
    if (message != nil) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
 
#if 0
    NSPredicate *telePre = [NSPredicate predicateWithFormat:@"self matches %@", kTelephoneNumberPredicate];
    NSPredicate *phonePre = [NSPredicate predicateWithFormat:@"self matches %@", kPhoneNumberPredicate];
    
    
    BOOL isPhone = [phonePre evaluateWithObject:_phoneNumberTitleTextField.textField.text];
    BOOL isTelephone = [telePre evaluateWithObject:_phoneNumberTitleTextField.textField.text];

    if(!isTelephone && !isPhone)
    {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"电话格式有误" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
        [av show];
        return;
    }
#endif
    
    
    
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    
    ContactsRecord4Cocoa *contactsRecord = [[[ContactsRecord4Cocoa alloc] init] autorelease];
    
    if (self.contactUUID) {
        if (![contactsRecord.phone isEmptyString] && [_phoneNumberTitleTextField.textField.text isEmptyString]) {
            UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                          message:@"请输入联系人电话"
                                                         delegate:nil
                                                cancelButtonTitle:@"我知道了"
                                                otherButtonTitles:nil] autorelease];
            [av show];
            return;
        }
       
        id<ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        CGFloat balance = [manifestService queryCardBalance:self.contactUUID];
        if (balance > 0 && ![self.currentRelationship containsObject:@"客户"]) {
            UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                          message:@"该联系人储值卡有余额，关系必须包含客户"
                                                         delegate:nil
                                                cancelButtonTitle:@"我知道了"
                                                otherButtonTitles:nil] autorelease];
            [av show];
            return;
        }
        
    }
    
    contactsRecord.contactUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
    //contactsRecord.avatar;             // 头像
    contactsRecord.name = _nameTitleTextField.textField.text;               // 联系人姓名
    contactsRecord.phone = _phoneNumberTitleTextField.textField.text;              // 联系电话
    contactsRecord.relationshipVector = self.currentRelationship; // 关系
    if ([_genderTapView.detailLabel.text isEqualToString:@""] || _genderTapView.detailLabel.text == nil) {
        contactsRecord.gender = 0;
    } else {
        contactsRecord.gender = [_genderTapView.detailLabel.text isEqualToString:@"女"];             // 性别 0:男 1:女
    }
    
    contactsRecord.birthday = _birthdayTime;           // 生日
    contactsRecord.company = _companyNameTitleTextField.textField.text;            // 公司名字
    contactsRecord.companyAddr = _companyAddressTitleTextField.textField.text;        // 公司地址
    contactsRecord.address = _addressTitleTextField.textField.text;
    contactsRecord.memo = _remarkTextView.text;               // 备注
    
    if (self.contactUUID) {  //修改联系人
        contactsRecord.contactUUID = self.contactUUID;
        [contactsService updateAccount:contactsRecord];
    } else {                //新建联系人
        contactsRecord.cardDiscount = 1;
        [contactsService insertAccount:contactsRecord];
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectRelationship
{
    [self.view endEditing:YES];
    JCHContactsRelationSelectViewController *relationSelectVC = [[[JCHContactsRelationSelectViewController alloc] initWithCurrentRelationship:self.currentRelationship] autorelease];
    [self.navigationController pushViewController:relationSelectVC animated:YES];
    _isNeedLoadCurrentRelationship = NO;
}


- (void)showPickerView:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (![_currentEditView.detailLabel.text isEqualToString:@""]) {
        [_pickerView.pickerView selectRow:[self.pickerViewDataSource indexOfObject:_currentEditView.detailLabel.text] inComponent:0 animated:NO];
    } else {
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
    }
    [_pickerView show];
    
    
    if (sender == _genderTapView.button) {
        self.pickerViewDataSource = @[@"男", @"女"];
        _pickerView.tag = kJCHPickerViewTagSex;
        [_pickerView setTitle:@"性别"];
        _currentEditView = _genderTapView;
    } else if (sender == _industryTapView.button) {
        self.pickerViewDataSource = @[@"餐饮", @"电器", @"居家", @"建材", @"服饰", @"食品", @"零售", @"其它"];
        _pickerView.tag = kJCHPickerViewTagIndustry;
        [_pickerView setTitle:@"行业"];
        _currentEditView = _industryTapView;
    }
    [_pickerView.pickerView reloadAllComponents];
}

- (void)showDatePickerView
{
    const CGFloat kUIDatePickerViewHeight = 240;
    CGRect pickerViewFrame = CGRectMake(0, 0, self.view.frame.size.width, kUIDatePickerViewHeight);
    _datePickerView = [[[JCHDatePickerView alloc] initWithFrame:pickerViewFrame
                                                         title:@"请选生日"] autorelease];
    _datePickerView.delegate = self;
    _datePickerView.datePickerMode = UIDatePickerModeDate;
    
    
    [_datePickerView show];
}

#pragma mark - JCHPickerViewDelegate

- (void)pickerViewWillHide:(JCHPickerView *)pickerView
{
    if ([_currentEditView.detailLabel.text isEqualToString:@""]) {
        _currentEditView.detailLabel.text = self.pickerViewDataSource[0];
    }
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kJCHPickerViewRowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerViewDataSource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_pickerView.tag == kJCHPickerViewTagSex) {
        _genderTapView.detailLabel.text = self.pickerViewDataSource[row];
    } else if (_pickerView.tag == kJCHPickerViewTagIndustry){
        _industryTapView.detailLabel.text = self.pickerViewDataSource[row];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerViewDataSource.count;
}

#pragma mark - JCHDatePickerViewDelegate
- (void)handleDateChanged:(JCHDatePickerView *)datePicker selectedDate:(NSDate *)selectedDate
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSString *selectedDateString = [dateFormater stringFromDate:selectedDate];
    _birthdayTapView.detailLabel.text = selectedDateString;
    
    _birthdayTime = [selectedDate timeIntervalSince1970];
    
    return;
}


@end
