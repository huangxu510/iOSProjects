//
//  JCHDeskPositionListViewController.m
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDeskPositionListViewController.h"
#import "JCHAddDeskPositionViewController.h"
#import "JCHSeparateLineSectionView.h"
#import "ServiceFactory.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHItemListFooterView.h"
#import "Masonry.h"
#import "CommonHeader.h"

#import "JCHItemListTableViewCell.h"

@interface JCHDeskPositionListViewController () <JCHItemListFooterViewDelegate, UIAlertViewDelegate>
{
    UITableView *contentTableView;
    JCHItemListFooterView *footerView;
    UIButton *editButton;
    UIImageView *defaultImageView;
    JCHDeskPositionListType currentType;
}

@property (retain, nonatomic, readwrite) NSMutableArray *regionRecordArray;


@end

@implementation JCHDeskPositionListViewController

- (instancetype)initWithType:(JCHDeskPositionListType)type
{
    self = [super init];
    if (self) {
        self.title = @"区域";
        currentType = type;
    }
    
    return self;
}


- (void)dealloc
{
    [self.regionRecordArray release];
    [self.sendValueBlock release];
    [self.selectPositionRecord release];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadCategoryData];
    contentTableView.editing = NO;
    editButton.selected = NO;
    [footerView setData:self.regionRecordArray.count];
    
    for (NSInteger i = 0; i < self.regionRecordArray.count; i++) {
        TableRegionRecord4Cocoa *regionRecord = self.regionRecordArray[i];
        if (currentType == kJCHDeskPositionListTypeSelect && [regionRecord.regionType isEqualToString:self.selectPositionRecord.regionType]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    if (currentType == kJCHDeskPositionListTypeNormal) {
        editButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                         target:self
                                         action:@selector(handleEditMode:)
                                          title:@"编辑"
                                     titleColor:nil
                                backgroundColor:nil];
        [editButton setTitle:@"取消" forState:UIControlStateSelected];
        editButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:editButton] autorelease];
        
        UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:self
                                                                                    action:nil] autorelease];
        flexSpacer.width = -10;
        
        self.navigationItem.rightBarButtonItems = @[flexSpacer, editButtonItem];
    }
    
    
    defaultImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_kinds_default"]] autorelease];
    defaultImageView.hidden = YES;
    //    defaultImageView.frame = CGRectMake(0, 0, 245, 41);
    [self.view addSubview:defaultImageView];
    
    [defaultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(245);
        make.height.mas_equalTo(41);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).with.offset(-20);
    }];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.tableHeaderView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    contentTableView.backgroundColor = JCHColorGlobalBackground;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.allowsMultipleSelectionDuringEditing = YES;
    contentTableView.tintColor = UIColorFromRGB(0x4c8cdf);
    [contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-49);
    }];
    
    footerView = [[[JCHItemListFooterView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 49, kScreenWidth, 49)] autorelease];
    footerView.categoryName = @"区域";
    footerView.categoryUnit = @"种";
    footerView.delegate = self;
    [self.view addSubview:footerView];
    
    return;
}


- (void)loadCategoryData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *regionRecordArray = [diningTableService queryTableRegion];
        self.regionRecordArray = [NSMutableArray arrayWithArray:regionRecordArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.regionRecordArray.count == 0)
            {
                contentTableView.hidden = YES;
                editButton.hidden = YES;
                defaultImageView.hidden = NO;
            }
            else
            {
                contentTableView.hidden = NO;
                editButton.hidden = NO;
                defaultImageView.hidden = YES;
            }
            [contentTableView reloadData];
            [footerView setData:self.regionRecordArray.count];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        });
    });
    
    return;
}


- (void)handleEditMode:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [footerView changeUI:contentTableView.isEditing];
    [contentTableView setEditing:!contentTableView.isEditing animated:YES];
    if (!contentTableView.isEditing) {
        [footerView setData:self.regionRecordArray.count];
    }else {
        NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
        [footerView setData:selectedIndexPaths.count];
    }
}


- (void)handleDeleteCategory:(NSIndexPath *)indexPath
{
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    TableRegionRecord4Cocoa *currentRegion = [self.regionRecordArray objectAtIndex:indexPath.row];
    NSArray *allTableList = [diningTableService queryDiningTable];
    BOOL findTable = NO;
    for (DiningTableRecord4Cocoa *table in allTableList) {
        if (table.regionID == currentRegion.regionID) {
            findTable = YES;
            break;
        }
    }
    
    if (YES == findTable) {
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"当前区域有关联桌台，不能删除"
                               duration:3
                                   mode:MBProgressHUDModeText
                             completion:nil];
        
        return;
    }
    
    [diningTableService deleteTableRegion:currentRegion.regionID];
    [self loadCategoryData];
    [footerView setData:self.regionRecordArray.count];
    
    
    return;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.regionRecordArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellReuseTag = @"kCellReuseTag";
    JCHItemListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseTag];
    if (nil == cell) {
        cell = [[[JCHItemListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseTag] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.textLabel.textColor = JCHColorMainBody;
        if (currentType == kJCHDeskPositionListTypeSelect) {
            cell.autoHiddenArrowImageViewWhileEditing = NO;
            cell.arrowImageView.hidden = YES;
        } else if (currentType == kJCHDeskPositionListTypeNormal) {
            cell.autoHiddenArrowImageViewWhileEditing = YES;
            cell.arrowImageView.hidden = NO;
        }
    }
    
    //每段最后一行的底线与左侧边无间隔
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    // WeakSelf;
    [cell setGoTopBlock:^(JCHItemListTableViewCell *cell) {
        // pass
    }];
    TableRegionRecord4Cocoa *record = [self.regionRecordArray objectAtIndex:indexPath.row];
    cell.textLabel.text = record.regionType;
    if (currentType == kJCHDeskPositionListTypeSelect && [record.regionType isEqualToString:self.selectPositionRecord.regionType]) {
        cell.selectImageView.hidden = NO;
    } else {
        cell.selectImageView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contentTableView.isEditing) {
        
        //取消选中 变为 全选
        [footerView setButtonSelected:NO];
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
        
        if ([contentTableView indexPathsForSelectedRows].count == self.regionRecordArray.count) {
            [footerView setButtonSelected:YES];
        }
    }
    else
    {
        TableRegionRecord4Cocoa *regionRecord = [self.regionRecordArray objectAtIndex:indexPath.row];
        
        if (currentType == kJCHDeskPositionListTypeSelect) {
            for (NSInteger i = 0; i < self.regionRecordArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                JCHItemListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.selectImageView.hidden = YES;
            }
            JCHItemListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectImageView.hidden = NO;
            self.sendValueBlock(regionRecord);
            [self.navigationController popViewControllerAnimated:YES];
        } else if (currentType == kJCHDeskPositionListTypeNormal) {
            
            JCHAddDeskPositionViewController *addController = [[[JCHAddDeskPositionViewController alloc] initWithTitle:@"修改区域"] autorelease];
            addController.tableRegionRecord = regionRecord;
            addController.addRegionType = kJCHAddDeskPositionTypeModifyCategory;
            [self.navigationController pushViewController:addController animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contentTableView.isEditing) {
        
        [footerView setButtonSelected:NO];
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self handleDeleteCategory:indexPath];
    }
}

#pragma mark - JCHItemListFooterViewDelegate
- (void)addItem
{
    WeakSelf;
    JCHAddDeskPositionViewController *addController = [[[JCHAddDeskPositionViewController alloc] initWithTitle:@"添加区域"] autorelease];
    if (self.sendValueBlock) {
        [addController setSendValueBlock:^(NSString *categoryName) {
            [weakSelf sendRecord:categoryName];
        }];
    }
    
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)sendRecord:(NSString *)regionType
{
    //由于传过来的record的uuid和保存之后的uuid不一样，所以这里要根据名字重新查询该record
    id<DiningTableService> diningTableService = [[ServiceFactory sharedInstance] diningTableService];
    NSArray *allRegionArray = [diningTableService queryTableRegion];
    
    for (TableRegionRecord4Cocoa *regionRecord in allRegionArray) {
        if ([regionRecord.regionType isEqualToString:regionType]) {
            if (self.sendValueBlock) {
                self.sendValueBlock(regionRecord);
            }
            break;
        }
    }
}

- (void)deleteItems
{
    
}

- (void)selectAll:(UIButton *)button
{
    if (button.selected) {
        //取消选中
        [contentTableView reloadData];
    }
    else
    {
        //选中所有
        for (NSInteger i = 0; i < self.regionRecordArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    //刷新footerView数据
    [footerView setData:[contentTableView indexPathsForSelectedRows].count];
}


@end


