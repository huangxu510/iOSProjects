//
//  BKCalculatorBaseViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/16.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCalculatorBaseViewController.h"

@interface BKCalculatorBaseViewController ()


@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation BKCalculatorBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = self.tableView.backgroundColor;
    BKCornerRadius(_button, 5);
    
//    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.equalTo(self.view);
//        make.bottom.equalTo(self.button.mas_top).offset(-10);
//    }];
}

- (IBAction)handleCalculate {
    
}


@end
