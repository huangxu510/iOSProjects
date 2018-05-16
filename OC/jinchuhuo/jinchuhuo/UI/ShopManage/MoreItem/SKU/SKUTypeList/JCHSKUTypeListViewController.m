//
//  JCHSpecificationListViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSKUTypeListViewController.h"
#import "JCHAddSKUViewController.h"
#import "JCHItemListTableViewCell.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHItemListFooterView.h"
#import "SKURecord4Cocoa.h"
#import "SKUService.h"
#import "ServiceFactory.h"  
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHPlaceholderView.h"
#import "Masonry.h"
#import "CommonHeader.h"

@interface JCHSKUTypeListViewController () <UITableViewDataSource, UITableViewDelegate, JCHItemListFooterViewDelegate, UIAlertViewDelegate, SWTableViewCellDelegate>
{
    UITableView *contentTableView;
    JCHItemListFooterView *footerView;
    UIButton *editButton;
    JCHPlaceholderView *placeholderView;
}
@property (retain, nonatomic, readwrite) NSMutableArray *skuTypeRecordArray;

@end

@implementation JCHSKUTypeListViewController

- (void)dealloc
{
    [self.skuTypeRecordArray release];

    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"规格";
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadSKUData];
    contentTableView.editing = NO;
    editButton.selected = NO;
    [footerView setData:self.skuTypeRecordArray.count];
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    editButton = [JCHUIFactory createButton:CGRectMake(0, 0, 40, 40)
                                     target:self
                                     action:@selector(handleEditMode:)
                                      title:@"编辑"
                                 titleColor:nil
                            backgroundColor:nil];
    [editButton setTitle:@"取消" forState:UIControlStateSelected];
    editButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:editButton] autorelease];
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:self
                                                                               action:nil] autorelease];
    fixedSpace.width = -10;
    
    self.navigationItem.rightBarButtonItems = @[fixedSpace, editButtonItem];
    
    contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    [self.view addSubview:contentTableView];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    contentTableView.tableHeaderView = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
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
    footerView.categoryName = @"规格";
    footerView.categoryUnit = @"种";
    footerView.delegate = self;
    [self.view addSubview:footerView];
    
    placeholderView = [[[JCHPlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
    placeholderView.hidden = YES;
    placeholderView.imageView.image = [UIImage imageNamed:@"default_stock_placeholder"];
    placeholderView.label.text = @"暂无规格";
    [self.view addSubview:placeholderView];
    
    [placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(158);
        make.width.mas_equalTo(kScreenWidth);
        make.centerY.equalTo(self.view);
    }];
    
    return;
}

#pragma mark - LoadData
- (void)loadSKUData
{
    [MBProgressHUD showHUDWithTitle:@"加载中..."
                             detail:nil
                           duration:100
                               mode:MBProgressHUDModeIndeterminate
                          superView:self.view
                         completion:nil];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *allSKUType = nil;
        [skuService queryAllSKUType:&allSKUType];
        
#if MMR_TAKEOUT_VERSION
        if (allSKUType.count == 0) {
            id<UtilityService> utilityService = [[ServiceFactory sharedInstance] utilityService];
            SKUTypeRecord4Cocoa *skuTypeRecord = [[[SKUTypeRecord4Cocoa alloc] init] autorelease];
            skuTypeRecord.skuTypeName = @"规格";
            skuTypeRecord.skuSortIndex = 0;
            skuTypeRecord.skuTypeUUID = [utilityService generateUUID];
            [skuService addSKUType:skuTypeRecord];
            allSKUType = @[skuTypeRecord];
        }
#endif
        
        self.skuTypeRecordArray = [NSMutableArray arrayWithArray:allSKUType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.skuTypeRecordArray.count == 0)
            {
                contentTableView.hidden = YES;
                editButton.hidden = YES;
                placeholderView.hidden = NO;
            }
            else
            {
                contentTableView.hidden = NO;
                editButton.hidden = NO;
                placeholderView.hidden = YES;
            }
            [contentTableView reloadData];
            [footerView setData:self.skuTypeRecordArray.count];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            
#if MMR_TAKEOUT_VERSION
            footerView.hidden = YES;
            editButton.hidden = YES;
#endif
        });
    });

    return;
}

- (void)handleEditMode:(UIButton *)sender
{

}

- (void)handleDeleteSKUType:(NSIndexPath *)indexPath
{
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    SKUTypeRecord4Cocoa *currentSKUType = self.skuTypeRecordArray[indexPath.row];
    

    BOOL isSKUTypeCanBeDeleted = [skuService isSKUTypeCanBeDeleted:currentSKUType.skuTypeUUID];
    
    if (NO == isSKUTypeCanBeDeleted) {
        
        [self showAlertForDeleteSKUType];
        return;
    }
    
    [skuService deleteSKUType:currentSKUType.skuTypeUUID];
    [self loadSKUData];
    [footerView setData:self.skuTypeRecordArray.count];
    return;
}

- (void)handleEditSKUType:(NSIndexPath *)indexPath
{
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"请输入规格名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [av textFieldAtIndex:0];
    SKUTypeRecord4Cocoa *record = self.skuTypeRecordArray[indexPath.row];
    textField.text = record.skuTypeName;
    av.tag = indexPath.row;
    [av show];
}


#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.skuTypeRecordArray.count;
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
        cell.delegate = self;
        cell.arrowImageView.hidden = NO;
    }
    
    //每段最后一行的底线与左侧边无间隔
    [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
    
    WeakSelf;
    [cell setGoTopBlock:^(JCHItemListTableViewCell *cell) {
        [weakSelf handleGoTopCell:cell];
    }];
    
    NSMutableArray *rightButons = [NSMutableArray array];
    [rightButons sw_addUtilityButtonWithColor:UIColorFromRGB(0x76828f) title:@"编辑"];
    [rightButons sw_addUtilityButtonWithColor:JCHColorHeaderBackground title:@"删除"];
#if !MMR_TAKEOUT_VERSION
    [cell setRightUtilityButtons:rightButons WithButtonWidth:[JCHSizeUtility calculateWidthWithSourceWidth:65.0f]];
#endif
    

    
    SKUTypeRecord4Cocoa *record = self.skuTypeRecordArray[indexPath.row];
    cell.textLabel.text = record.skuTypeName;

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contentTableView.isEditing) {
        
        //取消选中 变为 全选
        [footerView setButtonSelected:NO];
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
        
        if ([contentTableView indexPathsForSelectedRows].count == self.skuTypeRecordArray.count) {
            [footerView setButtonSelected:YES];
        }
    }
    else
    {
        SKUTypeRecord4Cocoa *record = self.skuTypeRecordArray[indexPath.row];

        JCHAddSKUViewController *addController = [[[JCHAddSKUViewController alloc] initWithType:kJCHSKUTypeModify skuTypeRecord:record] autorelease];

        [self.navigationController pushViewController:addController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contentTableView.isEditing) {
        
        [footerView setButtonSelected:NO];
        [footerView setData:[contentTableView indexPathsForSelectedRows].count];
    }
}

//! @brief 排序规则:移动之后将destinationIndexPath和之后的全部更新
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    SKUTypeRecord4Cocoa *sourceRecord = [self.skuTypeRecordArray[sourceIndexPath.row] retain];

    [self.skuTypeRecordArray removeObjectAtIndex:sourceIndexPath.row];
    [self.skuTypeRecordArray insertObject:sourceRecord atIndex:destinationIndexPath.row];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    
    NSInteger destinationSortIndex;
    if (destinationIndexPath.row == 0) {
        destinationSortIndex = 0;
    } else {
        SKUTypeRecord4Cocoa *lastRecord = self.skuTypeRecordArray[destinationIndexPath.row - 1];
        destinationSortIndex = lastRecord.skuSortIndex + 1;
    }
    
    
    for (NSInteger i = destinationIndexPath.row; i < self.skuTypeRecordArray.count; i++) {
        SKUTypeRecord4Cocoa *record = self.skuTypeRecordArray[i];
        
        record.skuSortIndex = destinationSortIndex;
        destinationSortIndex++;
        [skuService updateSKUType:record];
    }
}

- (void)handleGoTopCell:(JCHItemListTableViewCell *)cell
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    SKUTypeRecord4Cocoa *sourceRecord = [self.skuTypeRecordArray[indexPath.row] retain];
    [self.skuTypeRecordArray removeObjectAtIndex:indexPath.row];
    [self.skuTypeRecordArray insertObject:sourceRecord atIndex:0];
    
    id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
    
    for (NSInteger i = 0; i < self.skuTypeRecordArray.count; i++) {
        SKUTypeRecord4Cocoa *record = self.skuTypeRecordArray[i];
        
        record.skuSortIndex = i;
        [skuService updateSKUType:record];
    }
    [contentTableView reloadData];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [contentTableView indexPathForCell:cell];
    
    switch (index) {
        case 0: //编辑
        {
            [self handleEditSKUType:indexPath];
        }
            break;
            
        case 1: //删除
        {
            [self handleDeleteSKUType:indexPath];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
    if (buttonIndex == 0)
    {
        [contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    else //更新
    {
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        UITextField *textField = [alertView textFieldAtIndex:0];
        SKUTypeRecord4Cocoa *record = self.skuTypeRecordArray[alertView.tag];
        record.skuTypeName = textField.text;
        [skuService updateSKUType:record];
        [contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - JCHProductListFooterViewDelegate
- (void)addItem
{
    JCHAddSKUViewController *addController = [[[JCHAddSKUViewController alloc] initWithType:kJCHSKUTypeAdd skuTypeRecord:nil] autorelease];
    [self.navigationController pushViewController:addController animated:YES];
    //JCHAddSKUTypeViewController *addController = [[[JCHAddSKUTypeViewController alloc] init] autorelease];
    //[self.navigationController pushViewController:addController animated:YES];
}

- (void)deleteItems
{
    NSArray *selectedIndexPaths = [contentTableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        
        SKUTypeRecord4Cocoa *currentSKUType = self.skuTypeRecordArray[indexPath.row];
        id<SKUService> skuService = [[ServiceFactory sharedInstance] skuService];
        BOOL isSKUTypeCanBeDeleted = [skuService isSKUTypeCanBeDeleted:currentSKUType.skuTypeUUID];
        
        if (YES == isSKUTypeCanBeDeleted) {
            [self showAlertForDeleteSKUType];
            return;
        }
      
        [skuService deleteSKUType:currentSKUType.skuTypeUUID];
    }
    
    [self loadSKUData];
    
    //如果类型全部删除完,footerView切换模式
    if (self.skuTypeRecordArray.count == 0) {
        [footerView changeUI:YES];
    }
    [footerView setData:[contentTableView indexPathsForSelectedRows].count];
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
        for (NSInteger i = 0; i < self.skuTypeRecordArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    //刷新footerView数据
    [footerView setData:[contentTableView indexPathsForSelectedRows].count];
}

- (void)showAlertForDeleteSKUType{

        NSString *alertMessage = [NSString stringWithFormat:@"该规格下存在关联的商品，不能删除"];
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:alertMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    
}



@end
