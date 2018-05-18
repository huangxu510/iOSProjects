//
//  BKCreditCalculatorViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCreditCalculatorViewController.h"

@interface BKCreditCalculatorViewController ()

@end

@implementation BKCreditCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"信用卡分期计算器";
    
    [self setupUI];
}

- (void)setupUI {
    
    WeakSelf;
    BKWordArrowItem *item0 = [BKWordArrowItem itemWithTitle:@"分期金额（元）" subTitle:@""];
    item0.hasTextField = YES;
    item0.keyboardType = UIKeyboardTypeDecimalPad;
    
    BKWordArrowItem *item1 = [BKWordArrowItem itemWithTitle:@"分期期限（月）" subTitle:@""];
    item1.hasTextField = YES;
    item1.keyboardType = UIKeyboardTypeNumberPad;
    
    BKWordArrowItem *item2 = [BKWordArrowItem itemWithTitle:@"支付方式" subTitle:@""];
    __weak BKWordArrowItem *weakItem = item2;
    [item2 setItemOperation:^(NSIndexPath *indexPath) {
        NSArray *array = @[@"一次性支付",@"分期收取"];
        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:array tag:indexPath.row title:nil cancelTitle:@"取消" commitTitle:@"确认" commitBlock:^(NSString * _Nonnull string) {
            weakItem.subTitle = string;
            [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        } cancelBlock:nil];
    }];
    
    BKWordArrowItem *item3 = [BKWordArrowItem itemWithTitle:@"分期费率（%）" subTitle:@""];
    item3.hasTextField = YES;
    item3.keyboardType = UIKeyboardTypeDecimalPad;
    
    
    
    BKItemSection *section0 = [BKItemSection sectionWithItems:@[item0, item1, item2, item3] andHeaderTitle:nil footerTitle:nil];
    
    [self.sections addObject:section0];
}

- (void)handleCalculate {
    
    if (empty(self.sections[0].items[0].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入分期金额"];
        return;
    }
    
    if (empty(self.sections[0].items[1].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入分期期限"];
        return;
    }
    
    if (empty(self.sections[0].items[2].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请选择支付方式"];
        return;
    }
    
    if (empty(self.sections[0].items[3].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入分期费率"];
        return;
    }
    
    CGFloat capital = self.sections[0].items[0].subTitle.doubleValue;
    CGFloat months = self.sections[0].items[1].subTitle.integerValue;
    NSString *way = self.sections[0].items[2].subTitle;
    CGFloat rate = self.sections[0].items[3].subTitle.doubleValue / 100;
    
    
    CGFloat monthInterest = 0.0;
    if ([way isEqualToString:@"一次性支付"]) {
        monthInterest = [BKCalculatorUtility calculateMonthInterest:capital months:months rate:rate way:kRepaymentWay1];
    } else {
        monthInterest = [BKCalculatorUtility calculateMonthInterest:capital months:months rate:rate way:kRepaymentWay2] ;
    }
    
    NSArray *titleArray = [self getTitleArray];
    NSArray *detailArray = [self getDetailArray:capital months:months monthInterest:monthInterest];
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
    return @[@"还款总额", @"第一期还款", @"以后每期还款", @"支付手续费"];
}

- (NSArray *)getDetailArray:(CGFloat)capital months:(NSInteger)months monthInterest:(CGFloat)monthInterest {
    NSString *totalAmount = [NSString stringWithFormat:@"%.2f", capital + months * monthInterest];
    NSString *firstRepayment = [NSString stringWithFormat:@"%.2f", totalAmount.doubleValue / months];
    NSString *monthRepayment = [NSString stringWithFormat:@"%.2f", totalAmount.doubleValue / months];
    NSString *chargeAmount = [NSString stringWithFormat:@"%.2f", monthInterest * months];
    return @[totalAmount, firstRepayment, monthRepayment, chargeAmount];
}


@end
