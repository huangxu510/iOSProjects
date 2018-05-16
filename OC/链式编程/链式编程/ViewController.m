//
//  ViewController.m
//  链式编程
//
//  Created by huangxu on 2017/12/15.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Calculate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSInteger result =  [NSObject makeCaculators:^(CaculatorMaker *make) {
        make.add(1).add(2).add(2);
    }];
    
    NSLog(@"result = %ld", result);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
