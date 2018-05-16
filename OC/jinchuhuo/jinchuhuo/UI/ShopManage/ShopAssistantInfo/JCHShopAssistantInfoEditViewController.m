//
//  JCHShopAssistantInfoEditViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopAssistantInfoEditViewController.h"
#import "JCHInputAccessoryView.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"

@interface JCHShopAssistantInfoEditViewController ()
{
    UITextField *_shopAssistantInfoTextField;
    UIBarButtonItem *_saveButton;
    JCHShopAssistantInfoEditType _currentType;
}
@end

@implementation JCHShopAssistantInfoEditViewController

- (instancetype)initWithType:(JCHShopAssistantInfoEditType)type
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
    
    if (_currentType == kJCHShopAssistantInfoEditTypeRemark) {
        self.title = @"备注";
    }
    else
    {
        self.title = @"电话";
    }
    [self createUI];
}

- (void)dealloc
{
    [self.bookMemberRecord release];
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
    if (_currentType == kJCHShopAssistantInfoEditTypeRemark) {
        placeHolder = @"请输入备注";
    }
    else
    {
        placeHolder = @"请输入电话";
    }
    
    _shopAssistantInfoTextField = [JCHUIFactory createTextField:CGRectMake(0, kStandardTopMargin, kScreenWidth, textFieldHeight)
                                           placeHolder:placeHolder
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
    _shopAssistantInfoTextField.leftViewMode = UITextFieldViewModeAlways;
    _shopAssistantInfoTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    _shopAssistantInfoTextField.backgroundColor = [UIColor whiteColor];
    _shopAssistantInfoTextField.font = [UIFont systemFontOfSize:17];
    _shopAssistantInfoTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    
    _shopAssistantInfoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_shopAssistantInfoTextField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    [_shopAssistantInfoTextField addSeparateLineWithFrameTop:YES bottom:YES];
    _shopAssistantInfoTextField.text = self.bookMemberRecord.remarks;
    
    [backgroundTableView addSubview:_shopAssistantInfoTextField];
    
}
- (void)textFieldIsEditing
{
    if ([_shopAssistantInfoTextField.text isEqualToString:@""]) {
        _saveButton.enabled = NO;
    }
    else
    {
        _saveButton.enabled = YES;
    }
}

- (void)handleSaveRecord:(id)sender
{
    self.bookMemberRecord.remarks = _shopAssistantInfoTextField.text;
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    [bookMemberService updateBookMember:self.bookMemberRecord];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
