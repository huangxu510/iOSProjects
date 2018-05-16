//
//  JCHAddRestaurantCategoryViewController.m
//  restaurant
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddRestaurantCategoryViewController.h"
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
#import "JCHArrowTapView.h"
#import "Masonry.h"
#import "LCActionSheet.h"

@interface JCHAddRestaurantCategoryViewController () <UITextFieldDelegate, LCActionSheetDelegate>
{
    UITextField *nameTextField;
    JCHArrowTapView *categoryTypeTapView;
    UIBarButtonItem *addBtn;
}

@property (retain, nonatomic, readwrite) NSArray *categoryTypeList;

@end

@implementation JCHAddRestaurantCategoryViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
        self.categoryTypeList = @[@"菜品", @"原料"];
    }
    
    return self;
}

- (void)dealloc
{
    self.categoryRecord = nil;
    self.sendValueBlock = nil;
    self.categoryTypeList = nil;
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
    
    
    categoryTypeTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    categoryTypeTapView.titleLabel.text = @"类型归属";
    categoryTypeTapView.titleLabel.font = [UIFont systemFontOfSize:15.0];
    categoryTypeTapView.bottomLine.hidden = NO;
    [categoryTypeTapView.button addTarget:self action:@selector(handleSelectCategoryType:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundTableView addSubview:categoryTypeTapView];
    
    [categoryTypeTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backgroundTableView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(nameTextField.mas_bottom).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    
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
    
    if (self.categoreType == kJCHRestaurantCategoryTypeModifyCategory) {
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
    } else {
        // 如果为添加分类
        // 检查当前添加的分类是否已存在于数据库中
        for (CategoryRecord4Cocoa *category in allCategoryList) {
            if ([category.categoryName isEqualToString:nameTextField.text]) {
                [self showDuplicateCategoryAlert];
                return;
            }
        }
    }
    
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    NSString *categoryName = nameTextField.text;
    CategoryRecord4Cocoa *record = [[[CategoryRecord4Cocoa alloc] init] autorelease];
    record.categoryMemo = @"";
    record.categoryName = categoryName;
    record.categoryProperty = @"";
    record.categoryUUID = [utilityService generateUUID];
    
    if (self.categoreType == kJCHRestaurantCategoryTypeModifyCategory)
    {
        record.categoryUUID = self.categoryRecord.categoryUUID;
        if([categoryService updateCategory:record]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"修改分类失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            
            return;
        }
    }
    else
    {
        if([categoryService insertCategory:record]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"添加分类失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            
            return;
        }
    }
    
    if (self.sendValueBlock) {
        self.sendValueBlock(record.categoryName);
        UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
        [self.navigationController popToViewController:addProductViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
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

- (void)handleSelectCategoryType:(id)sender
{
    [nameTextField resignFirstResponder];
    
    LCActionSheet *actionSheet = [[[LCActionSheet alloc] initWithTitle:nil
                                                          buttonTitles:self.categoryTypeList
                                                        redButtonIndex:-1
                                                              delegate:self] autorelease];
    [actionSheet show];
    
    return;
}

#pragma mark - LCActionSheetDelegate
- (void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < self.categoryTypeList.count) {
        categoryTypeTapView.detailLabel.text = self.categoryTypeList[buttonIndex];
    }
    
}

@end

