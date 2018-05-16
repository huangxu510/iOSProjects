//
//  JCHAddCategoryViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHAddCategoryViewController.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHUISizeSettings.h"
#import "JCHInputAccessoryView.h"
#import "JCHColorSettings.h"
#import "UIView+JCHView.h"
#import "MBProgressHUD+JCHHud.h"
#import "Masonry.h"
#import "CommonHeader.h"

@interface JCHAddCategoryViewController () <UITextFieldDelegate>
{
    UITextField *nameTextField;
    UIBarButtonItem *addBtn;
}
@end

@implementation JCHAddCategoryViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
    }
    
    return self;
}

- (void)dealloc
{
    self.categoryRecord = nil;
    self.sendValueBlock = nil;
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [nameTextField becomeFirstResponder];
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    //右上角完成按钮
    addBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(handleAddRecord:)];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    UITableView *backgroundTableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
    backgroundTableView.backgroundColor = JCHColorGlobalBackground;
    backgroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:backgroundTableView];
    
    
    const CGFloat textFieldHeight = 44;
    
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    
    nameTextField = [JCHUIFactory createTextField:CGRectMake(0, kStandardTopMargin, kScreenWidth, textFieldHeight)
                                      placeHolder:@"请输入名称"
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    nameTextField.leftViewMode = UITextFieldViewModeAlways;
    nameTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.font = [UIFont systemFontOfSize:17];
    nameTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    nameTextField.text = self.categoryRecord.categoryName;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.delegate = self;
    [nameTextField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    
    [backgroundTableView addSubview:nameTextField];
    
    [nameTextField addSeparateLineWithFrameTop:YES bottom:YES];

    
    return;
}

- (void)textFieldIsEditing
{
    if ([nameTextField.text isEqualToString:@""]) {
        addBtn.enabled = NO;
    }
    else
    {
        addBtn.enabled = YES;
    }
}

- (void)handleAddRecord:(id)sender
{
    if ((nil == nameTextField.text) ||
        ([nameTextField.text isEqualToString:@""])) {
        return;
    }
    
    [nameTextField resignFirstResponder];
    
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    NSArray *allCategoryList = [categoryService queryAllCategory];
    
    CategoryRecord4Cocoa *record = [[[CategoryRecord4Cocoa alloc] init] autorelease];
    
#if MMR_TAKEOUT_VERSION
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    if (self.categoreType == kJCHCategoryTypeModifyCategory) {
        // 如果为修改分类
        // 如果修改了分类名称，肯修改后的分类名称已存在于数据库中
        if (NO == [self.categoryRecord.categoryName isEqualToString:nameTextField.text]) {
            for (CategoryRecord4Cocoa *category in allCategoryList) {
                if ([category.categoryName isEqualToString:nameTextField.text]) {
                    [self showDuplicateCategoryAlert];
                    return;
                }
            }
        }
        
        NSString *categoryName = nameTextField.text;
        record.categoryMemo = @"";
        record.categoryName = categoryName;
        record.categoryProperty = @"";
        record.categoryUUID = self.categoryRecord.categoryUUID;
        
        UpdateCategoryRequest *request = [[[UpdateCategoryRequest alloc] init] autorelease];
        request.oldName = self.categoryRecord.categoryName;
        request.currentNewName = categoryName;
        request.token = statusManager.syncToken;
        request.bookID = statusManager.accountBookID;
        request.index = self.categoryRecord.categorySortIndex;
        request.serviceURL = [NSString stringWithFormat:@"%@/category/update", kTakeoutServerIP];
        [MBProgressHUD showHUDWithTitle:@"保存中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
        [takeoutService updateCategory:request callback:^(id response) {
            
            NSDictionary *data = response;
            
            if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
                NSDictionary *responseData = data[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    //! @todo
                    if (responseCode == 22000) {
                        [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                                 detail:@"请重新登录"
                                               duration:kJCHDefaultShowHudTime
                                                   mode:MBProgressHUDModeText
                                              superView:self.view
                                             completion:nil];
                    } else {
                        [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                                 detail:responseDescription
                                               duration:kJCHDefaultShowHudTime
                                                   mode:MBProgressHUDModeText
                                              superView:self.view
                                             completion:nil];
                    }
                } else {
                    NSLog(@"responseData = %@", responseData);
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                    
                    int status = [categoryService updateCategory:record];
                    if(status) {
                        NSString *detail = [NSString stringWithFormat:@"修改分类失败 %d", status];
                        [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:detail duration:2 mode:MBProgressHUDModeText completion:nil];
                    }
                }
            } else {
                NSLog(@"request fail: %@", data[@"data"]);
                [MBProgressHUD showNetWorkFailedHud:@""
                                          superView:self.view];
            }
            
            if (self.sendValueBlock) {
                self.sendValueBlock(record.categoryName);
                UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
                [self.navigationController popToViewController:addProductViewController animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    } else {
        // 如果为添加分类
        // 检查当前添加的分类是否已存在于数据库中
        for (CategoryRecord4Cocoa *category in allCategoryList) {
            if ([category.categoryName isEqualToString:nameTextField.text]) {
                [self showDuplicateCategoryAlert];
                return;
            }
        }
        
        id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
        NSString *categoryName = nameTextField.text;
        
        record.categoryMemo = @"";
        record.categoryName = categoryName;
        record.categoryProperty = @"";
        record.categoryUUID = [utilityService generateUUID];
        
        AddCategoryRequest *request = [[[AddCategoryRequest alloc] init] autorelease];
        request.name = categoryName;
        request.token = statusManager.syncToken;
        request.bookID = statusManager.accountBookID;
        request.serviceURL = [NSString stringWithFormat:@"%@/category/add", kTakeoutServerIP];
        [MBProgressHUD showHUDWithTitle:@"保存中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
        
        [takeoutService addCategory:request callback:^(id response) {
        
            NSDictionary *data = response;
            
            if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
                NSDictionary *responseData = data[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    //! @todo
                    if (responseCode == 22000) {
                        [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                                 detail:@"请重新登录"
                                               duration:kJCHDefaultShowHudTime
                                                   mode:MBProgressHUDModeText
                                              superView:self.view
                                             completion:nil];
                    } else {
                        [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                                 detail:responseDescription
                                               duration:kJCHDefaultShowHudTime
                                                   mode:MBProgressHUDModeText
                                              superView:self.view
                                             completion:nil];
                    }
                } else {
                    NSLog(@"responseData = %@", responseData);
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                    
                    int status = [categoryService insertCategory:record];
                    if(status) {
                        NSString *detail = [NSString stringWithFormat:@"添加分类失败 %d", status];
                        [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:detail duration:2 mode:MBProgressHUDModeText completion:nil];
                    }
                }
            } else {
                NSLog(@"request fail: %@", data[@"data"]);
                [MBProgressHUD showNetWorkFailedHud:@""
                                          superView:self.view];
            }
            
            if (self.sendValueBlock) {
                self.sendValueBlock(record.categoryName);
                UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
                [self.navigationController popToViewController:addProductViewController animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    
    
#else
    if (self.categoreType == kJCHCategoryTypeModifyCategory) {
        // 如果为修改分类
        // 如果修改了分类名称，肯修改后的分类名称已存在于数据库中
        if (NO == [self.categoryRecord.categoryName isEqualToString:nameTextField.text]) {
            for (CategoryRecord4Cocoa *category in allCategoryList) {
                if ([category.categoryName isEqualToString:nameTextField.text]) {
                    [self showDuplicateCategoryAlert];
                    return;
                }
            }
        }
        
        NSString *categoryName = nameTextField.text;
        record.categoryMemo = @"";
        record.categoryName = categoryName;
        record.categoryProperty = @"";
        record.categoryUUID = self.categoryRecord.categoryUUID;
        
        int status = [categoryService updateCategory:record];
        if(status) {
            NSString *detail = [NSString stringWithFormat:@"修改分类失败 %d", status];
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:detail duration:2 mode:MBProgressHUDModeText completion:nil];
        }
    } else {
        // 如果为添加分类
        // 检查当前添加的分类是否已存在于数据库中
        for (CategoryRecord4Cocoa *category in allCategoryList) {
            if ([category.categoryName isEqualToString:nameTextField.text]) {
                [self showDuplicateCategoryAlert];
                return;
            }
        }
        
        id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
        NSString *categoryName = nameTextField.text;
        
        record.categoryMemo = @"";
        record.categoryName = categoryName;
        record.categoryProperty = @"";
        record.categoryUUID = [utilityService generateUUID];
        
        int status = [categoryService insertCategory:record];
        if(status) {
            NSString *detail = [NSString stringWithFormat:@"添加分类失败 %d", status];
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:detail duration:2 mode:MBProgressHUDModeText completion:nil];
        }
    }
    
    
    if (self.sendValueBlock) {
        self.sendValueBlock(record.categoryName);
        UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
        [self.navigationController popToViewController:addProductViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
#endif
}


- (void)showDuplicateCategoryAlert
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"您添加的分类已存在" duration:2 mode:MBProgressHUDModeText completion:nil];
    return;
}

#pragma mark - UITextFieldDelete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self handleAddRecord:nil];
    return YES;
}

@end
