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
@end
