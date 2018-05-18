//
//  BKCalculatorBaseViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/16.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCalculatorBaseViewController.h"

@interface BKCalculatorBaseViewController ()

@end

@implementation BKCalculatorBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    UIButton *button = [UIFactory createButtonWithTitle:@"开始计算" titleColor:[UIColor whiteColor] fontSize:15 target:self action:@selector(handleCalculate)];
    button.backgroundColor = HexColor(0xe77747);
    [self.view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view).offset(-40);
        make.centerX.equalTo(self.view);
    }];
    
    BKCornerRadius(button, 5);
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(button.mas_top).offset(-10);
    }];
}


- (void)handleCalculate {
    
}



@end
