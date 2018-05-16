//
//  MTSeatViewController.m
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import "MTSeatViewController.h"
#import "MBProgressHUD+Add.h"
#import "MTSeatSelectionView.h"
#import "MTSeatButton.h"
#import "UIView+Extension.h"

@interface MTSeatViewController ()

@property (nonatomic, copy) NSMutableArray *selectSeatModelList;

@end

@implementation MTSeatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *maoyanLabel = [[UILabel alloc]init];
    maoyanLabel.text = @"高仿猫眼选票";
    [maoyanLabel sizeToFit];
    maoyanLabel.font = [UIFont systemFontOfSize:25];
    maoyanLabel.textColor = [UIColor redColor];
    
    self.navigationItem.titleView = maoyanLabel;
    
    UIButton *bookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bookButton setTitle:@"预订" forState:UIControlStateNormal];
    bookButton.backgroundColor = [UIColor lightGrayColor];
    [bookButton addTarget:self action:@selector(bookAction) forControlEvents:UIControlEventTouchUpInside];
    bookButton.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
    NSLog(@"frame = %@", NSStringFromCGRect(bookButton.frame));
    [self.view addSubview:bookButton];
    
    [self loadData];
}

- (NSMutableArray *)selectSeatModelList
{
    if (_selectSeatModelList == nil) {
        _selectSeatModelList = [NSMutableArray array];
    }
    return _selectSeatModelList;
}

- (void)loadData
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc]initWithView:self.view];
    
    HUD.tintColor = [UIColor blackColor];
    [self.view addSubview:HUD];
    [HUD showAnimated:YES];
    __weak typeof(self) weakSelf = self;
    //模拟延迟加载
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *roomNumers = @[@"914", @"915", @"1001", @"1012", @"1015", @"1201", @"1305", @"1310", @"1402"];
        NSMutableArray *seatsArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 9; i++) {
            NSMutableArray *seatsArrayInRow = [NSMutableArray array];
            for (NSInteger j = 0; j < 18; j++) {
                MTSeatModel *seatModel = [[MTSeatModel alloc] init];
                seatModel.row= i;
                seatModel.column = j;
                seatModel.status = !(arc4random() % 5);
                seatModel.roomNumber = roomNumers[i];
                [seatsArrayInRow addObject:seatModel];
            }
            [seatsArray addObject:seatsArrayInRow];
        }
 
        [HUD hideAnimated:YES];
//        weakSelf.seatsModelArray = seatsModelArray;
        
        //数据回来初始化选座模块
        [weakSelf initSelectionView:seatsArray];
    });
}

//创建选座模块
- (void)initSelectionView:(NSMutableArray *)seatsModelArray {
    __weak typeof(self) weakSelf = self;
    MTSeatSelectionView *seatSelectionView = [[MTSeatSelectionView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 400) SeatsArray:seatsModelArray seatBtnActionBlock:^(MTSeatButton *seatButton) {
        NSLog(@"row = %ld, column = %ld", seatButton.seatModel.row, seatButton.seatModel.column);
        
        if (seatButton.selected) {
            for (MTSeatModel *model in weakSelf.selectSeatModelList) {
                if (seatButton.seatModel.row != model.row) {
                    [MBProgressHUD showWarnMessage:@"每次只能预订一个会议室"];
                    seatButton.selected = NO;
                    return;
                }
            }
            
            [weakSelf.selectSeatModelList addObject:seatButton.seatModel];
        } else {
            if ([weakSelf.selectSeatModelList containsObject:seatButton.seatModel]) {
                [weakSelf.selectSeatModelList removeObject:seatButton.seatModel];
            }
        }
    } roomIndexActionBlock:^(NSInteger index) {
        NSLog(@"roomDidTap:%ld", index);
        [MBProgressHUD showText:@(index).stringValue];
    }];
    
    [self.view addSubview:seatSelectionView];
}

- (void)bookAction
{
    if (self.selectSeatModelList.count == 0) {
        [MBProgressHUD showWarnMessage:@"未选座"];
    }
    
    // 判断已选座位row是否一致
    NSMutableArray *allColumnNumbers = [NSMutableArray array];
    NSInteger index = [self.selectSeatModelList.firstObject row];
    for (NSInteger i = 0; i < self.selectSeatModelList.count; i++) {
        MTSeatModel *seatModel = self.selectSeatModelList[i];
        [allColumnNumbers addObject:@(seatModel.column)];
        if (index != seatModel.row) {
            [MBProgressHUD showWarnMessage:@"每次只能预订一个会议室"];
            return;
        }
    }
    
    NSLog(@"%@", allColumnNumbers);
    
    // 判断已选座位是否连续
    [allColumnNumbers sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return obj1.integerValue > obj2.integerValue;
    }];
    
    NSInteger diff = [allColumnNumbers.firstObject integerValue];
    for (NSInteger i = 0; i < allColumnNumbers.count; i++) {
        NSInteger column = [allColumnNumbers[i] integerValue];
        if (column - i != diff) {
            [MBProgressHUD showWarnMessage:@"必须选座连续的时间段"];
            return;
        }
    }
    
    [MBProgressHUD showSuccessMessage:@"预订成功"];
}

@end
