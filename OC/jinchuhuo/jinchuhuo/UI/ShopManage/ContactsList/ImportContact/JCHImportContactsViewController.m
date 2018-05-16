//
//  JCHImportContactsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHImportContactsViewController.h"
#import "JCHImportContactsRelationSelectViewController.h"
#import "JCHImportContactTableViewCell.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import "JCHPinYinUtility.h"
#import <AddressBook/AddressBook.h>

@implementation JCHContactsInfo

- (void)dealloc
{
    [self.name release];
    [self.phone release];
    [self.company release];
    [self.pinyin release];
    [super dealloc];
}

@end

@interface JCHImportContactsViewController () <UITableViewDelegate,
                                                UITableViewDataSource,
                                                UISearchResultsUpdating>
{
    UITableView *_contentTableView;
    BOOL _selectAll;
}

@property (nonatomic, retain) NSArray *allContacts;
@property (nonatomic, retain) NSArray *allContactsWithSubSection;
@property (nonatomic, retain) NSArray *sectionIndexTitles;
@property (nonatomic, retain) UISearchController *searchController;
@property (nonatomic, retain) NSArray *searchResult;

@end

@implementation JCHImportContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择联系人";
    [self createUI];
    [self loadData];
}

- (void)dealloc
{
    [self.searchController.view removeFromSuperview];
    [self.allContacts release];
    [self.allContactsWithSubSection release];
    [self.sectionIndexTitles release];
    [self.searchController release];
    [self.searchResult release];
    
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
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
    _contentTableView.allowsMultipleSelection = YES;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [_contentTableView registerClass:[JCHImportContactTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    
    self.searchController = [[[UISearchController alloc] initWithSearchResultsController:nil] autorelease];
    //self.searchController.searchBar.frame=CGRectMake(100, 10, 200, 44);
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    //! @brief调整searchBar样式
    {
        //开始搜索后的背景色
        self.searchController.searchBar.barTintColor = JCHColorGlobalBackground;
        self.searchController.searchBar.translucent = NO;
        
        //searchBar 内部的textField
        UITextField *textField = [[[self.searchController.searchBar.subviews firstObject] subviews] lastObject];
        textField.backgroundColor = JCHColorGlobalBackground;
        textField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"请输入联系人信息"
                                                                           attributes:@{NSForegroundColorAttributeName : JCHColorAuxiliary}] autorelease];
        //背景色
        self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
        
        //开始搜索后取消按钮的颜色
        self.searchController.searchBar.tintColor = JCHColorAuxiliary;
        self.searchController.searchBar.showsCancelButton = NO;
        
        //更改cancel为取消
        for(UIView *view in  [[[self.searchController.searchBar subviews] objectAtIndex:0] subviews]) {
            if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
                UIButton * cancel =(UIButton *)view;
                [cancel setTitle:@"取消" forState:UIControlStateNormal];
            }
        }
        
        [self.searchController.searchBar sizeToFit];
        [self.searchController.searchBar addSeparateLineWithMasonryTop:NO bottom:YES];
    }
   
    _contentTableView.tableHeaderView = self.searchController.searchBar;
}


#pragma mark - SaveRecord

- (void)handleSaveRecord
{
    if (self.searchController.active) {
        self.searchController.active = NO;
    }
    NSMutableArray *selectedContacts = [NSMutableArray array];
    for (JCHContactsInfo *contactsInfo in self.allContacts) {
        
        if (contactsInfo.selected) {
            [selectedContacts addObject:contactsInfo];
        }
    }
    JCHImportContactsRelationSelectViewController *viewController = [[[JCHImportContactsRelationSelectViewController alloc] init] autorelease];
    viewController.contactsList = selectedContacts;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - LoadData

//读取通讯录
- (void)loadData
{
    ABAddressBookRef addressBokRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    //还没有申请权限
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBokRef, ^(bool granted, CFErrorRef error) {
            
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            [self copyAddressBook:addressBook];
            CFRelease(addressBook);
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        //已经获取权限
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
        CFRelease(addressBook);
    } else {
        
        //没有获取通讯录权限
        NSLog(@"没有获得通讯录权限");
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"没有获取您的通讯录权限，请在手机设置中打开权限"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    CFRelease(addressBokRef);
}

- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *contactsList = [NSMutableArray array];
    
    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        //名
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        
        //姓
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        //读取organization公司
        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
        
    
        
        JCHContactsInfo *contactsInfo = [[[JCHContactsInfo alloc] init] autorelease];
        contactsInfo.name = [NSString stringWithFormat:@"%@%@", [self processTheParameter:lastName], [self processTheParameter:firstName]];
        contactsInfo.company = organization;
        contactsInfo.phone = personPhone;
        contactsInfo.pinyin = [JCHPinYinUtility getFirstPinYinLetterForProductName:contactsInfo.name];
        contactsInfo.selected = NO;
        
        if (![contactsInfo.name isEmptyString]) {
            [contactsList addObject:contactsInfo];
        }
        

        CFRelease(phone);
    }
    CFRelease(people);
    NSArray *allContacts = [contactsList sortedArrayUsingComparator:^NSComparisonResult(ContactsRecord4Cocoa *obj1, ContactsRecord4Cocoa *obj2) {
        return [obj1.pinyin localizedCompare:obj2.pinyin];
    }];
    self.allContacts = allContacts;
    
    self.allContactsWithSubSection  = [self subSectionAllContacts:allContacts];
    
    //全选cell
    JCHContactsInfo *contactsInfo = [[[JCHContactsInfo alloc] init] autorelease];
    contactsInfo.name = @"全选";
    contactsInfo.selected = NO;
    NSMutableArray *array = [NSMutableArray arrayWithObject:@[contactsInfo]];
    [array addObjectsFromArray:self.allContactsWithSubSection];
    self.allContactsWithSubSection = array;
    
    //第一次申请通讯录权限的时候，tableView不刷新，所以延迟刷新一下
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_contentTableView reloadData];
    });
}

- (NSMutableArray *)subSectionAllContacts:(NSArray *)allContacts
{
    NSMutableArray *allLetters = [NSMutableArray array];
    
    for (ContactsRecord4Cocoa *contactsRecord in allContacts) {
        
        NSString *firstLetter = [contactsRecord.pinyin substringToIndex:1];
        if (contactsRecord == allContacts[0]) {
            [allLetters addObject:firstLetter];
        } else if (![allLetters.lastObject isEqualToString:firstLetter]) {
            [allLetters addObject:firstLetter];
        }
    }
    
    
    NSMutableArray *allSubSectionContacts = [NSMutableArray array];
    for (NSString *letter in allLetters) {
        
        NSMutableArray *subSectionContacts = [NSMutableArray array];
        
        for (ContactsRecord4Cocoa *contactsRecord in allContacts) {
            
            NSString *firstLetter = [contactsRecord.pinyin substringToIndex:1];
            if ([letter isEqualToString:firstLetter]) {
                [subSectionContacts addObject:contactsRecord];
            }
        }
        [allSubSectionContacts addObject:subSectionContacts];
    }
    
    
    //[allLetters insertObject:@"" atIndex:0];
    [allLetters insertObject:UITableViewIndexSearch atIndex:0];
    self.sectionIndexTitles = allLetters;
    
    return allSubSectionContacts;
}


- (NSString *)processTheParameter:(NSString *)parameter
{
    if (parameter) {
        return parameter;
    } else {
        return @"";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return 1;
    } else {
        return self.allContactsWithSubSection.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return self.searchResult.count;
    } else {
        return [self.allContactsWithSubSection[section] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHImportContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    JCHContactsInfo *contactsInfo = nil;
    if (self.searchController.active) {
        contactsInfo = self.searchResult[indexPath.row];
    } else {
        contactsInfo = self.allContactsWithSubSection[indexPath.section][indexPath.row];
    }
    
    cell.titleLabel.text = contactsInfo.name;
    
    if (indexPath.section == 0 && !self.searchController.active) {
        cell.titleLabel.textColor = JCHColorHeaderBackground;
    } else {
        cell.titleLabel.textColor = JCHColorMainBody;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    [cell setCheckMarkSelected:contactsInfo.selected];

    
    [cell hideLastBottomLine:tableView indexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return 0;
    } else {
        if (section == 0) {
            return 0;
        } else {
            return 28;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return nil;
    } else {
        
        UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 28)] autorelease];
        sectionView.backgroundColor = JCHColorGlobalBackground;
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth - 2 * kStandardLeftMargin, 28)
                                                  title:@""
                                                   font:[UIFont jchSystemFontOfSize:15.0f]
                                              textColor:JCHColorMainBody
                                                 aligin:NSTextAlignmentLeft];
        
        //titleLabel.text = @[@"", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L"][section];
//        titleLabel.text = self.sectionIndexTitles[section + 1];
        titleLabel.text = self.sectionIndexTitles[section];
        [sectionView addSubview:titleLabel];
        
        [sectionView addSeparateLineWithFrameTop:YES bottom:YES];
        return sectionView;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index == 0) {
        [tableView scrollRectToVisible:CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height) animated:NO];
    }
    return index - 1;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return nil;
    } else {
        if (self.sectionIndexTitles.count < 3) {
            return nil;
        }
        return self.sectionIndexTitles;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JCHImportContactTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    JCHContactsInfo *contactsInfo = nil;
    if (self.searchController.active) {
        contactsInfo = self.searchResult[indexPath.row];
    } else {
        contactsInfo = self.allContactsWithSubSection[indexPath.section][indexPath.row];
    }
    
    
    JCHContactsInfo *selectAllContactsInfo = self.allContactsWithSubSection[0][0];
    if (indexPath.section == 0 && !self.searchController.active) {
        selectAllContactsInfo.selected = !selectAllContactsInfo.selected;
        [self handleSelectAll:selectAllContactsInfo];
    } else {
        contactsInfo.selected = !contactsInfo.selected;
        [cell setCheckMarkSelected:contactsInfo.selected];
        
        if (contactsInfo.selected == NO) {
            _selectAll = NO;
            selectAllContactsInfo.selected = NO;
            JCHImportContactTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell setCheckMarkSelected:NO];
        } else {
            BOOL selectAll = YES;
            for (NSInteger i = 1; i < self.allContactsWithSubSection.count; i++) {
                NSArray *subSection = self.allContactsWithSubSection[i];
                for (NSInteger j = 0; j < subSection.count; j++) {
                    JCHContactsInfo *contactsInfo = subSection[j];
                    if (contactsInfo.selected == NO) {
                        selectAll = NO;
                        break;
                    }
                }
            }
            
            if (selectAll) {
                selectAllContactsInfo.selected = YES;
                JCHImportContactTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setCheckMarkSelected:YES];
            }
        }
    }
}


- (void)handleSelectAll:(JCHContactsInfo *)selectAllContactsInfo
{
    _selectAll = selectAllContactsInfo.selected;
    for (NSInteger i = 1; i < self.allContactsWithSubSection.count; i++) {
        NSArray *subSection = self.allContactsWithSubSection[i];
        for (NSInteger j = 0; j < subSection.count; j++) {
            JCHContactsInfo *contactsInfo = subSection[j];
            contactsInfo.selected = selectAllContactsInfo.selected;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            JCHImportContactTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:indexPath];
            [cell setCheckMarkSelected:contactsInfo.selected];
        }
    }
    [_contentTableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.pinyin contains[c] %@", searchController.searchBar.text];
    [resultArray addObjectsFromArray:[self.allContacts filteredArrayUsingPredicate:predicate]];
    
    predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchController.searchBar.text];
    [resultArray addObjectsFromArray:[self.allContacts filteredArrayUsingPredicate:predicate]];
    
    resultArray = [resultArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
    self.searchResult = resultArray;
    
    [_contentTableView reloadData];
}

@end
