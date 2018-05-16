//
//  JCHContactsRelationSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHContactsRelationSelectViewController.h"
#import "JCHAddContactsViewController.h"
#import "CommonHeader.h"
#import "ServiceFactory.h"
#import <Masonry.h>

@interface JCHContactsRelationSelectViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
}
@property (nonatomic, retain) NSArray *availableRelationship;
@property (nonatomic, retain) NSArray *currentRelationship;
@end

@implementation JCHContactsRelationSelectViewController

- (instancetype)initWithCurrentRelationship:(NSArray *)currentRelationship
{
    self = [super init];
    if (self) {
        self.title = @"关系";
        self.currentRelationship = currentRelationship;
    }
    return self;
}

- (void)dealloc
{
    [self.availableRelationship release];
    [self.currentRelationship release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self loadData];
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
    //_contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //_contentTableView.tintColor = JCHColorMainBody;
    _contentTableView.sectionIndexColor = JCHColorMainBody;
    _contentTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    _contentTableView.allowsMultipleSelection = YES;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [_contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - LoadData
- (void)loadData
{
    id<ContactsService> contactsService = [[ServiceFactory sharedInstance] contactsService];
    self.availableRelationship = [contactsService getAvailableRelationship];
}

- (void)handleSaveRecord
{
    NSArray *selectedIndexPaths = [_contentTableView indexPathsForSelectedRows];
    
    
    NSMutableArray *selectedRelationship = [NSMutableArray array];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [selectedRelationship addObject:self.availableRelationship[indexPath.row]];
    }
    JCHAddContactsViewController *addContactsVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    addContactsVC.currentRelationship = selectedRelationship;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.availableRelationship.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = self.availableRelationship[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (NSString *relationship in self.currentRelationship) {
        if ([relationship isEqualToString:self.availableRelationship[indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
