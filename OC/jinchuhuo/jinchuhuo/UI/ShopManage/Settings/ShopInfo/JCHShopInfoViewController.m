//
//  JCHShopInfoViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopInfoViewController.h"
#import "JCHShopCoverSelectViewController.h"
#import "JCHShopCoverTableViewCell.h"
#import "JCHShopInfoManageProVersionInfoView.h"
#import "JCHShopInfoEditViewController.h"
#import "JCHSeparateLineSectionView.h"
#import "JCHAboutTableViewCell.h"
#import "JCHPickerView.h"
#import "JCHDataSyncManager.h"
#import "CommonHeader.h"

#if MMR_TAKEOUT_VERSION
enum
{
    kShopCoverRow = 0,                      //  店铺封面
    kShopNameRow = 1,                       //  店铺名称
    kShopAddressRow = 2,                    //  店铺地址
    kShopTelephoneRow = 3,                  //  联系电话
//    kShopNoticeRow = 4,                     //  店铺公告
};
#else
enum
{
    kShopCoverRow = 0,                      //  店铺封面
    kShopNameRow = 1,                       //  店铺名称
    kShopAddressRow = 2,                    //  店铺地址
    kShopTypeRow = 3,                       //  店铺类型
    kShopTelephoneRow = 4,                  //  联系电话
    kShopNoticeRow = 6,                     //  店铺公告
};
#endif


@interface JCHShopInfoViewController () <UITableViewDelegate, UITableViewDataSource, JCHPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UITableView *_contentTableView;
    JCHShopInfoManageProVersionInfoView *_proVersionInfoView;
    JCHPickerView *_pickerView;
    
    JCHShopInfoViewControllerType _currentType;
}

@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, retain) BookInfoRecord4Cocoa *bookInfoRecord;
@property (nonatomic, retain) NSArray *availableShopType;
@end

@implementation JCHShopInfoViewController

- (instancetype)initWithType:(JCHShopInfoViewControllerType)type
{
    self = [super init];
    if (self) {
        _currentType = type;
        
        self.title = @"店铺信息";
#if MMR_RESTAURANT_VERSION
        self.availableShopType =  @[@"早餐", @"西餐", @"咖啡", @"PISA",
                                    @"外卖", @"火锅", @"甜品", @"面包",
                                    @"日韩食物", @"奶茶饮品", @"烧烤", @"粥粉面",
                                    @"酒吧", @"汉堡", @"其它"];
#else
        self.availableShopType = @[@"服饰店", @"水果店", @"化妆品店", @"五金店", @"宠物店", @"母婴店", @"精品店", @"珠宝店", @"文具店", @"零食店", @"茶叶店", @"其他"];
#endif
        
#if MMR_TAKEOUT_VERSION
        self.titleArray = @[@"店铺封面", @"店铺名称", @"店铺地址", @"联系电话"];
#else
        self.titleArray = @[@"店铺封面", @"店铺名称", @"店铺地址", @"店铺类型"];
#endif
    }
    return self;
}

- (void)dealloc
{
    [self.titleArray release];
    [self.bookInfoRecord release];
    
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

- (void)createUI
{
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.tableFooterView = [[[UIView alloc] init] autorelease];
    _contentTableView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contentTableView.bounces = YES;
    [_contentTableView registerClass:[JCHAboutTableViewCell class] forCellReuseIdentifier:@"shopInfoTableViewCell"];
    [_contentTableView registerClass:[JCHShopCoverTableViewCell class] forCellReuseIdentifier:@"JCHShopCoverTableViewCell"];
    [self.view addSubview:_contentTableView];
    
    [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)] autorelease];
    footerView.backgroundColor = JCHColorGlobalBackground;
    _contentTableView.tableFooterView = footerView;
    
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    if (addedServiceManager.level == kJCHAddedServiceSiverLevel || addedServiceManager.level == kJCHAddedServiceGoldLevel) {
        //银麦会员服务时间
        _proVersionInfoView = [[[JCHShopInfoManageProVersionInfoView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kStandardItemHeight)] autorelease];
        _proVersionInfoView.backgroundColor = [UIColor whiteColor];
        [_proVersionInfoView addSeparateLineWithFrameTop:YES bottom:YES];
        [footerView addSubview:_proVersionInfoView];
        CGRect frame = footerView.frame;
        frame.size.height += kStandardItemHeight + 20;
        footerView.frame = frame;
    }
 
    //店员 添加退出店铺按钮
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (!statusManager.isShopManager) {
        UIButton *quitShopButton = [JCHUIFactory createButton:CGRectMake(0, CGRectGetMaxY(_proVersionInfoView.frame) + 20, kScreenWidth, kStandardButtonHeight)
                                                         target:self
                                                         action:@selector(handleQuitShop)
                                                          title:@"退出店铺"
                                                     titleColor:JCHColorMainBody
                                                backgroundColor:[UIColor whiteColor]];
        quitShopButton.titleLabel.font = JCHFont(16.0f);
        [quitShopButton addSeparateLineWithFrameTop:YES bottom:YES];
        [footerView addSubview:quitShopButton];
        CGRect frame = footerView.frame;
        frame.size.height += kStandardButtonHeight + 20;
        footerView.frame = frame;
    }


    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:@"店铺类型" showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
}

- (void)loadData
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    self.bookInfoRecord = [bookInfoService queryBookInfo:statusManager.userID];
    [_contentTableView reloadData];
}

- (void)handleQuitShop
{
    //1) 从店铺成员中移除自己
    //2) 推送店铺数据
    //3) 请求服务器解除关系(terminal/leave)
    //4) 清除本地数据账本
    //5) 2和3任意一个失败的话,重新将自己添加到店铺中,退店失败
    WeakSelf;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                             message:@"确定退出该店铺?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf makeSureQuitShop];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:alertAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)makeSureQuitShop
{
    [MBProgressHUD showHUDWithTitle:@"退出店铺中..."
                             detail:@""
                           duration:1000
                               mode:MBProgressHUDModeIndeterminate
                         completion:nil];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *myBookMemberRecord = [bookMemberService queryBookMemberWithUserID:statusManager.userID];
    
    //1) 从店铺成员中移除自己
    [bookMemberService deleteBookMemeber:statusManager.userID];
    
    
    //2) 推送店铺数据
    WeakSelf;
    [dataSyncManager doSyncPushCommand:^(NSInteger pushFlag, NSInteger pullFlag, NSDictionary *responseData) {
        
        
        if (pushFlag == 1) {
            //3) 请求服务器解除关系
            [weakSelf doLeaveAccountBook];
        }
    } failure:^(NSInteger responseCode, NSError *error) {
        
        //重新将自己添加到店铺中,退店失败
        [bookMemberService addBookMember:myBookMemberRecord];
        
        NSString *message = nil;
        if (error) {
            message = error.localizedDescription;
        } else {
            if (responseCode == 20102) {
                message = @"该账号已在其它设备登录，请重新登陆！";
            } else {
                message = [NSString stringWithFormat:@"错误码:%ld", responseCode];
            }
        }
        
        [MBProgressHUD showHUDWithTitle:@"退店失败"
                                 detail:message
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }];
}

- (void)doLeaveAccountBook
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    JCHDataSyncManager *dataSyncManager = [JCHDataSyncManager shareInstance];
    id<BookMemberService> bookMemberService = [[ServiceFactory sharedInstance] bookMemberService];
    BookMemberRecord4Cocoa *myBookMemberRecord = [bookMemberService queryBookMemberWithUserID:statusManager.userID];
    
    WeakSelf;
    [dataSyncManager doLeaveAccountBook:statusManager.userID success:^(NSDictionary *responseData) {
        //4) 清除本地数据账本
        [ServiceFactory deleteAccountBook:statusManager.userID
                            accountBookID:statusManager.accountBookID];
        
        statusManager.accountBookID = nil;
        [JCHSyncStatusManager writeToFile];
        
        AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
        
        [appDelegate switchToHomePage:weakSelf completion:^{
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        }];
        [MBProgressHUD showHUDWithTitle:@"退店成功"
                                 detail:@""
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
        
    } failure:^(NSInteger responseCode, NSError *error) {
        //重新将自己添加到店铺中,退店失败
        [bookMemberService addBookMember:myBookMemberRecord];
        
        NSString *message = nil;
        if (error) {
            message = error.localizedDescription;
        } else {
            if (responseCode == 20102) {
                message = @"该账号已在其它设备登录，请重新登陆！";
            } else {
                message = [NSString stringWithFormat:@"错误码:%ld", responseCode];
            }
        }
        
        //重新将自己添加到店铺中,退店失败
        [bookMemberService addBookMember:myBookMemberRecord];
        [MBProgressHUD showHUDWithTitle:@"退店失败"
                                 detail:message
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            JCHShopCoverTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"JCHShopCoverTableViewCell" forIndexPath:indexPath];
            cell.clipsToBounds = YES;
            cell.titleLabel.text = self.titleArray[indexPath.row];
            
            
            JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
            
            //更新封面
            if ([statusManager.shopCoverImageName isEmptyString]) {
                cell.shopCoverImageView.image = [UIImage imageNamed:@"bg_manage_1"];
            } else {
                cell.shopCoverImageView.image = [UIImage imageNamed:statusManager.shopCoverImageName];
            }
            
            return cell;
        } else {
            JCHAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopInfoTableViewCell" forIndexPath:indexPath];
            cell.arrowImageView.hidden = NO;
            //每段最后一行的底线与左侧边无间隔
            [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
            
            cell.titleLabel.text = self.titleArray[indexPath.row];

            
            if (indexPath.row == 1) {
                cell.detailTitleLabel.text = self.bookInfoRecord.bookName;
            } else if (indexPath.row == 2) {
                cell.detailTitleLabel.text = self.bookInfoRecord.bookAddress;
            } else if (indexPath.row == 3) {
#if MMR_TAKEOUT_VERSION ||  MMR_RESTAURANT_VERSION
                cell.detailTitleLabel.text = self.bookInfoRecord.telephone;
#else
                cell.detailTitleLabel.text = self.bookInfoRecord.bookType;
#endif
            }
            
            return cell;
        }
    } else {
        
        JCHAboutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopInfoTableViewCell" forIndexPath:indexPath];
        cell.arrowImageView.hidden = NO;
        //每段最后一行的底线与左侧边无间隔
        [cell moveLastBottomLineLeft:tableView indexPath:indexPath];
        
        cell.titleLabel.text = self.titleArray[indexPath.row];

        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if MMR_TAKEOUT_VERSION
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (_currentType == kJCHShopInfoViewControllerTypeShopAssistant) {
                return 0;
            }
            return 62;
        } else {
            return kStandardItemHeight;
        }
    } else {
        return kStandardItemHeight;
    }
#else
    if (indexPath.row == 0) {
        if (_currentType == kJCHShopInfoViewControllerTypeShopAssistant) {
            return 0;
        }
        return 62;
    } else {
        return kStandardItemHeight;
    }
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JCHSeparateLineSectionView *view = [[[JCHSeparateLineSectionView alloc] initWithTopLine:NO BottomLine:YES] autorelease];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    if (!statusManager.isShopManager) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    UIViewController *viewController = nil;
    
    NSInteger index = indexPath.row;
    
    switch (index) {
        case kShopCoverRow:
        {
            viewController = [[[JCHShopCoverSelectViewController alloc] init] autorelease];
        }
            break;
            
        case kShopNameRow:
        {
            viewController = [[[JCHShopInfoEditViewController alloc] initWithType:kJCHShopName] autorelease];
        }
            break;
            
        case kShopAddressRow:
        {
            viewController = [[[JCHShopInfoEditViewController alloc] initWithType:kJCHShopAddress] autorelease];
        }
            break;
#if MMR_TAKEOUT_VERSION || MMR_RESTAURANT_VERSION
            
#else
            // 基础版有店铺类型选择
        case kShopTypeRow:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [_pickerView show];
            if ([self.bookInfoRecord.bookType isEqualToString:@""] || !self.bookInfoRecord.bookType || [self.bookInfoRecord.bookType isEqualToString:kJCHDefaultShopType]) {
                [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
                self.bookInfoRecord.bookType = self.availableShopType[0];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [_pickerView.pickerView selectRow:[self.availableShopType indexOfObject:self.bookInfoRecord.bookType] inComponent:0 animated:NO];
            }
        }
            break;
#endif
            
        
        
        case kShopTelephoneRow:
        {
            viewController = [[[JCHShopInfoEditViewController alloc] initWithType:kJCHShopTelephone] autorelease];
        }
            break;
            
        default:
        {
            // pass
        }
            break;
    }
    
    if (nil != viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


#pragma mark - JCHPickerViewDelegate

- (void)pickerViewWillHide:(JCHPickerView *)pickerView
{
    id <BookInfoService> bookInfoService = [[ServiceFactory sharedInstance] bookInfoService];
    [bookInfoService updateBookInfo:self.bookInfoRecord];
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kJCHPickerViewRowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.availableShopType[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.bookInfoRecord.bookType = self.availableShopType[row];
    
    NSIndexPath *indexPath = nil;
#if MMR_TAKEOUT_VERSION
    indexPath = [NSIndexPath indexPathForRow:[self.titleArray[0] indexOfObject:@"店铺类型"] inSection:0];
#else
    indexPath = [NSIndexPath indexPathForRow:[self.titleArray indexOfObject:@"店铺类型"] inSection:0];
#endif
    
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.availableShopType.count;
}


@end
