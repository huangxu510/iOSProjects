//
//  BKSmallCalculatorViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKSmallCalculatorViewController.h"
#import "MOFSPickerManager.h"

@interface BKSmallCalculatorViewController ()

@end

@implementation BKSmallCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"小额计算器";
    
    [self setupUI];
}

- (void)setupUI {
    
    WeakSelf;
    BKWordArrowItem *item0 = [BKWordArrowItem itemWithTitle:@"贷款总金额（元）" subTitle:@""];
    item0.hasTextField = YES;
    item0.keyboardType = UIKeyboardTypeDecimalPad;
    [item0 setItemOperation:^(NSIndexPath *indexPath) {
        
    }];
    
    BKWordArrowItem *item1 = [BKWordArrowItem itemWithTitle:@"贷款期限（月）" subTitle:@""];
    item1.hasTextField = YES;
    item1.keyboardType = UIKeyboardTypeNumberPad;
    [item1 setItemOperation:^(NSIndexPath *indexPath) {

    }];
    
    BKWordArrowItem *item2 = [BKWordArrowItem itemWithTitle:@"贷款利率（%）" subTitle:@""];
    item2.hasTextField = YES;
    item2.keyboardType = UIKeyboardTypeDecimalPad;
    [item2 setItemOperation:^(NSIndexPath *indexPath) {
        
    }];
    
    BKWordArrowItem *item3 = [BKWordArrowItem itemWithTitle:@"还款方式" subTitle:@""];
    __weak BKWordArrowItem *weakItem = item3;
    [item3 setItemOperation:^(NSIndexPath *indexPath) {
        NSArray *array = @[@"等额本息",@"等额本金"];
        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:array tag:indexPath.row title:nil cancelTitle:@"取消" commitTitle:@"确认" commitBlock:^(NSString * _Nonnull string) {
            weakItem.subTitle = string;
            [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        } cancelBlock:nil];
    }];
    
    
    BKItemSection *section0 = [BKItemSection sectionWithItems:@[item0, item1, item2, item3] andHeaderTitle:nil footerTitle:nil];
    
    [self.sections addObject:section0];
}

- (IBAction)handleCalculate {
    
    if (empty(self.sections[0].items[0].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入总金额"];
        return;
    }
    
    if (empty(self.sections[0].items[1].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入贷款期限"];
        return;
    }
    
    if (empty(self.sections[0].items[2].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请输入贷款利率"];
        return;
    }
    
    if (empty(self.sections[0].items[3].subTitle)) {
        [SVProgressHUD showErrorWithStatus:@"请选择还款方式"];
        return;
    }
    
    CGFloat capital = self.sections[0].items[0].subTitle.doubleValue;
    CGFloat months = self.sections[0].items[1].subTitle.integerValue;
    CGFloat rate = self.sections[0].items[2].subTitle.doubleValue / 100;
    NSString *way = self.sections[0].items[3].subTitle;
    
    CGFloat totalInterest = 0.0;
    if ([way isEqualToString:@"等额本息"]) {
        totalInterest = [BKCalculatorUtility calculateMonthInterest:capital months:months rate:rate way:kRepaymentWay1] * months;
    } else {
        totalInterest = [BKCalculatorUtility calculateMonthInterest:capital months:months rate:rate way:kRepaymentWay2] * months;
    }
    
    
    NSString *message = [NSString stringWithFormat:@"您需要支付的总利息为：%.2f元", totalInterest];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:alertAction];
    [self presentViewController:ac animated:YES completion:nil];
}


@end
