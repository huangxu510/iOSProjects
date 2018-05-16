//
//  JCHShopEditViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopInfoEditViewController.h"
#import "JCHInputAccessoryView.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "JCHSyncStatusManager.h"
#import "NSString+JCHString.h"
#import "ServiceFactory.h"

@interface JCHShopInfoEditViewController ()
{
    UITextField *_shopInfoTextField;
    UIBarButtonItem *_saveButton;
    JCHShopInfoEditType _currentType;
}
@property (nonatomic, retain) BookInfoRecord4Cocoa *bookInfoRecord;
@end

@implementation JCHShopInfoEditViewController

- (instancetype)initWithType:(JCHShopInfoEditType)type
{
    self = [super init];
    if (self) {
        _currentType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (_currentType == kJCHShopName) {
        self.title = @"店铺名称";
    } else if (_currentType == kJCHShopAddress) {
        self.title = @"店铺地址";
    } else if (_currentType == kJCHShopTelephone) {
        self.title = @"联系电话";
    } else if (_currentType == kJCHShopNotice) {
        self.title = @"店铺公告";
    }
    [self loadData];
    [self createUI];
}

- (void)dealloc
{
    [self.bookInfoRecord release];
    [super dealloc];
}


- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    //右上角完成按钮
    _saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveRecord:)];
    self.navigationItem.rightBarButtonItem = _saveButton;
    
    UITableView *backgroundTableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
    backgroundTableView.backgroundColor = JCHColorGlobalBackground;
    backgroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:backgroundTableView];
    
    
    const CGFloat textFieldHeight = 44;
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    
    
    
    
    
    NSString *placeHolder = nil;
    if (_currentType == kJCHShopName) {
        placeHolder = @"请输入店铺名称";
    } else if (_currentType == kJCHShopAddress) {
        placeHolder = @"请输入店铺地址";
    } else if (_currentType == kJCHShopTelephone) {
        placeHolder = @"请输入店铺电话";
    } else if (_currentType == kJCHShopNotice) {
        placeHolder = @"请输入店铺公告";
    }
    
    _shopInfoTextField = [JCHUIFactory createTextField:CGRectMake(0, kStandardTopMargin, kScreenWidth, textFieldHeight)
                                              placeHolder:placeHolder
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    _shopInfoTextField.leftViewMode = UITextFieldViewModeAlways;
    _shopInfoTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    _shopInfoTextField.backgroundColor = [UIColor whiteColor];
    _shopInfoTextField.font = [UIFont systemFontOfSize:17];
    _shopInfoTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    
    _shopInfoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_shopInfoTextField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    [_shopInfoTextField addSeparateLineWithFrameTop:YES bottom:YES];
    

    if (_currentType == kJCHShopName) {
        _shopInfoTextField.text = self.bookInfoRecord.bookName;
    } else if (_currentType == kJCHShopAddress) {
        _shopInfoTextField.text = self.bookInfoRecord.bookAddress;
    } else if (_currentType == kJCHShopTelephone) {
        _shopInfoTextField.text = self.bookInfoRecord.telephone;
        _shopInfoTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else if (_currentType == kJCHShopNotice) {
        
    }
    
    
    [backgroundTableView addSubview:_shopInfoTextField];
}

- (void)loadData
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    self.bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
}

- (void)textFieldIsEditing
{
    if ([_shopInfoTextField.text isEqualToString:@""]) {
        _saveButton.enabled = NO;
    }
    else
    {
        _saveButton.enabled = YES;
    }
}

- (void)handleSaveRecord:(id)sender
{
    if (_currentType == kJCHShopName) {
        self.bookInfoRecord.bookName = _shopInfoTextField.text;
    } else if (_currentType == kJCHShopAddress) {
        self.bookInfoRecord.bookAddress = _shopInfoTextField.text;
    } else if (_currentType == kJCHShopTelephone) {
        self.bookInfoRecord.telephone = _shopInfoTextField.text;
    } else if (_currentType == kJCHShopNotice) {
        
    }
    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    [bookInfoService updateBookInfo:self.bookInfoRecord];
    [self.navigationController popViewControllerAnimated:YES];
}




@end
