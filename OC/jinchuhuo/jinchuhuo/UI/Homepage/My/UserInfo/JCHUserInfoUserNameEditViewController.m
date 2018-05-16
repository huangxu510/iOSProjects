//
//  JCHUserInfoUserNameEditViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHUserInfoUserNameEditViewController.h"
#import "JCHUserInfoViewController.h"
#import "JCHInputAccessoryView.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "JCHSyncStatusManager.h"
#import "ServiceFactory.h"

@interface JCHUserInfoUserNameEditViewController ()
{
    UITextField *_nameTextField;
    UIBarButtonItem *_saveBtn;
}
@end

@implementation JCHUserInfoUserNameEditViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"修改昵称";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    //右上角完成按钮
    _saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveUserName)];
    self.navigationItem.rightBarButtonItem = _saveBtn;
    
    UITableView *backgroundTableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
    backgroundTableView.backgroundColor = JCHColorGlobalBackground;
    backgroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:backgroundTableView];
    
    
    const CGFloat textFieldHeight = 44;
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    
    _nameTextField = [JCHUIFactory createTextField:CGRectMake(0, kStandardTopMargin, kScreenWidth, textFieldHeight)
                                      placeHolder:@"请输入名称"
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    _nameTextField.leftViewMode = UITextFieldViewModeAlways;
    _nameTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    _nameTextField.backgroundColor = [UIColor whiteColor];
    _nameTextField.font = [UIFont systemFontOfSize:17];
    _nameTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_nameTextField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    _nameTextField.text = manager.userName;
    
    [backgroundTableView addSubview:_nameTextField];
    
    [_nameTextField addSeparateLineWithFrameTop:YES bottom:YES];
}

- (void)textFieldIsEditing
{
    if ([_nameTextField.text isEqualToString:@""]) {
        _saveBtn.enabled = NO;
    }
    else
    {
        _saveBtn.enabled = YES;
    }
}

- (void)handleSaveUserName
{
    JCHSyncStatusManager *manager = [JCHSyncStatusManager shareInstance];
    manager.userName = _nameTextField.text;
    [JCHSyncStatusManager writeToFile];
    
    id <BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *bookMemberRecord = [bookMemberService queryBookMemberWithUserID:manager.userID];
    bookMemberRecord.nickname = _nameTextField.text;

    //更新所有账本中的book member信息
    [ServiceFactory updateBookMemberInAllAccountBook:manager.userID bookMember:bookMemberRecord];
    
    //由上个页面将用户信息上传到服务器
    NSArray *viewControllers = self.navigationController.viewControllers;
    JCHUserInfoViewController *userInfoVierController = viewControllers[viewControllers.count - 2];
    [userInfoVierController doUpdateUserProfile];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
