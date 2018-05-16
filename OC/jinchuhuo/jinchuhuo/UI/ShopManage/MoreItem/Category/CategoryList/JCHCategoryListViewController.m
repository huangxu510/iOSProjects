//
//  JCHCategoryListViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHCategoryListViewController.h"
#import "JCHAddCategoryViewController.h"
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

@interface JCHCategoryListViewController () <JCHItemListFooterViewDelegate, UIAlertViewDelegate>
{
    UITableView *contentTableView;
    JCHItemListFooterView *footerView;
    UIButton *editButton;
    UIImageView *defaultImageView;
    JCHCategoryListType currentType;
}

@property (retain, nonatomic, readwrite) NSMutableArray *categoryRecordArray;


@end

@implementation JCHCategoryListViewController

- (instancetype)initWithType:(JCHCategoryListType)type
{
    self = [super init];
    if (self) {
        self.title = @"类型";
        currentType = type;
    }
    
    return self;
}


- (void)dealloc
{
    [self.categoryRecordArray release];
    [self.sendValueBlock release];
    [self.selectCategoryRecord release];
    
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
    [footerView setData:self.categoryRecordArray.count];
    
    for (NSInteger i = 0; i < self.categoryRecordArray.count; i++) {
        CategoryRecord4Cocoa *categoryRecord = self.categoryRecordArray[i];
        if (currentType == kJCHCategoryListTypeSelect && [categoryRecord.categoryName isEqualToString:self.selectCategoryRecord.categoryName]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;

    if (currentType == kJCHCategoryListTypeNormal) {
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
    footerView.categoryName = @"类型";
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
    
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *categoryRecordArray = [categoryService queryAllCategory];
        self.categoryRecordArray = [NSMutableArray arrayWithArray:categoryRecordArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.categoryRecordArray.count == 0)
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
            [footerView setData:self.categoryRecordArray.count];
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
        [footerView setData:self.categoryRecordArray.count];
    }else {
        NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
        [footerView setData:selectedIndexPaths.count];
    }
}


- (void)handleDeleteCategory:(NSIndexPath *)indexPath
{
    CategoryRecord4Cocoa *currentCategory = [self.categoryRecordArray objectAtIndex:indexPath.row];
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    
    BOOL isCategoryCanBeDeleted = [self showAlertForDeleteCategory:currentCategory];
    if (NO == isCategoryCanBeDeleted) {
        return;
    }
    
#if MMR_TAKEOUT_VERSION
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
    DeleteCategoryRequest *request = [[[DeleteCategoryRequest alloc] init] autorelease];
    request.nameList = @[currentCategory.categoryName];
    request.token = statusManager.syncToken;
    request.bookID = statusManager.accountBookID;
    request.serviceURL = [NSString stringWithFormat:@"%@/category/delete", kTakeoutServerIP];
    
    [MBProgressHUD showHUDWithTitle:@"删除中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
    [takeoutService deleteCategory:request callback:^(id response) {
        
        NSDictionary *data = response;
        
        if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
            NSDictionary *responseData = data[@"data"];
            NSInteger responseCode = [responseData[@"code"] integerValue];
            NSString *responseDescription = responseData[@"desc"];
            NSString *responseStatus = responseData[@"status"];
            
            NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
            
            if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                //! @todo
                if (responseCode == 22000) {
                    [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                             detail:@"请重新登录"
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                             detail:responseDescription
                                           duration:kJCHDefaultShowHudTime
                                               mode:MBProgressHUDModeText
                                          superView:self.view
                                         completion:nil];
                }
            } else {
                NSLog(@"responseData = %@", responseData);
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                
                [categoryService deleteCategory:currentCategory.categoryUUID];
                [self loadCategoryData];
                [footerView setData:self.categoryRecordArray.count];
                
            }
        } else {
            NSLog(@"request fail: %@", data[@"data"]);
            [MBProgressHUD showNetWorkFailedHud:@""
                                      superView:self.view];
        }
    }];
#else
    [categoryService deleteCategory:currentCategory.categoryUUID];
    [self loadCategoryData];
    [footerView setData:self.categoryRecordArray.count];
#endif
    
    
    
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
    return (NSInteger)self.categoryRecordArray.count;
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
        if (currentType == kJCHCategoryListTypeSelect) {
            cell.autoHiddenArrowImageViewWhileEditing = NO;
            cell.arrowImageView.hidden = YES;
        } else if (currentType == kJCHCategoryListTypeNormal) {
            cell.autoHiddenArrowImageViewWhileEditing = YES;
            cell.arrowImageView.hidden = NO;
        }
    }
    
    //每段最后一行的底线与左侧边无间隔
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    WeakSelf;
    [cell setGoTopBlock:^(JCHItemListTableViewCell *cell) {
        [weakSelf handleGoTopCell:cell];
    }];
    CategoryRecord4Cocoa *record = [self.categoryRecordArray objectAtIndex:indexPath.row];
    cell.textLabel.text = record.categoryName;
    if (currentType == kJCHCategoryListTypeSelect && [record.categoryName isEqualToString:self.selectCategoryRecord.categoryName]) {
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
        
        if ([contentTableView indexPathsForSelectedRows].count == self.categoryRecordArray.count) {
            [footerView setButtonSelected:YES];
        }
    }
    else
    {
        CategoryRecord4Cocoa *categoryRecord = [self.categoryRecordArray objectAtIndex:indexPath.row];
        
        if (currentType == kJCHCategoryListTypeSelect) {
            for (NSInteger i = 0; i < self.categoryRecordArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                JCHItemListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.selectImageView.hidden = YES;
            }
            JCHItemListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectImageView.hidden = NO;
            self.sendValueBlock(categoryRecord);
            [self.navigationController popViewControllerAnimated:YES];
        } else if (currentType == kJCHCategoryListTypeNormal) {
            
            JCHAddCategoryViewController *addController = [[[JCHAddCategoryViewController alloc] initWithTitle:@"修改类型"] autorelease];
            addController.categoryRecord = categoryRecord;
            addController.categoreType = kJCHCategoryTypeModifyCategory;
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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    CategoryRecord4Cocoa *sourceRecord = [self.categoryRecordArray[sourceIndexPath.row] retain];
    
    [self.categoryRecordArray removeObjectAtIndex:sourceIndexPath.row];
    [self.categoryRecordArray insertObject:sourceRecord atIndex:destinationIndexPath.row];
    
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    
    NSInteger destinationSortIndex;
    if (destinationIndexPath.row == 0) {
        destinationSortIndex = 0;
    } else {
        CategoryRecord4Cocoa *lastRecord = self.categoryRecordArray[destinationIndexPath.row - 1];
        destinationSortIndex = lastRecord.categorySortIndex + 1;
    }
    
    for (NSInteger i = destinationIndexPath.row; i < self.categoryRecordArray.count; i++) {
        CategoryRecord4Cocoa *record = self.categoryRecordArray[i];
        
        record.categorySortIndex = destinationSortIndex;
        destinationSortIndex++;
        [categoryService updateCategory:record];
    }
}

- (void)handleGoTopCell:(JCHItemListTableViewCell *)cell
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    CategoryRecord4Cocoa *sourceRecord = [self.categoryRecordArray[indexPath.row] retain];
    [self.categoryRecordArray removeObjectAtIndex:indexPath.row];
    [self.categoryRecordArray insertObject:sourceRecord atIndex:0];
    
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    
    for (NSInteger i = 0; i < self.categoryRecordArray.count; i++) {
        CategoryRecord4Cocoa *record = self.categoryRecordArray[i];
        
        record.categorySortIndex = i;
        [categoryService updateCategory:record];
    }
    [contentTableView reloadData];
}


#pragma mark - JCHItemListFooterViewDelegate
- (void)addItem
{
    WeakSelf;
    JCHAddCategoryViewController *addController = [[[JCHAddCategoryViewController alloc] initWithTitle:@"添加类型"] autorelease];
    if (self.sendValueBlock) {
        [addController setSendValueBlock:^(NSString *categoryName) {
            [weakSelf sendRecord:categoryName];
        }];
    }
   
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)sendRecord:(NSString *)categoryName
{
    //由于传过来的record的uuid和保存之后的uuid不一样，所以这里要根据名字重新查询该record
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    NSArray *allCategoryRecords = [categoryService queryAllCategory];
    
    for (CategoryRecord4Cocoa *categoryRecord in allCategoryRecords) {
        if ([categoryRecord.categoryName isEqualToString:categoryName]) {
            if (self.sendValueBlock) {
                self.sendValueBlock(categoryRecord);
            }
            break;
        }
    }
}

- (void)deleteItems
{
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    
    NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
    BOOL categoriesCanBeDeleted = YES;
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        
        CategoryRecord4Cocoa *currentCategory = [self.categoryRecordArray objectAtIndex:indexPath.row];
        
        categoriesCanBeDeleted = [self showAlertForDeleteCategory:currentCategory];
        if (NO == categoriesCanBeDeleted) {
            break;
        }
    }
    
    if (categoriesCanBeDeleted) {
        
#if MMR_TAKEOUT_VERSION
        NSMutableArray *categoryNameList = [NSMutableArray array];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            CategoryRecord4Cocoa *categoryRecord = [self.categoryRecordArray objectAtIndex:indexPath.row];
            [categoryNameList addObject:categoryRecord.categoryName];
        }
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        
        id<TakeOutService> takeoutService = [[ServiceFactory sharedInstance] takeoutService];
        DeleteCategoryRequest *request = [[[DeleteCategoryRequest alloc] init] autorelease];
        request.nameList = categoryNameList;
        request.token = statusManager.syncToken;
        request.bookID = statusManager.accountBookID;
        request.serviceURL = [NSString stringWithFormat:@"%@/category/delete", kTakeoutServerIP];
        
        [MBProgressHUD showHUDWithTitle:@"删除中..." detail:@"" duration:9999 mode:MBProgressHUDModeIndeterminate superView:self.view completion:nil];
        
        [takeoutService deleteCategory:request callback:^(id response) {
            
            NSDictionary *data = response;
            
            if (kJCHServiceSuccess == [data[@"status"] integerValue]) {
                NSDictionary *responseData = data[@"data"];
                NSInteger responseCode = [responseData[@"code"] integerValue];
                NSString *responseDescription = responseData[@"desc"];
                NSString *responseStatus = responseData[@"status"];
                
                NSLog(@"%d, %@, %@", (int)responseCode, responseDescription, responseStatus);
                
                if (NO == [responseStatus isEqualToString:kJCHServiceResponseSuccess]) {
                    //! @todo
                    if (responseCode == 22000) {
                        [MBProgressHUD showHUDWithTitle:@"用户验证失败"
                                                 detail:@"请重新登录"
                                               duration:kJCHDefaultShowHudTime
                                                   mode:MBProgressHUDModeText
                                              superView:self.view
                                             completion:nil];
                    } else {
                        [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"%ld", responseCode]
                                                 detail:responseDescription
                                               duration:kJCHDefaultShowHudTime
                                                   mode:MBProgressHUDModeText
                                              superView:self.view
                                             completion:nil];
                    }
                } else {
                    NSLog(@"responseData = %@", responseData);
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                    
                    for (NSIndexPath *indexPath in selectedIndexPaths) {
                        CategoryRecord4Cocoa *categoryRecord = self.categoryRecordArray[indexPath.row];
                        [categoryService deleteCategory:categoryRecord.categoryUUID];
                    }
                    
                    [self loadCategoryData];
                    
                    //如果类型全部删除完,footerView切换模式
                    if (self.categoryRecordArray.count == 0) {
                        [footerView changeUI:YES];
                    }
                    [footerView setData:[contentTableView indexPathsForSelectedRows].count];
                }
            } else {
                NSLog(@"request fail: %@", data[@"data"]);
                [MBProgressHUD showNetWorkFailedHud:@""
                                          superView:self.view];
            }
        }];
#else
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            CategoryRecord4Cocoa *categoryRecord = self.categoryRecordArray[indexPath.row];
            [categoryService deleteCategory:categoryRecord.categoryUUID];
        }
        
        [self loadCategoryData];
        
        //如果类型全部删除完,footerView切换模式
        if (self.categoryRecordArray.count == 0) {
            [footerView changeUI:YES];
        }
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
#endif
        
        
        

    } else {
     
        [self loadCategoryData];
        
        //如果类型全部删除完,footerView切换模式
        if (self.categoryRecordArray.count == 0) {
            [footerView changeUI:YES];
        }
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
    }
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
        for (NSInteger i = 0; i < self.categoryRecordArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    //刷新footerView数据
    [footerView setData:[contentTableView indexPathsForSelectedRows].count];
}

- (BOOL)showAlertForDeleteCategory:(CategoryRecord4Cocoa *)categoryRecord
{
    id<CategoryService> categoryService = [[ServiceFactory sharedInstance] categoryService];
    BOOL isCategoryCanBeDeleted = [categoryService isCategoryCanBeDeleted:categoryRecord.categoryUUID];
    //如果当前类型被商品选择，但是商品未保存，也不能删除
    if ([categoryRecord.categoryUUID isEqualToString:self.selectCategoryRecord.categoryUUID]) {
        isCategoryCanBeDeleted = NO;
    }
    
    if (!isCategoryCanBeDeleted) {
        NSString *alertMessage = [NSString stringWithFormat:@"\"%@\" 类型下存在关联的商品，不能删除", categoryRecord.categoryName];
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:alertMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
    
    return isCategoryCanBeDeleted;
}

@end
