//
//  JCHGroupContactsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHGroupContactsViewController.h"
#import "JCHAddContactsViewController.h"
#import "JCHContactDetailViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHContactsTableViewCell.h"
#import "JCHItemListFooterView.h"
#import "UIView+JCHView.h"
#import "CommonHeader.h"
#import "UIImage+JCHImage.h"
#import "ServiceFactory.h"
#import "JCHPinYinUtility.h"
#import "JCHManifestMemoryStorage.h"
#import <Masonry.h>

@interface JCHGroupContactsViewController () <UISearchBarDelegate,
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                UISearchResultsUpdating,
                                                SWTableViewCellDelegate>
{
    JCHPlaceholderView *_placeholderView;
    UITableView *_contentTableView;
    UIButton *_editButton;
    NSInteger _currentGroupContactsTag;
    BOOL _selectMember; //从收银台进入的标记
}

@property (nonatomic, retain) UISearchController *searchController;
@property (nonatomic, retain) NSArray *searchResult;
@property (nonatomic, retain) NSMutableArray *groupContacts;
@property (nonatomic, retain) NSMutableArray *groupContactsWithSubSection;
@property (nonatomic, retain) NSArray *sectionIndexTitles;

@end

@implementation JCHGroupContactsViewController

- (instancetype)initWithType:(kJCHGroupContactsType)type selectMember:(BOOL)selectMember
{
    self = [super init];
    if (self) {
        _currentGroupContactsTag = type;
        _selectMember = selectMember;
        self.refreshUIAfterAutoSync = YES;
        if (type == kJCHGroupContactsClient) {
            self.title = @"客户";
        } else if (type == kJCHGroupContactsColleague) {
            self.title = @"同事";
        } else if (type == kJCHGroupContactsSupplier) {
            self.title = @"供应商";
        }
    }
    return self;
}

- (void)dealloc
{
    [self.searchController.view removeFromSuperview];
    [self.searchController release];
    [self.searchResult release];
    [self.groupContactsWithSubSection release];
    [self.sectionIndexTitles release];
    [self.groupContacts release];
    [self.balanceForContactUUID release];
    [self.sendValueBlock release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
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
    
    UIButton *addAccountBookButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                         target:self
                                                         action:@selector(handleAddContact)
                                                          title:nil
                                                     titleColor:nil
                                                backgroundColor:nil];
    [addAccountBookButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addAccountBookButton] autorelease];
    self.navigationItem.rightBarButtonItem = addItem;
    
    _placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    _placeholderView.hidden = YES;
    _placeholderView.imageView.image = [UIImage imageNamed:@"default_contacts_placeholder"];
    _placeholderView.label.text = @"暂无联系人,立即添加吧!";
    [self.view addSubview:_placeholderView];
    
    [_placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view).with.offset(-20);
    }];

    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //_contentTableView.tintColor = JCHColorMainBody;
    _contentTableView.sectionIndexColor = JCHColorMainBody;
    _contentTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    _contentTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.searchController = [[[UISearchController alloc] initWithSearchResultsController:nil] autorelease];
    
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
    }
    //[self.searchController.searchBar addSeparateLineWithFrameTop:NO bottom:YES];
    _contentTableView.tableHeaderView = self.searchController.searchBar;
    
    [_contentTableView registerClass:[JCHContactsTableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)handleAddContact
{
    JCHAddContactsViewController *addContactsVC = [[[JCHAddContactsViewController alloc] initWithContactsUUID:nil relationship:self.title] autorelease];
    [self.navigationController pushViewController:addContactsVC animated:YES];
}

#pragma mark - LoadData
- (void)loadData
{
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    NSArray *allContacts = [contactsService queryAllContacts];
    
    NSMutableArray *groupContacts = [NSMutableArray array];
    for (ContactsRecord4Cocoa *contactsRecord in allContacts) {
        if (_currentGroupContactsTag == kJCHGroupContactsClient && [contactsRecord.relationshipVector containsObject:@"客户"]) {
            
            [groupContacts addObject:contactsRecord];
        } else if (_currentGroupContactsTag == kJCHGroupContactsColleague && [contactsRecord.relationshipVector containsObject:@"同事"]) {
            
            [groupContacts addObject:contactsRecord];
        } else if (_currentGroupContactsTag == kJCHGroupContactsSupplier && [contactsRecord.relationshipVector containsObject:@"供应商"]) {
            
            [groupContacts addObject:contactsRecord];
        }
        contactsRecord.pinyin = [JCHPinYinUtility getFirstPinYinLetterForProductName:contactsRecord.name];
    }
    
    groupContacts = [NSMutableArray arrayWithArray:[groupContacts sortedArrayUsingComparator:^NSComparisonResult(ContactsRecord4Cocoa *obj1, ContactsRecord4Cocoa *obj2) {
        return [obj1.pinyin localizedCompare:obj2.pinyin];
    }]];
    
    self.groupContacts = [NSMutableArray arrayWithArray:groupContacts];
    
    self.groupContactsWithSubSection = [NSMutableArray arrayWithArray:[self subSectionAllContacts:self.groupContacts]];
    
    if (self.groupContactsWithSubSection.count == 0) {
        _placeholderView.hidden = NO;
        _contentTableView.hidden = YES;
    } else {
        _placeholderView.hidden = YES;
        _contentTableView.hidden = NO;
    }
    
    [_contentTableView reloadData];
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
    
    
    [allLetters insertObject:UITableViewIndexSearch atIndex:0];
    self.sectionIndexTitles = allLetters;
    
    return allSubSectionContacts;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active)
    {
        return 1;
    }
    return self.groupContactsWithSubSection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return self.searchResult.count;
    }

    return [self.groupContactsWithSubSection[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JCHContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    ContactsRecord4Cocoa *contactsRecord = nil;
    if (self.searchController.active) {
        contactsRecord = self.searchResult[indexPath.row];
    } else {
        contactsRecord = self.groupContactsWithSubSection[indexPath.section][indexPath.row];
        if (indexPath.section != self.groupContactsWithSubSection.count - 1) {
            [cell hideLastBottomLine:tableView indexPath:indexPath];
        } else {
            [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        }
    }
    
    CGFloat balance = 0.0;
#if 1
    if ([self.balanceForContactUUID objectForKey:contactsRecord.contactUUID] == nil) {
        id <ManifestService> manifestService = [[ServiceFactory sharedInstance] manifestService];
        balance = [manifestService queryCardBalance:contactsRecord.contactUUID];
        [self.balanceForContactUUID setObject:@(balance) forKey:contactsRecord.contactUUID];
    } else {
        balance = [[self.balanceForContactUUID objectForKey:contactsRecord.contactUUID] doubleValue];
    }
#endif
    JCHContactsTableViewCellData *data = [[[JCHContactsTableViewCellData alloc] init] autorelease];
    data.headImageName = nil;
    data.name = contactsRecord.name;
    data.companyName = contactsRecord.company;
    data.savingCardHidden = balance <= 0;
    
    [cell setData:data];
    return cell;

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.searchController.active) {
        return 28;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 28)] autorelease];
    sectionView.backgroundColor = JCHColorGlobalBackground;
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, kScreenWidth - 2 * kStandardLeftMargin, 28)
                                              title:@""
                                               font:[UIFont jchSystemFontOfSize:15.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    titleLabel.text = self.sectionIndexTitles[section + 1];
    
    [sectionView addSubview:titleLabel];
    
    [sectionView addSeparateLineWithFrameTop:YES bottom:YES];
    return sectionView;
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
    if (!self.searchController.active) {
        return self.sectionIndexTitles;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section = %ld", indexPath.section);
    if (tableView == _contentTableView) {
        
        ContactsRecord4Cocoa *contactsRecord = self.groupContactsWithSubSection[indexPath.section][indexPath.row];
        
        if (_selectMember) {
            if (self.sendValueBlock) {
                self.sendValueBlock(contactsRecord);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
            self.hidesBottomBarWhenPushed = YES;
            JCHContactDetailViewController *contactDetailVC = [[[JCHContactDetailViewController alloc] initWithContactUUID:contactsRecord.contactUUID] autorelease];
            [self.navigationController pushViewController:contactDetailVC animated:YES];
        }
    } else {
        
        ContactsRecord4Cocoa *contactsRecord = self.searchResult[indexPath.row];
        
        if (_selectMember) {
            
            if (self.sendValueBlock) {
                self.sendValueBlock(contactsRecord);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            
            self.hidesBottomBarWhenPushed = YES;
            JCHContactDetailViewController *contactDetailVC = [[[JCHContactDetailViewController alloc] initWithContactUUID:contactsRecord.contactUUID] autorelease];
            [self.navigationController pushViewController:contactDetailVC animated:YES];
        }
    }
}

#pragma mark - SWTableViewCellDelegate

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return NO;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.pinyin contains[c] %@", searchController.searchBar.text];
    [resultArray addObjectsFromArray:[self.groupContacts filteredArrayUsingPredicate:predicate]];
    
    predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchController.searchBar.text];
    [resultArray addObjectsFromArray:[self.groupContacts filteredArrayUsingPredicate:predicate]];
    
    self.searchResult = resultArray;
    [_contentTableView reloadData];
}


- (void)handlePopAction
{
    if (_selectMember) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
