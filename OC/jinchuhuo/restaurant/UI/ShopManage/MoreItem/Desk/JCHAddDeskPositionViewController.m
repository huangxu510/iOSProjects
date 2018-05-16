//
//  JCHAddDeskPositionViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHAddDeskPositionViewController.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHUISizeSettings.h"
#import "JCHInputAccessoryView.h"
#import "JCHColorSettings.h"
#import "JCHTitleTextField.h"
#import "UIView+JCHView.h"
#import "MBProgressHUD+JCHHud.h"
#import "Masonry.h"

@interface JCHAddDeskPositionViewController () <UITextFieldDelegate>
{
    JCHTitleTextField *nameTextField;
    UIBarButtonItem *addBtn;
}
@end

@implementation JCHAddDeskPositionViewController

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
    self.tableRegionRecord = nil;
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
    nameTextField = [[[JCHTitleTextField alloc] initWithTitle:@"区域命名"
                                                         font:JCHFont(17.0)
                                                  placeholder:@"如\"A区\"，\"B区\""
                                                    textColor:JCHColorMainBody] autorelease];
    nameTextField.frame = CGRectMake(0, kStandardTopMargin, kScreenWidth, textFieldHeight);
    nameTextField.textField.leftViewMode = UITextFieldViewModeAlways;
    nameTextField.textField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    nameTextField.textField.backgroundColor = [UIColor whiteColor];
    nameTextField.textField.font = [UIFont systemFontOfSize:17];
    nameTextField.textField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    nameTextField.textField.text = self.tableRegionRecord.regionType;
    nameTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.textField.returnKeyType = UIReturnKeyDone;
    nameTextField.textField.delegate = self;
    [nameTextField.textField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    
    
    [backgroundTableView addSubview:nameTextField];
    
    [nameTextField addSeparateLineWithFrameTop:YES bottom:YES];
    
    
    return;
}

- (void)textFieldIsEditing
{
    if ([nameTextField.textField.text isEqualToString:@""]) {
        addBtn.enabled = NO;
    }
    else
    {
        addBtn.enabled = YES;
    }
}

- (void)handleAddRecord:(id)sender
{
    if ((nil == nameTextField.textField.text) ||
        ([nameTextField.textField.text isEqualToString:@""])) {
        return;
    }
    
    [nameTextField resignFirstResponder];
    
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray *allRegionArray = [diningTableService queryTableRegion];
    
    if (self.addRegionType == kJCHAddDeskPositionTypeModifyCategory) {
        // 如果为修改分类
        // 如果修改了分类名称，肯修改后的分类名称已存在于数据库中
        if (NO == [self.tableRegionRecord.regionType isEqualToString:nameTextField.textField.text]) {
            for (TableRegionRecord4Cocoa *region in allRegionArray) {
                if ([region.regionType isEqualToString:nameTextField.textField.text]) {
                    [self showDuplicateCategoryAlert];
                    return;
                }
            }
        }
    } else {
        // 如果为添加分类
        // 检查当前添加的分类是否已存在于数据库中
        for (TableRegionRecord4Cocoa *region in allRegionArray) {
            if ([region.regionType isEqualToString:nameTextField.textField.text]) {
                [self showDuplicateCategoryAlert];
                return;
            }
        }
    }
    
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    NSString *regionName = nameTextField.textField.text;
    TableRegionRecord4Cocoa *record = [[[TableRegionRecord4Cocoa alloc] init] autorelease];
    record.regionType = regionName;
    record.regionID = [utilityService generateID];
    
    if (self.addRegionType == kJCHAddDeskPositionTypeModifyCategory)
    {
        record.regionID = self.tableRegionRecord.regionID;
        if([diningTableService addOrUpdateTableRegion:record]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"修改区域失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            
            return;
        }
    }
    else
    {
        if([diningTableService addOrUpdateTableRegion:record]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"添加区域失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            
            return;
        }
    }
    
    if (self.sendValueBlock) {
        self.sendValueBlock(record.regionType);
        UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
        [self.navigationController popToViewController:addProductViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
}

- (void)showDuplicateCategoryAlert
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"您添加的区域已存在" duration:2 mode:MBProgressHUDModeText completion:nil];
    return;
}

#pragma mark - UITextFieldDelete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self handleAddRecord:nil];
    return YES;
}


@end


