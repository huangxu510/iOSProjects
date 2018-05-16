//
//  JCHAllContactsViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAllContactsViewController.h"
#import "JCHImportContactsViewController.h"
#import "JCHAddContactsViewController.h"
#import "JCHGroupContactsViewController.h"
#import "JCHContactDetailViewController.h"
#import "JCHMenuView.h"
#import "JCHContactsTableViewCell.h"
#import "JCHContactsTopTableViewCell.h"
#import "CommonHeader.h"
#import "UIImage+JCHImage.h"
#import "UIView+JCHView.h"
#import "ServiceFactory.h"
#import "JCHPinYinUtility.h"
#import <Masonry.h>

static NSString *const kJCHContactsTableViewCellResuseID = @"JCHContactsTableViewCell";
static NSString *const kJCHContactsTopTableViewCellResuseID = @"JCHContactsTopTableViewCell";

@interface JCHAllContactsViewController () <UISearchBarDelegate,
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            JCHContactTopTableViewCellDelegate,
                                            UISearchResultsUpdating,
                                            JCHMenuViewDelegate,
                                            SWTableViewCellDelegate>
{
    JCHPlaceholderView *_placeholderView;
    UITableView *_contentTableView;
}
@property (nonatomic, retain) UISearchController *searchController;
@property (nonatomic, retain) NSArray *searchResult;

//所有联系人
@property (nonatomic, retain) NSMutableArray *allContacts;

//所有联系人(分组)(二维数组)
@property (nonatomic, retain) NSMutableArray *allContactsWithSubSection;
@property (nonatomic, retain) NSArray *sectionIndexTitles;

@property (nonatomic, retain) NSMutableDictionary *balanceForContactUUID;

@end

@implementation JCHAllContactsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.title = @"通讯录";
        self.balanceForContactUUID = [NSMutableDictionary dictionary];
    }
    return self;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_contentTableView deselectRowAtIndexPath:[_contentTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)dealloc
{
    [self.searchController.view removeFromSuperview];
    [self.allContactsWithSubSection release];
    [self.searchController release];
    [self.searchResult release];
    [self.sectionIndexTitles release];
    [self.allContacts release];
    [self.balanceForContactUUID release];
    
    [super dealloc];
}


- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *addAccountBookButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                         target:self
                                                         action:@selector(showTopMenuView)
                                                          title:nil
                                                     titleColor:nil
                                                backgroundColor:nil];
    [addAccountBookButton setImage:[UIImage imageNamed:@"icon_account_add"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addAccountBookButton] autorelease];
    
    UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil] autorelease];
    flexSpacer.width = -5;
    self.navigationItem.rightBarButtonItems = @[flexSpacer, addItem];
    
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
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
    [self.searchController.searchBar addSeparateLineWithFrameTop:NO bottom:YES];
    
    _contentTableView.tableHeaderView = self.searchController.searchBar;
    
    [_contentTableView registerClass:[JCHContactsTableViewCell class] forCellReuseIdentifier:kJCHContactsTableViewCellResuseID];
    [_contentTableView registerClass:[JCHContactsTopTableViewCell class] forCellReuseIdentifier:kJCHContactsTopTableViewCellResuseID];
}

#pragma mark - LoadData
- (void)loadData
{
    id <ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    
    NSArray *allContacts = [contactsService queryAllContacts];
    
    NSInteger clientCount = 0;
    NSInteger supplierCount = 0;
    NSInteger colleagueCount = 0;
    
    for (ContactsRecord4Cocoa *contactsRecord in allContacts) {
        if ([contactsRecord.relationshipVector containsObject:@"客户"]) {
            clientCount++;
        }
        if ([contactsRecord.relationshipVector containsObject:@"供应商"]) {
            supplierCount++;
        }
        if ([contactsRecord.relationshipVector containsObject:@"同事"]) {
            colleagueCount++;
        }
        
        contactsRecord.pinyin = [JCHPinYinUtility getFirstPinYinLetterForProductName:contactsRecord.name];
    }
    
    allContacts = [allContacts sortedArrayUsingComparator:^NSComparisonResult(ContactsRecord4Cocoa *obj1, ContactsRecord4Cocoa *obj2) {
        return [obj1.pinyin localizedCompare:obj2.pinyin];
    }];
    
    self.allContacts = [NSMutableArray arrayWithArray:allContacts];
    
    JCHContactsTopTableViewCellData *topCellData = [[[JCHContactsTopTableViewCellData alloc] init] autorelease];
    topCellData.clientCount = clientCount;
    topCellData.supplierCount = supplierCount;
    topCellData.colleagueCount = colleagueCount;
    

    
    self.allContactsWithSubSection = [NSMutableArray arrayWithObject:topCellData];
    [self.allContactsWithSubSection addObjectsFromArray:[self subSectionAllContacts:allContacts]];
    
    if (self.allContactsWithSubSection.count == 1) {
        _contentTableView.hidden = YES;
        _placeholderView.hidden = NO;
    } else {
        _contentTableView.hidden = NO;
        _placeholderView.hidden = YES;
    }
    
    [_contentTableView reloadData];
}

#if 1
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
    
    [allLetters insertObject:@"" atIndex:0];
    [allLetters insertObject:UITableViewIndexSearch atIndex:0];
    self.sectionIndexTitles = allLetters;

    return allSubSectionContacts;
}
#endif

- (void)showTopMenuView
{
    CGFloat menuWidth = 110;
    CGFloat rowHeight = 44;
    JCHMenuView *topMenuView = [[[JCHMenuView alloc] initWithTitleArray:@[@"新建联系人", @"通讯录导入"]
                                                             imageArray:nil
                                                                 origin:CGPointMake(kScreenWidth - menuWidth - kStandardLeftMargin, 64)
                                                                  width:menuWidth
                                                              rowHeight:rowHeight
                                                              maxHeight:CGFLOAT_MAX
                                                                 Direct:kRightTriangle] autorelease];
    topMenuView.delegate = self;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:topMenuView];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active)
    {
        return 1;
    }
    return self.allContactsWithSubSection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return self.searchResult.count;
    }
    
    if (section == 0) {
        return 1;
    }
    //NSArray *arr = self.dataSource[section];
    //return 5;
    return [self.allContactsWithSubSection[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0 && !self.searchController.active) {
        
        JCHContactsTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHContactsTopTableViewCellResuseID forIndexPath:indexPath];
        [cell hideLastBottomLine:tableView indexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        JCHContactsTopTableViewCellData *data = self.allContactsWithSubSection[indexPath.section];
        [cell setCellData:data];
        return cell;
    } else {
        
        JCHContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJCHContactsTableViewCellResuseID forIndexPath:indexPath];
        cell.delegate = self;
        ContactsRecord4Cocoa *contactsRecord = nil;
        if (!self.searchController.active) {
            contactsRecord = self.allContactsWithSubSection[indexPath.section][indexPath.row];
            if (indexPath.section != self.allContactsWithSubSection.count - 1) {
                [cell hideLastBottomLine:tableView indexPath:indexPath];
            } else {
                 [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
            }
        } else {
            contactsRecord = self.searchResult[indexPath.row];
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

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.searchController.active) {
        if (indexPath.section == 0) {
            return 118.0f;
        } else {
            return 66.0f;
        }
    }
    return 66.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active || section == 0) {
        return 0;
    }
    return 28;
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
    
    //titleLabel.text = @[@"", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L"][section];
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
        if (self.sectionIndexTitles.count < 3) {
            return nil;
        }
        return self.sectionIndexTitles;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidesBottomBarWhenPushed = YES;
    
    ContactsRecord4Cocoa *contactsRecord = nil;
    if (self.searchController.active) {
        contactsRecord = self.searchResult[indexPath.row];
    } else {
        if (indexPath.section == 0) {
            return;
        }
        contactsRecord = self.allContactsWithSubSection[indexPath.section][indexPath.row];
    }

    JCHContactDetailViewController *contactDetailVC = [[[JCHContactDetailViewController alloc] initWithContactUUID:contactsRecord.contactUUID] autorelease];
    [self.navigationController pushViewController:contactDetailVC animated:YES];
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
    [resultArray addObjectsFromArray:[self.allContacts filteredArrayUsingPredicate:predicate]];
    
    predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchController.searchBar.text];
    [resultArray addObjectsFromArray:[self.allContacts filteredArrayUsingPredicate:predicate]];
    
    self.searchResult = resultArray;
    [_contentTableView reloadData];
}


#pragma mark - JCHContactTopTableViewCellDelegate

- (void)handleSwitchToGroupList:(JCHContactTopViewButton *)cell button:(UIButton *)button
{
    NSLog(@"buttonTag = %ld", button.tag);
    self.hidesBottomBarWhenPushed = YES;
    JCHGroupContactsViewController *groupContactsVC = [[[JCHGroupContactsViewController alloc] initWithType:button.tag selectMember:NO] autorelease];
    groupContactsVC.balanceForContactUUID = self.balanceForContactUUID;
    [self.navigationController pushViewController:groupContactsVC animated:YES];
}

#pragma mark - JCHMenuViewDelegate

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        self.hidesBottomBarWhenPushed = YES;
        JCHAddContactsViewController *addContactVC = [[[JCHAddContactsViewController alloc] initWithContactsUUID:nil relationship:nil] autorelease];
        [self.navigationController pushViewController:addContactVC animated:YES];
    } else if (indexPath.row == 1) {
        
        self.hidesBottomBarWhenPushed = YES;
        JCHImportContactsViewController *importContactsVC = [[[JCHImportContactsViewController alloc] init] autorelease];
        [self.navigationController pushViewController:importContactsVC animated:YES];
    }
}





@end
