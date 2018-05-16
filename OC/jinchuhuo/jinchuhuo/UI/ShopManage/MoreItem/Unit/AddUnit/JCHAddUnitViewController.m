//
//  JCHAddUnitViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHAddUnitViewController.h"
#import "ServiceFactory.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHPickerView.h"
#import "JCHInputAccessoryView.h"
#import "UIView+JCHView.h"
#import "MBProgressHUD+JCHHud.h"
#import "Masonry.h"

@interface JCHAddUnitViewController () <UIPickerViewDelegate, UIPickerViewDataSource, JCHPickerViewDelegate, UITextFieldDelegate>
{
    UITableView *backgroundTableView;
    UITextField *nameTextField;
    UILabel *decimalTitleLabel;
    UISwitch *decimalSwitch;
    UIButton *decimalButton;
    UILabel *decimalValueLabel;
    UILabel *decimalLengthLabel;
    JCHPickerView *pickerView;
    NSInteger unitDigitsCount;
    UIBarButtonItem *addBtn;
}

@property (nonatomic, retain) NSArray *dataSource;
@end

@implementation JCHAddUnitViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
        self.dataSource = @[@"1位", @"2位", @"3位", @"4位", @"5位"];
        unitDigitsCount = 0;
    }
    
    return self;
}

- (void)dealloc
{
    self.unitRecord = nil;
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
    
    const CGFloat textFieldHeight = 44;
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, self.view.frame.size.width, kJCHInputAccessoryViewHeight);
    
    //右上角完成按钮
    addBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(handleAddRecord:)];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    backgroundTableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
    backgroundTableView.backgroundColor = JCHColorGlobalBackground;
    backgroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:backgroundTableView];
    

    nameTextField = [JCHUIFactory createTextField:CGRectMake(0, kStandardTopMargin, kScreenWidth, textFieldHeight)
                                      placeHolder:@"请输入名称"
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    nameTextField.font = [UIFont systemFontOfSize:17];
    nameTextField.leftViewMode = UITextFieldViewModeAlways;
    nameTextField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kStandardLeftMargin, textFieldHeight)] autorelease];
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.text = self.unitRecord.unitName;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    [nameTextField addTarget:self action:@selector(textFieldIsEditing) forControlEvents:UIControlEventEditingChanged];
    if ([self.unitRecord.unitName isEqualToString:@""] || (self.unitRecord.unitName == nil)) {
        addBtn.enabled = NO;
    }
    else
    {
        addBtn.enabled = YES;
    }
    [backgroundTableView addSubview:nameTextField];
    nameTextField.delegate = self;
    nameTextField.returnKeyType = UIReturnKeyDone;
    [nameTextField addSeparateLineWithFrameTop:YES bottom:YES];
    
#if 1
    UIFont *titleLabelFont = [UIFont systemFontOfSize:16];
    CGFloat titleLabelHeight = 44;
    
    decimalTitleLabel = [JCHUIFactory createLabel:CGRectMake(0, textFieldHeight + 2 * kStandardTopMargin, kScreenWidth, titleLabelHeight)
                                            title:@"   是否使用小数点"
                                             font:titleLabelFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    decimalTitleLabel.backgroundColor = [UIColor whiteColor];
    [backgroundTableView addSubview:decimalTitleLabel];
    
    [decimalTitleLabel layoutIfNeeded];
    
    
    [decimalTitleLabel addSeparateLineWithFrameTop:YES bottom:YES];

    decimalSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 74, CGRectGetMinY(decimalTitleLabel.frame) + 8, 94, titleLabelHeight)] autorelease];

    [decimalSwitch addTarget:self action:@selector(handleSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [backgroundTableView addSubview:decimalSwitch];
   
    
    decimalLengthLabel = [JCHUIFactory createLabel:CGRectMake(0, CGRectGetMaxY(decimalTitleLabel.frame), kScreenWidth, titleLabelHeight)
                                            title:@"   小数位数"
                                             font:titleLabelFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    decimalLengthLabel.backgroundColor = [UIColor whiteColor];
    decimalLengthLabel.hidden = YES;
    [backgroundTableView addSubview:decimalLengthLabel];

    
    decimalValueLabel = [JCHUIFactory createLabel:CGRectMake(0, CGRectGetMinY(decimalLengthLabel.frame), kScreenWidth - 2 * kStandardLeftMargin, titleLabelHeight)
                                            title:@"2位"
                                             font:titleLabelFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentRight];
    decimalValueLabel.hidden = YES;
    [backgroundTableView addSubview:decimalValueLabel];
    
    decimalButton = [JCHUIFactory createButton:decimalLengthLabel.frame
                                        target:self
                                        action:@selector(handlePickerView)
                                         title:@""
                                    titleColor:JCHColorMainBody
                               backgroundColor:nil];
    decimalButton.hidden = YES;
    [backgroundTableView addSubview:decimalButton];
    
    
    [decimalButton addSeparateLineWithFrameTop:NO bottom:YES];
    
    //pickerView
    {
        const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
        pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"请选择" showInView:self.view] autorelease];
        pickerView.delegate = self;
        pickerView.dataSource = self;
    }
    
  
    //修改单位时根据小数点位数显示相应的控件
    if (self.unitRecord.unitDecimalDigits != 0)
    {
        [decimalSwitch setOn:YES];
        [self handleSwitchAction:decimalSwitch];
        decimalValueLabel.text = [NSString stringWithFormat:@"%ld位", (long)self.unitRecord.unitDecimalDigits];
    }
    else
    {
        [decimalSwitch setOn:NO];
    }
    
#endif
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
    if (nil == nameTextField.text ||
        YES == [nameTextField.text isEqualToString:@""]) {
        return;
    }
    
    [nameTextField resignFirstResponder];
    
    // 判断当前的单位是否已存在
    id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
    id<UnitService> unitService = [[ServiceFactory sharedInstance] unitService];
    NSArray *allUnitList = [unitService queryAllUnit];

    // 如果是更新新记录
    if (self.unitType == kJCHUnitTypeModifyUnit) {
        // 如果修改了名称，需要判断修改好的名称是否已存在于数据库中
        if (NO == [self.unitRecord.unitName isEqualToString:nameTextField.text]) {
            for (UnitRecord4Cocoa *unit in allUnitList) {
                if ([unit.unitName isEqualToString:nameTextField.text]) {
                    [self showDuplicateUnitName];
                    return;
                }
            }
        }
    } else {
        // 如果是插入记录
        for (UnitRecord4Cocoa *unit in allUnitList) {
            // 判断插入的单位名称是否已存在于数据库中
            if ([unit.unitName isEqualToString:nameTextField.text]) {
                [self showDuplicateUnitName];
                return;
            }
        }
    }

    NSString *unitName = nameTextField.text;

    UnitRecord4Cocoa *unitRecord = [[[UnitRecord4Cocoa alloc] init] autorelease];
    unitRecord.unitDecimalDigits = unitDigitsCount;     // 小数位数
    unitRecord.unitName = unitName;                     // 单位名称
    unitRecord.unitMemo = @"";                      // 备注
    unitRecord.unitProperty = @"";                  // 单位属性
  
    if(self.unitType == kJCHUnitTypeModifyUnit)
    {
        unitRecord.unitUUID = [self.unitRecord unitUUID];
        if([unitService updateUnit:unitRecord]) {
            
            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"修改单位失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            return;
        }
    }
    else
    {
        unitRecord.unitUUID = [utilityService generateUUID];
        if([unitService insertUnit:unitRecord]) {

            [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"添加单位失败" duration:2 mode:MBProgressHUDModeText completion:nil];
            return;
        }
    }
    
    if (self.sendValueBlock) {
        self.sendValueBlock(unitRecord.unitName);
        UIViewController *addProductViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
        [self.navigationController popToViewController:addProductViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
}

- (void)showDuplicateUnitName
{

    [MBProgressHUD showHUDWithTitle:@"温馨提示" detail:@"您添加的单位已存在" duration:2 mode:MBProgressHUDModeText completion:nil];
    
    return;
}

- (void)handleSwitchAction:(UISwitch *)sender
{
    if (sender.on)
    {   //on
        decimalButton.hidden = NO;
        decimalLengthLabel.hidden = NO;
        decimalValueLabel.hidden = NO;
        unitDigitsCount = 2;
    }
    else
    {   //off
        decimalButton.hidden = YES;
        decimalLengthLabel.hidden = YES;
        decimalValueLabel.hidden = YES;
        unitDigitsCount = 0;
        [pickerView hide];
    }
}

- (void)handlePickerView
{
    [self.view endEditing:YES];
    
    [pickerView show];
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        if ([decimalValueLabel.text isEqualToString:self.dataSource[i]]) {
            [pickerView.pickerView selectRow:i inComponent:0 animated:YES];
            break;
        }
    }
    
    [pickerView.pickerView reloadAllComponents];
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
    return self.dataSource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    decimalValueLabel.text = self.dataSource[row];
    unitDigitsCount = row + 1;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSource.count;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [pickerView hide];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self handleAddRecord:nil];
    return YES;
}

@end
