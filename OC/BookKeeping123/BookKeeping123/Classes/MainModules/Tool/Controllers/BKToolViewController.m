//
//  BKToolViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKToolViewController.h"
#import "BKSmallCalculatorViewController.h"
#import "BKCreditCalculatorViewController.h"
#import "BKProvidentFundCalculatorViewController.h"
#import "BKCombineLoanCalculatorViewController.h"
#import "BKBusinessLoanCalculatorViewController.h"
#import "BKCalculateButton.h"

@interface BKToolViewController ()

@end

@implementation BKToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"工具";
    
    [self setupUI];
}

- (void)setupUI {
    NSArray *titleArray = @[@"小额计算器", @"信用卡分期计算器", @"公积金房贷计算器", @"组合房贷计算器", @"商业房贷计算器"];
    NSArray *imageArray = @[@"Tool_calculate_small", @"Tool_calculate_credit", @"Tool_calculate_accumulationfund", @"Tool_calculate_combine", @"Tool_calculate_buiness"];
    CGFloat labelHeight = 30;
    CGFloat leftPadding = 16;
    CGFloat topPadding = 20;
    CGFloat middlePadding = 18;
    CGFloat width = (kScreenWidth - 2 * leftPadding - middlePadding) / 2;
    CGFloat height = width / (338.0 / 210);
    for (NSInteger i = 0; i < titleArray.count; i++) {
        BKCalculateButton *button = [BKCalculateButton buttonWithTitle:titleArray[i] imageName:imageArray[i]];
        [self.view addSubview:button];
        button.tag = i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
       
        CGFloat x = (i % 2 == 0) ? leftPadding : leftPadding + middlePadding + width;
        CGFloat y = topPadding + i / 2 * (height + middlePadding);
        if (i > 1) {
            y += labelHeight;
        }
        button.frame = CGRectMake(x, y, width, height);
        
        BKCornerRadius(button, 5);
        BKShadow(button, 4, 0.1);
    }
    
    UILabel *label = [UIFactory createLabelWithColor:[UIColor lightGrayColor] fontSize:17];
    label.text = @"房贷计算器";
    label.frame = CGRectMake(leftPadding, topPadding + height + 9, kScreenWidth - 2 * leftPadding, labelHeight);
    [self.view addSubview:label];
}

- (void)buttonAction:(UIButton *)sender {
    UIViewController *vc = nil;
    switch (sender.tag) {
        case 0:
            vc = [[BKSmallCalculatorViewController alloc] init];
            break;
        case 1:
            vc = [[BKCreditCalculatorViewController alloc] init];
            break;
        case 2:
            vc = [[BKProvidentFundCalculatorViewController alloc] init];
            break;
        case 3:
            vc = [[BKCombineLoanCalculatorViewController alloc] init];
            break;
        case 4:
            vc = [[BKBusinessLoanCalculatorViewController alloc] init];
            break;
            
        default:
            break;
    }

    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
