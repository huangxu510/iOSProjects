//
//  JCHAddWarehouseViewController.m
//  jinchuhuo
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddWarehouseViewController.h"
#import "JCHGroupContactsViewController.h"
#import "JCHTitleArrowButton.h"
#import "JCHSwitchLabelView.h"
#import "JCHTitleTextField.h"
#import "JCHArrowTapView.h"
#import "ServiceFactory.h"
#import "CommonHeader.h"
#import "JCHTextView.h"
#import <Masonry.h>

@interface JCHAddWarehouseViewController ()<UITextViewDelegate>
{
    // 名称
    JCHTitleTextField *nameTextField;
    
    // 地址
    JCHTitleTextField *addressTextField;
    
    // 联系人
    JCHArrowTapView *contactButton;
    
    // 设为默认仓库
    JCHSwitchLabelView *defaultWarehouseSwitch;
    
    // 启用仓库
    JCHSwitchLabelView *enableWarehouseSwitch;
    
    // 备注
    JCHTextView *remarkTextView;
    
    // 操作模式
    enum WarehouseMode currentWarehouseMode;

}

@property (retain, nonatomic, readwrite) NSString *currentWarehouseID;
@property (retain, nonatomic, readwrite) ContactsRecord4Cocoa *currentContactsRecord;

@end

@implementation JCHAddWarehouseViewController

- (id)initWithWarehouseID:(NSString *)warehouseID controllerMode:(enum WarehouseMode)mode
{
    self = [super init];
    if (self) {
        
        currentWarehouseMode = mode;
        self.currentWarehouseID = warehouseID;
        
        if (kAddWarehouse == currentWarehouseMode) {
            self.title = @"添加仓库";
        } else if (kModifyWarehouse == currentWarehouseMode) {
            self.title = @"编辑仓库";
        } else {
            // pass
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.currentWarehouseID = nil;
    self.currentContactsRecord = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self loadData];
    
    return;
}

- (void)loadData
{
    if (currentWarehouseMode == kAddWarehouse) {
        
        nameTextField.textField.text = @"";
        addressTextField.textField.text = @"";
        contactButton.detailLabel.text = @"";
        
        defaultWarehouseSwitch.switchButton.on = YES;
//        enableWarehouseSwitch.switchButton.on = YES;
        remarkTextView.text = @"";
    } else if (currentWarehouseMode == kModifyWarehouse) {
        
        if (nil != self.currentWarehouseID && self.currentWarehouseID.longLongValue >= 0) {
            id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
            
            WarehouseRecord4Cocoa *currentWarehouseRecord = nil;
            NSArray* warehouseList = [warehouseService queryAllWarehouse];
            
            for (WarehouseRecord4Cocoa *record in warehouseList) {
                if ([record.warehouseID isEqualToString:self.currentWarehouseID]) {
                    currentWarehouseRecord = record;
                    break;
                }
            }
            
            if (nil != currentWarehouseRecord) {
                id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
                
                if (![currentWarehouseRecord.contactUUID isEmptyString]) {
                    self.currentContactsRecord = [contactsService queryContacts:currentWarehouseRecord.contactUUID];
                    contactButton.detailLabel.text = [NSString stringWithFormat:@"%@/%@", self.currentContactsRecord.name, self.currentContactsRecord.phone];
                }
                
                nameTextField.textField.text = currentWarehouseRecord.warehouseName;
                addressTextField.textField.text = currentWarehouseRecord.warehouseAddr;
                
                
                
                defaultWarehouseSwitch.switchButton.on = YES;
                enableWarehouseSwitch.switchButton.on = !currentWarehouseRecord.warehouseStatus;
                remarkTextView.text = currentWarehouseRecord.warehouseRemarks;
            }
        }
    } else {
        // pass
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI
{
    //
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    //
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveWarehouse:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0f];
    // 名称
    nameTextField = [[JCHTitleTextField alloc] initWithTitle:@"名称"
                                                        font:textFont
                                                 placeholder:@"请输入名称"
                                                   textColor:JCHColorMainBody];
    [self.backgroundScrollView addSubview:nameTextField];
    
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView.mas_top).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    {
        UIView *seperateLine = [JCHUIFactory createSeperatorLine:0];
        [nameTextField addSubview:seperateLine];
        
        [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.equalTo(nameTextField);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    
    // 地址
    addressTextField = [[JCHTitleTextField alloc] initWithTitle:@"地址"
                                                           font:textFont
                                                    placeholder:@"请输入地址"
                                                      textColor:JCHColorMainBody];
    [self.backgroundScrollView addSubview:addressTextField];
    
    [addressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameTextField.mas_bottom);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    // 联系人
    contactButton = [[[JCHArrowTapView alloc] initWithFrame:CGRectZero] autorelease];
    [self.backgroundScrollView addSubview:contactButton];
    contactButton.titleLabel.text = @"联系人";
    contactButton.titleLabel.font = textFont;
    contactButton.titleLabel.textColor = JCHColorMainBody;
    [contactButton.button addTarget:self
                             action:@selector(handleChooseContact:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:contactButton];
    
    [contactButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressTextField.mas_bottom);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    {
        UIView *seperateLine = [JCHUIFactory createSeperatorLine:0];
        [contactButton addSubview:seperateLine];
        
        [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(contactButton);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }

#if 0
    // 设为默认仓库
    defaultWarehouseSwitch = [[[JCHSwitchLabelView alloc] initWithFrame:CGRectZero] autorelease];
    [self.backgroundScrollView addSubview:defaultWarehouseSwitch];
    defaultWarehouseSwitch.switchButton.on = NO;
    defaultWarehouseSwitch.titleLabel.textColor = JCHColorMainBody;
    defaultWarehouseSwitch.titleLabel.font = textFont;
    defaultWarehouseSwitch.titleLabel.text = @"设为默认仓库";
    defaultWarehouseSwitch.backgroundColor = [UIColor whiteColor];
    [self.backgroundScrollView addSubview:defaultWarehouseSwitch];
    
    [defaultWarehouseSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contactButton.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    

    
    {
        UIView *seperateLine = [JCHUIFactory createSeperatorLine:0];
        [defaultWarehouseSwitch addSubview:seperateLine];
        
        [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.equalTo(defaultWarehouseSwitch);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }

    {
        UIView *seperateLine = [JCHUIFactory createSeperatorLine:0];
        [defaultWarehouseSwitch addSubview:seperateLine];
        
        [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(defaultWarehouseSwitch);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
#endif
    // 启用仓库
    enableWarehouseSwitch = [[[JCHSwitchLabelView alloc] initWithFrame:CGRectZero] autorelease];
    [self.backgroundScrollView addSubview:defaultWarehouseSwitch];
    enableWarehouseSwitch.switchButton.on = YES;
//    [enableWarehouseSwitch.switchButton addTarget:self action:@selector(setWarehouseStatus:) forControlEvents:UIControlEventValueChanged];
    enableWarehouseSwitch.titleLabel.textColor = JCHColorMainBody;
    enableWarehouseSwitch.titleLabel.font = textFont;
    enableWarehouseSwitch.titleLabel.text = @"启用仓库";
    enableWarehouseSwitch.backgroundColor = [UIColor whiteColor];
    [self.backgroundScrollView addSubview:enableWarehouseSwitch];
    
    [enableWarehouseSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contactButton.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    {
        UIView *seperateLine = [JCHUIFactory createSeperatorLine:0];
        [enableWarehouseSwitch addSubview:seperateLine];
        
        [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.equalTo(enableWarehouseSwitch);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }

    {
        UIView *seperateLine = [JCHUIFactory createSeperatorLine:0];
        [enableWarehouseSwitch addSubview:seperateLine];
        
        [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(enableWarehouseSwitch);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }

    // 备注
    UIView *remarkTopSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.backgroundScrollView addSubview:remarkTopSeperateLine];
    
    [remarkTopSeperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView.mas_left);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(enableWarehouseSwitch.mas_bottom).with.offset(kStandardSeparateViewHeight);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    CGFloat remarkTextViewMinHeight = kStandardItemHeight;
    remarkTextView = [[[JCHTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, remarkTextViewMinHeight)] autorelease];
    [self.backgroundScrollView addSubview:remarkTextView];
    
    remarkTextView.delegate = self;
    remarkTextView.textColor = JCHColorMainBody;
    remarkTextView.font = textFont;
    remarkTextView.placeholder = @"添加备注信息";
    remarkTextView.placeholderColor = UIColorFromRGB(0xd5d5d5);
    remarkTextView.isAutoHeight = YES;
    remarkTextView.minHeight = remarkTextViewMinHeight;

    [remarkTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView.mas_left);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(kStandardItemHeight);
        make.top.equalTo(remarkTopSeperateLine.mas_bottom);
    }];
    
    UIView *remarkBottomSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.backgroundScrollView addSubview:remarkBottomSeperateLine];
    
    [remarkBottomSeperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundScrollView.mas_left);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(remarkTextView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(remarkBottomSeperateLine.mas_bottom).with.offset(kStandardSeparateViewHeight);
    }];
    
    return;
}


- (void)handleChooseContact:(id)sender
{
    JCHGroupContactsViewController *viewController = [[[JCHGroupContactsViewController alloc] initWithType:kJCHGroupContactsColleague
                                             selectMember:YES] autorelease];
    WeakSelf;
    viewController.sendValueBlock = ^(ContactsRecord4Cocoa *contactsRecord) {
        [weakSelf setContactsRecord:contactsRecord];
    };
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [self presentViewController:navController animated:YES completion:nil];
    return;
}

- (void)setContactsRecord:(ContactsRecord4Cocoa *)contactsRecord
{
    self.currentContactsRecord = contactsRecord;
    contactButton.detailLabel.text = [NSString stringWithFormat:@"%@/%@",
                                      self.currentContactsRecord.name ? self.currentContactsRecord.name : @"",
                                      self.currentContactsRecord.phone ? self.currentContactsRecord.phone : @""];
}

- (void)handleSaveWarehouse:(id)sender
{
    if (nameTextField.textField.text == nil ||
        [nameTextField.textField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请填写仓库名称"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        
        
        return;
    }
    
    if (addressTextField.textField.text == nil ||
        [addressTextField.textField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请填写仓库地址"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        
        
        return;
    }
    

    if (nil == self.currentContactsRecord) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"请选择联系人"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        
        
        return;
    }
    

    //默认仓库不能禁用
    if ([self.currentWarehouseID isEqualToString:@"0"] && !enableWarehouseSwitch.switchButton.on) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"默认仓库不可禁用"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    
    WarehouseRecord4Cocoa *warehouseRecord = [[[WarehouseRecord4Cocoa alloc] init] autorelease];
    warehouseRecord.warehouseName = nameTextField.textField.text;
    warehouseRecord.warehouseAddr = addressTextField.textField.text;
    warehouseRecord.contactUUID = self.currentContactsRecord.contactUUID;
    warehouseRecord.warehouseRemarks = remarkTextView.text ? remarkTextView.text : @"";
    warehouseRecord.warehouseStatus = !enableWarehouseSwitch.switchButton.on;
    warehouseRecord.warehouseID = self.currentWarehouseID;
    id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
    
    if (currentWarehouseMode == kAddWarehouse) {
        
        //TODO: 之前本地insert的时候底层生成warehouseID ,现在insert之前要先向服务器强求添加，所以要上层生成warehouseID
        //需要调用生成uuid的接口
        warehouseRecord.warehouseID = [warehouseService generateWarehouseID];
        //添加仓库
//        [self doAddWarehouseToServer:warehouseRecord];
        [warehouseService insertWarehouse:warehouseRecord];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [warehouseService updateWarehouse:warehouseRecord];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return;
}


- (void)doAddWarehouseToServer:(WarehouseRecord4Cocoa *)warehouseRecord
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    WarehouseManageRequest *request = [[[WarehouseManageRequest alloc] init] autorelease];
    request.deviceUUID = statusManager.deviceUUID;
    request.token = statusManager.syncToken;
    request.accountBookID = statusManager.accountBookID;
    request.dataType = @"0";
    request.dataKey = warehouseRecord.warehouseID;
    request.serviceURL = [NSString stringWithFormat:@"%@/control/add", kJCHSyncManagerServerIP];
    
    
    id<DataSyncService> dataSyncService = [[ServiceFactory sharedInstance] dataSyncService];
    
    [dataSyncService addWarehouse:request callback:^(id response) {
        
        NSDictionary *userData = response;
        
        if (kJCHServiceSuccess == [userData[@"status"] integerValue]) {
            NSDictionary *responseData = userData[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                
                [MBProgressHUD showHUDWithTitle:@"添加失败"
                                         detail:responseDescription
                                       duration:kJCHDefaultShowHudTime
                                           mode:MBProgressHUDModeText
                                     completion:nil];
            } else {
                //添加成功
                
                id<WarehouseService> warehouseService = [[ServiceFactory sharedInstance] warehouseService];
                [warehouseService insertWarehouse:warehouseRecord];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            NSLog(@"request fail: %@", userData[@"data"]);
            
            [MBProgressHUD showNetWorkFailedHud:nil];
        }

    }];
}


@end
