//
//  ViewController.m
//  NavigationBarTest
//
//  Created by huangxu on 2017/9/22.
//  Copyright © 2017年 huangxu. All rights reserved.
//

#import "ViewController.h"
#import "MTNavigationBar.h"

@interface ViewController ()

@property (nonatomic, strong) MTNavigationBar *customNavBar;
@property (nonatomic, strong) UINavigationItem *customNavigationItem;
//@property (nonatomic, strong) UINavigationBar *customNavBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.customNavBar = [[MTNavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    self.customNavBar.barTintColor = [UIColor cyanColor];
    [self.view addSubview:_customNavBar];
    
    self.customNavigationItem = [[UINavigationItem alloc] init];
    self.customNavBar.items = @[self.customNavigationItem];
    
    self.title = @"首页";
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    self.customNavigationItem.title = title;
}

@end
