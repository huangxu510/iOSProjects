//
//  BKProvidentFundCalculatorViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKProvidentFundCalculatorViewController.h"

@interface BKProvidentFundCalculatorViewController ()

@end

@implementation BKProvidentFundCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"公积金房贷计算器";
    
    [self setupUI];
}

- (void)setupUI {
    
    WeakSelf;
    BKWordArrowItem *item0 = [BKWordArrowItem itemWithTitle:@"还款方式" subTitle:@""];
    __weak BKWordArrowItem *weakItem = item0;
    [item0 setItemOperation:^(NSIndexPath *indexPath) {
        NSArray *array = @[@"等额本息", @"等额本金"];
        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:array tag:indexPath.row title:nil cancelTitle:@"取消" commitTitle:@"确认" commitBlock:^(NSString * _Nonnull string) {
            weakItem.subTitle = string;
            [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        } cancelBlock:nil];
    }];
    
    BKWordArrowItem *item1 = [BKWordArrowItem itemWithTitle:@"计算方式" subTitle:@""];
    __weak BKWordArrowItem *weakItem1 = item1;
    [item1 setItemOperation:^(NSIndexPath *indexPath) {
        NSArray *array = @[@"总价", @"面积"];
        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:array tag:indexPath.row title:nil cancelTitle:@"取消" commitTitle:@"确认" commitBlock:^(NSString * _Nonnull string) {
            weakItem1.subTitle = string;
            [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        } cancelBlock:nil];
    }];
    
    BKWordArrowItem *item2 = [BKWordArrowItem itemWithTitle:@"贷款总额（元）" subTitle:@""];
    item2.hasTextField = YES;
    item2.keyboardType = UIKeyboardTypeDecimalPad;
    
    BKWordArrowItem *item3 = [BKWordArrowItem itemWithTitle:@"按揭年数" subTitle:@""];
    __weak BKWordArrowItem *weakItem3 = item3;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 1; i < 31; i++) {
        NSString *text = [NSString stringWithFormat:@"%ld年（%ld个月）", i, i * 12];
        [array addObject:text];
    }
    [item3 setItemOperation:^(NSIndexPath *indexPath) {
        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:array tag:indexPath.row title:nil cancelTitle:@"取消" commitTitle:@"确认" commitBlock:^(NSString * _Nonnull string) {
            weakItem3.subTitle = string;
            [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        } cancelBlock:nil];
    }];
    
    BKWordArrowItem *item4 = [BKWordArrowItem itemWithTitle:@"公积金利率（%）" subTitle:@""];
    item4.hasTextField = YES;
    item4.keyboardType = UIKeyboardTypeDecimalPad;
    
    BKItemSection *section0 = [BKItemSection sectionWithItems:@[item0, item1, item2, item3, item4] andHeaderTitle:nil footerTitle:nil];
    [self.sections addObject:section0];
}

- (void)handleCalculate {
    
    if (empty(self.sections[0].items[0].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请选择还款方式"];
        return;
    }
    
    if (empty(self.sections[0].items[1].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请选择计价方式"];
        return;
    }
    
    if (empty(self.sections[0].items[2].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入贷款总额"];
        return;
    }
    
    if (empty(self.sections[0].items[3].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请选择按揭年数"];
        return;
    }
    
    if (empty(self.sections[0].items[4].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入公积金利率"];
        return;
    }
    
    CGFloat capital = self.sections[0].items[2].subTitle.doubleValue;
    NSString *yearInfo = self.sections[0].items[3].subTitle;
    NSArray *array = [yearInfo componentsSeparatedByString:@"年"];
    CGFloat months = [array.firstObject integerValue] * 12;
    NSString *way = self.sections[0].items[0].subTitle;
    CGFloat rate = self.sections[0].items[4].subTitle.doubleValue / 100;
    
    
    CGFloat monthInterest = 0.0;
    if ([way isEqualToString:@"等额本息"]) {
        monthInterest = [BKCalculatorUtility calculateMonthInterest:capital months:months rate:rate way:kRepaymentWay1];
    } else {
        monthInterest = [BKCalculatorUtility calculateMonthInterest:capital months:months rate:rate way:kRepaymentWay2] ;
    }
    
    NSArray *titleArray = [self getTitleArray];
    NSArray *detailArray = [self getDetailArray:capital months:months monthInterest:monthInterest yearInfo:yearInfo];
    NSMutableArray *dataSource = [NSMutableArray array];
    for (NSInteger i = 0; i < titleArray.count; i++) {
        BKCalculateResultTableViewCellModel *model = [[BKCalculateResultTableViewCellModel alloc] init];
        model.title = titleArray[i];
        model.detail = detailArray[i];
        if (i == 0) {
            model.detailColor = [UIColor redColor];
        }
        [dataSource addObject:model];
    }
    [BKCalculateResultView showWithDataSource:dataSource];
}

- (NSArray *)getTitleArray {
    return @[@"贷款总额", @"还款总额", @"支付利息", @"按揭年数", @"月均还款"];
}

- (NSArray *)getDetailArray:(CGFloat)capital months:(NSInteger)months monthInterest:(CGFloat)monthInterest yearInfo:(NSString *)yearInfo {
    NSString *capitalString = [NSString stringWithFormat:@"%.2f", capital];
    NSString *totalAmount = [NSString stringWithFormat:@"%.2f", capital + months * monthInterest];
    NSString *monthRepayment = [NSString stringWithFormat:@"%.2f", totalAmount.doubleValue / months];
    NSString *chargeAmount = [NSString stringWithFormat:@"%.2f", monthInterest * months];
    return @[capitalString, totalAmount, chargeAmount, yearInfo, monthRepayment];
}

@end
