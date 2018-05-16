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

@interface BKToolViewController ()

@end

@implementation BKToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"工具";
}

- (IBAction)buttonAction:(UIButton *)sender {
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
