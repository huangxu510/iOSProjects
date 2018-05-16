//
//  JCHImportContactsRelationSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHImportContactsRelationSelectViewController.h"
#import "JCHImportContactTableSectionView.h"
#import "JCHImportContactsViewController.h"
#import "JCHImportContactRelationSelectTableViewCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"

@interface JCHImportContactsRelationSelectViewController () <UITableViewDelegate,
                                                            UITableViewDataSource,
                                                            JCHImportContactRelationSelectTableViewCellDelegate>
{
    UITableView *_contentTableView;
}

@property (nonatomic, retain) NSArray *dataSource;

@end

@implementation JCHImportContactsRelationSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"请选择关系";
    
    [self createUI];
    [self loadData];
}

- (void)dealloc
{
    [self.contactsList release];
    [self.dataSource release];
    [super dealloc];
}



- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *saveButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                               target:self
                                               action:@selector(handleSaveRecord)
                                                title:@"完成"
                                           titleColor:nil
                                      backgroundColor:nil];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:saveButton] autorelease];
    
    UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    flexSpacer.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[flexSpacer, editButtonItem];
    
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.sectionIndexColor = JCHColorMainBody;
    _contentTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [_contentTableView registerClass:[JCHImportContactRelationSelectTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - SaveRecord

- (void)handleSaveRecord
{
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    NSArray *allContacts = [contactsService queryAllContacts];
    
    for (NSInteger i = 1; i < self.dataSource.count; i++) {
        JCHImportContactRelationSelectTableViewCellData *data = self.dataSource[i];
        NSArray *relationshipVector = [self getRelationshipVector:data];
        if (relationshipVector.count == 0) {
            
            NSString *message = [NSString stringWithFormat:@"%@没有选择关系", data.name];
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                 message:message
                                                                delegate:nil
                                                       cancelButtonTitle:@"我知道了"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
    }
    
    
    for (NSInteger i = 1; i < self.dataSource.count; i++) {
        JCHImportContactRelationSelectTableViewCellData *data = self.dataSource[i];
        NSInteger index = [self.dataSource indexOfObject:data];
        JCHContactsInfo *contactInfo = self.contactsList[index - 1];
        NSArray *relationshipVector = [self getRelationshipVector:data];

        
        BOOL isExisting = NO;
        for (ContactsRecord4Cocoa *contactsRecord in allContacts) {
            if ([contactsRecord.name isEqualToString:contactInfo.name] && [contactsRecord.phone isEqualToString:contactInfo.phone]) {
                contactsRecord.relationshipVector = relationshipVector;
                [contactsService updateAccount:contactsRecord];
                isExisting = YES;
                break;
            }
        }
        
        if (!isExisting) {
            
            ContactsRecord4Cocoa *contactsRecord = [[[ContactsRecord4Cocoa alloc] init] autorelease];
            
            contactsRecord.contactUUID = [[[ServiceFactory sharedInstance] utilityService] generateUUID];
            contactsRecord.name = contactInfo.name;               // 联系人姓名
            contactsRecord.phone = contactInfo.phone;              // 联系电话
            contactsRecord.relationshipVector = relationshipVector; // 关系
            
            contactsRecord.company = contactInfo.company;            // 公司名字
            contactsRecord.gender = -1;
            contactsRecord.birthday = INT_MAX;
            [contactsService insertAccount:contactsRecord];
        }
    }
    
    [MBProgressHUD showResultCustomViewHUDWithTitle:@""
                                             detail:@"通讯录导入成功"
                                           duration:1.5
                                             result:YES
                                         completion:nil];
    UIViewController *viewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
    [self.navigationController popToViewController:viewController animated:YES];
}

- (NSArray *)getRelationshipVector:(JCHImportContactRelationSelectTableViewCellData *)data
{
    NSMutableArray *relationshipVector = [NSMutableArray array];
    if (data.clientButtonSelected) {
        [relationshipVector addObject:@"客户"];
    }
    if (data.supplierButtonSelected) {
        [relationshipVector addObject:@"供应商"];
    }
    if (data.colleagueButtonSelected) {
        [relationshipVector addObject:@"同事"];
    }
    return relationshipVector;
}

#pragma mark - LoadData

- (void)loadData
{
    NSMutableArray *dataSource = [NSMutableArray array];
    JCHImportContactRelationSelectTableViewCellData *data = [[[JCHImportContactRelationSelectTableViewCellData alloc] init] autorelease];
    data.name = @"全选";
    data.clientButtonSelected = NO;
    data.supplierButtonSelected = NO;
    data.colleagueButtonSelected = NO;
    [dataSource addObject:data];
    
    for (JCHContactsInfo *contactsInfo in self.contactsList) {
        
        JCHImportContactRelationSelectTableViewCellData *data = [[[JCHImportContactRelationSelectTableViewCellData alloc] init] autorelease];
        data.name = contactsInfo.name;
        data.clientButtonSelected = NO;
        data.supplierButtonSelected = NO;
        data.colleagueButtonSelected = NO;
        [dataSource addObject:data];
    }
    self.dataSource = dataSource;
    [_contentTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHImportContactRelationSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    JCHImportContactRelationSelectTableViewCellData *data = self.dataSource[indexPath.row];
    
    [cell setCellData:data];
    
    if (indexPath.row == 0) {
        [cell setTitleLabelColor:JCHColorHeaderBackground];
    } else {
        [cell setTitleLabelColor:JCHColorMainBody];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHImportContactTableSectionView *sectionView = [[[JCHImportContactTableSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)] autorelease];
    sectionView.backgroundColor = JCHColorGlobalBackground;
    [sectionView addSeparateLineWithFrameTop:NO bottom:YES];
    return sectionView;
}

#pragma mark - JCHImportContactRelationSelectTableViewCellDelegate

- (void)handleSelectCell:(JCHImportContactRelationSelectTableViewCell *)cell Relation:(UIButton *)button
{
    NSIndexPath *indexPath = [_contentTableView indexPathForCell:cell];
    JCHImportContactRelationSelectTableViewCellData *data = self.dataSource[indexPath.row];
    switch (button.tag) {
        case kJCHClientButtonTag:
        {
            data.clientButtonSelected = button.selected;
            
            //全选
            if (indexPath.row == 0) {
                for (NSInteger i = 1; i < self.dataSource.count; i++) {
                    JCHImportContactRelationSelectTableViewCellData *cellData = self.dataSource[i];
                    cellData.clientButtonSelected = button.selected;
                    
                }
            } else {
                if (data.clientButtonSelected == NO) {
                    JCHImportContactRelationSelectTableViewCellData *selectAllCellData = self.dataSource[0];
                    selectAllCellData.clientButtonSelected = NO;
                } else {
                    BOOL selectAll = YES;
                    for (NSInteger i = 1; i < self.dataSource.count; i++) {
                        JCHImportContactRelationSelectTableViewCellData *cellData = self.dataSource[i];
                        if (cellData.clientButtonSelected == NO) {
                            selectAll = NO;
                            break;
                        }
                    }
                    if (selectAll) {
                        JCHImportContactRelationSelectTableViewCellData *selectAllCellData = self.dataSource[0];
                        selectAllCellData.clientButtonSelected = YES;
                    }
                }

            }
        }
            break;
            
        case kJCHSupplierButtonTag:
        {
            data.supplierButtonSelected = button.selected;
            
            //全选
            if (indexPath.row == 0) {
                for (NSInteger i = 1; i < self.dataSource.count; i++) {
                    JCHImportContactRelationSelectTableViewCellData *cellData = self.dataSource[i];
                    cellData.supplierButtonSelected = button.selected;
                }
            } else {
                if (data.supplierButtonSelected == NO) {
                    JCHImportContactRelationSelectTableViewCellData *selectAllCellData = self.dataSource[0];
                    selectAllCellData.supplierButtonSelected = NO;
                } else {
                    BOOL selectAll = YES;
                    for (NSInteger i = 1; i < self.dataSource.count; i++) {
                        JCHImportContactRelationSelectTableViewCellData *cellData = self.dataSource[i];
                        if (cellData.supplierButtonSelected == NO) {
                            selectAll = NO;
                            break;
                        }
                    }
                    if (selectAll) {
                        JCHImportContactRelationSelectTableViewCellData *selectAllCellData = self.dataSource[0];
                        selectAllCellData.supplierButtonSelected = YES;
                    }
                }
                
            }

        }
            break;
            
        case kJCHColleagueButtonTag:
        {
            data.colleagueButtonSelected = button.selected;
            
            //全选
            if (indexPath.row == 0) {
                for (NSInteger i = 1; i < self.dataSource.count; i++) {
                    JCHImportContactRelationSelectTableViewCellData *cellData = self.dataSource[i];
                    cellData.colleagueButtonSelected = button.selected;
                    
                }
            } else {
                if (data.colleagueButtonSelected == NO) {
                    JCHImportContactRelationSelectTableViewCellData *selectAllCellData = self.dataSource[0];
                    selectAllCellData.colleagueButtonSelected = NO;
                } else {
                    BOOL selectAll = YES;
                    for (NSInteger i = 1; i < self.dataSource.count; i++) {
                        JCHImportContactRelationSelectTableViewCellData *cellData = self.dataSource[i];
                        if (cellData.colleagueButtonSelected == NO) {
                            selectAll = NO;
                            break;
                        }
                    }
                    if (selectAll) {
                        JCHImportContactRelationSelectTableViewCellData *selectAllCellData = self.dataSource[0];
                        selectAllCellData.colleagueButtonSelected = YES;
                    }
                }
                
            }

        }
            break;
            
        default:
            break;
    }
    
    [_contentTableView reloadData];
}



@end
