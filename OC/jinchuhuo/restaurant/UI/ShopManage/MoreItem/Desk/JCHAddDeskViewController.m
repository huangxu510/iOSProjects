//
//  JCHAddDeskViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHAddDeskViewController.h"
#import "CommonHeader.h"
#import "JCHTextView.h"
#import "JCHArrowTapView.h"
#import "JCHTitleTextField.h"
#import "JCHInputAccessoryView.h"
#import "JCHDeskPositionListViewController.h"
#import "JCHDeskModelListViewController.h"

@interface JCHAddDeskViewController ()<UITextViewDelegate>
{
    JCHArrowTapView *positionArrayTapView;
    JCHArrowTapView *deskModelArrayTapView;
    JCHTitleTextField *deskNumberTextField;
    JCHTextView *remarkTextView;
}

@property (retain, nonatomic, readwrite) TableRegionRecord4Cocoa *selectPositionRecord;
@property (retain, nonatomic, readwrite) TableTypeRecord4Cocoa *selectModelRecord;

@end

@implementation JCHAddDeskViewController

- (id)init
{
    self = [super init];
    if (self) {
        if (kJCHAddDeskTypeAdd == self.enumAddType) {
            self.title = @"添加桌台";
        } else if (kJCHAddDeskTypeModify == self.enumAddType) {
            self.title = @"修改桌台";
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.selectPositionRecord = nil;
    self.selectModelRecord = nil;
    self.currentTableRecord = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self restoreUIStatus];
}

- (void)createUI
{
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveRecord:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIFont *textFont = [UIFont jchSystemFontOfSize:16.0f];
    UIColor *textColor = JCHColorMainBody;
    const CGRect inputAccessoryFrame = CGRectMake(0, 0,self.view.frame.size.width,
                                                  [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:kJCHInputAccessoryViewHeight]);
    
    // 区域
    {
        positionArrayTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        positionArrayTapView.titleLabel.text = @"区域";
        positionArrayTapView.bottomLine.hidden = NO;
        [positionArrayTapView.button addTarget:self action:@selector(handleSelectPosition:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.backgroundScrollView addSubview:positionArrayTapView];
    
    [positionArrayTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(self.backgroundScrollView.mas_top).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    // 桌型
    {
        deskModelArrayTapView = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
        deskModelArrayTapView.titleLabel.text = @"桌型";
        deskModelArrayTapView.titleLabel.font = [UIFont systemFontOfSize:15.0];
        deskModelArrayTapView.bottomLine.hidden = NO;
        [deskModelArrayTapView.button addTarget:self action:@selector(handleSelectDeskModel:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundScrollView addSubview:deskModelArrayTapView];
        
        [deskModelArrayTapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(positionArrayTapView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 桌号
    {
        deskNumberTextField = [[JCHTitleTextField alloc] initWithTitle:@"桌台号" font:textFont placeholder:@"请输入桌号" textColor:textColor];
        deskNumberTextField.backgroundColor = [UIColor whiteColor];
        NSAttributedString *placeHolder = [[[NSAttributedString alloc] initWithString:@"请输入桌号" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xd5d5d5), NSFontAttributeName : textFont}] autorelease];
        deskNumberTextField.textField.attributedPlaceholder = placeHolder;
        deskNumberTextField.textField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
        deskNumberTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        deskNumberTextField.textField.textAlignment = NSTextAlignmentRight;
        [self.backgroundScrollView addSubview:deskNumberTextField];
        
        [deskNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
            make.right.equalTo(deskModelArrayTapView.mas_right);
            make.top.equalTo(deskModelArrayTapView.mas_bottom);
            make.height.mas_equalTo(kStandardItemHeight);
        }];
    }
    
    // 备注信息
    {
        
        CGFloat remarkTextViewHeight = 40.0f;
        remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, remarkTextViewHeight)] autorelease];
        [self.backgroundScrollView addSubview:remarkTextView];
        
        remarkTextView.delegate = self;
        remarkTextView.textColor = JCHColorMainBody;
        remarkTextView.font = textFont;
        remarkTextView.placeholder = @"添加备注信息";
        remarkTextView.placeholderColor = UIColorFromRGB(0xd5d5d5);
        remarkTextView.isAutoHeight = YES;
        remarkTextView.minHeight = remarkTextViewHeight;
        
        [remarkTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backgroundScrollView);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(remarkTextViewHeight);
            make.top.equalTo(deskNumberTextField.mas_bottom).offset(kStandardTopMargin * 2);
        }];
    }
    
    {
        [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(remarkTextView.mas_bottom);
        }];
    }
}

- (void)restoreUIStatus
{
    if (kJCHAddDeskTypeModify == self.enumAddType &&
        nil != self.currentTableRecord) {
        id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
        NSArray *regionArray = [diningTableService queryTableRegion];
        NSArray *modelArray = [diningTableService queryTableType];
        
        for (TableRegionRecord4Cocoa *region in regionArray) {
            if (region.regionID == self.currentTableRecord.regionID) {
                self.selectPositionRecord = region;
                positionArrayTapView.detailLabel.text = region.regionType;
                break;
            }
        }
        
        for (TableTypeRecord4Cocoa *model in modelArray) {
            if (model.typeID == self.currentTableRecord.typeID) {
                self.selectModelRecord = model;
                deskModelArrayTapView.detailLabel.text = model.typeName;
                break;
            }
        }
        
        deskNumberTextField.textField.text = self.currentTableRecord.tableName;
        remarkTextView.text = self.currentTableRecord.memo;
    }
}

- (void)handleSelectPosition:(id)sender
{
    WeakSelf;
    JCHDeskPositionListViewController *positionListController = [[[JCHDeskPositionListViewController alloc] initWithType:kJCHDeskPositionListTypeSelect] autorelease];
    positionListController.selectPositionRecord = self.selectPositionRecord;
    positionListController.sendValueBlock = ^(TableRegionRecord4Cocoa *selectRegionRecord){
        weakSelf.selectPositionRecord = selectRegionRecord;
        weakSelf -> positionArrayTapView.detailLabel.text = selectRegionRecord.regionType;
    };
    [self.navigationController pushViewController:positionListController animated:YES];
}

- (void)handleSelectDeskModel:(id)sender
{
    WeakSelf;
    JCHDeskModelListViewController *positionListController = [[[JCHDeskModelListViewController alloc] initWithType:kJCHDeskModeListTypeSelect] autorelease];
    positionListController.selectModelRecord = self.selectModelRecord;
    positionListController.sendValueBlock = ^(TableTypeRecord4Cocoa *selectTableTypeRecord){
        weakSelf.selectModelRecord = selectTableTypeRecord;
        weakSelf -> deskModelArrayTapView.detailLabel.text = selectTableTypeRecord.typeName;
    };
    [self.navigationController pushViewController:positionListController animated:YES];
}

- (void)handleSaveRecord:(id)sender
{
    if (nil == self.selectPositionRecord) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请选择桌台区域"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if (nil == self.selectModelRecord) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请选择桌台类型"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if (nil == deskNumberTextField.textField.text ||
        [deskNumberTextField.textField.text isEmptyString]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请输入桌台号"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray *tableArray = [diningTableService queryDiningTable];
    BOOL findDuplicate = NO;
    for (DiningTableRecord4Cocoa *table in tableArray) {
        if ([table.tableName isEqualToString:deskNumberTextField.textField.text]) {
            findDuplicate = YES;
            break;
        }
    }
    
    if (YES == findDuplicate &&
        NO == [deskNumberTextField.textField.text isEqualToString:self.currentTableRecord.tableName]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"您输入的桌台号已存在"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    
    DiningTableRecord4Cocoa *tableRecord = [[[DiningTableRecord4Cocoa alloc] init] autorelease];
    tableRecord.tableName = deskNumberTextField.textField.text;
    tableRecord.memo = remarkTextView.text;
    tableRecord.typeID = self.selectModelRecord.typeID;
    tableRecord.regionID = self.selectPositionRecord.regionID;
    tableRecord.sortIndex = 0;
    
    if (self.enumAddType == kJCHAddDeskTypeAdd) {
        tableRecord.tableID = [[[ServiceFactory sharedInstance] utilityService] generateID];
        [diningTableService addDiningTable:tableRecord];
    } else if (self.enumAddType == kJCHAddDeskTypeModify) {
        tableRecord.tableID = self.currentTableRecord.tableID;
        [diningTableService updateDiningTable:tableRecord];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end


