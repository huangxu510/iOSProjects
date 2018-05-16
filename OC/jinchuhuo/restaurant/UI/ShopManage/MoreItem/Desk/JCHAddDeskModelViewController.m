//
//  JCHAddDeskModelViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHAddDeskModelViewController.h"
#import "JCHUISizeSettings.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHUISizeSettings.h"
#import "JCHInputAccessoryView.h"
#import "JCHColorSettings.h"
#import "UIView+JCHView.h"
#import "JCHTitleTextField.h"
#import "JCHArrowTapView.h"
#import "MBProgressHUD+JCHHud.h"
#import "LCActionSheet.h"
#import "Masonry.h"

enum {
    kActionSheetChooseTableType = 1001,
};

@interface JCHAddDeskModelViewController () <LCActionSheetDelegate>
{
    JCHArrowTapView *nameArrowTapView;
    UIBarButtonItem *addBtn;
}

@property (retain, nonatomic, readwrite) NSArray *tableTypeList;
@end

@implementation JCHAddDeskModelViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
        self.tableTypeList = @[@"1~2", @"3~4", @"5~8", @"9~13", @"14以上"];
    }
    
    return self;
}

- (void)dealloc
{
    self.tableTypeRecord = nil;
    self.sendValueBlock = nil;
    self.tableTypeList = nil;
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
    
    [nameArrowTapView becomeFirstResponder];
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
    nameArrowTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, textFieldHeight)] autorelease];
    nameArrowTapView.titleLabel.text = @"桌型容量";
    nameArrowTapView.detailLabel.text = @"1~2";
    [nameArrowTapView.button addTarget:self
                                action:@selector(chooseTableType:)
                      forControlEvents:UIControlEventTouchUpInside];
    [backgroundTableView addSubview:nameArrowTapView];
    
    [nameArrowTapView addSeparateLineWithFrameTop:YES bottom:YES];
    
    
    return;
}

- (void)chooseTableType:(id)sender
{
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                                  buttonTitles:self.tableTypeList
                                                redButtonIndex:-1
                                                      delegate:self];
    actionSheet.tag = kActionSheetChooseTableType;
    [actionSheet show];
}

- (void)handleAddRecord:(id)sender
{
    if ((nil == nameArrowTapView.detailLabel.text) ||
        ([nameArrowTapView.detailLabel.text isEqualToString:@""])) {
        return;
    }
    
    [nameArrowTapView resignFirstResponder];
    
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray *allTypeList = [diningTableService queryTableType];
    
    if (self.categoreType == kJCHAddDeskModelTypeModifyCategory) {
        // 如果为修改分类
        // 如果修改了分类名称，肯修改后的分类名称已存在于数据库中
        if (NO == [self.tableTypeRecord.typeName isEqualToString:nameArrowTapView.detailLabel.text]) {
            for (TableTypeRecord4Cocoa *typeType in allTypeList) {
                if ([typeType.typeName isEqualToString:nameArrowTapView.detailLabel.text]) {
                    [self showDuplicateCategoryAlert];
                    return;
                }
            }
        }
    } else {
        // 如果为添加分类
        // 检查当前添加的分类是否已存在于数据库中
        for (TableTypeRecord4Cocoa *typeType in allTypeList) {
            if ([typeType.typeName isEqualToString:nameArrowTapView.detailLabel.text]) {
                [self showDuplicateCategoryAlert];
                return;
            }
        }
    }
    
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    NSString *typeName = nameArrowTapView.detailLabel.text;
    TableTypeRecord4Cocoa *record = [[[TableTypeRecord4Cocoa alloc] init] autorelease];
    record.typeName = typeName;
    record.typeID = [utilityService generateID];
    
    if (self.categoreType == kJCHAddDeskModelTypeModifyCategory)
    {
        record.typeID = self.tableTypeRecord.typeID;
        if([diningTableService addOrUpdateTableType:record]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"修改桌型失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            
            return;
        }
    }
    else
    {
        if([diningTableService addOrUpdateTableType:record]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"添加桌型失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            
            return;
        }
    }
    
    if (self.sendValueBlock) {
        self.sendValueBlock(record.typeName);
        UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
        [self.navigationController popToViewController:addProductViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
}

- (void)showDuplicateCategoryAlert
{
    [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"您添加的桌型已存在" duration:2 mode:MBProgressHUDModeText completion:nil];
    return;
}

#pragma mark - UITextFieldDelete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self handleAddRecord:nil];
    return YES;
}

#pragma mark -
#pragma mark LCActionDelegate
- (void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kActionSheetChooseTableType:
        {
            if (buttonIndex < self.tableTypeList.count) {
                nameArrowTapView.detailLabel.text = self.tableTypeList[buttonIndex];
            }
        }
            break;
            
        default:
            break;
    }
}

@end


