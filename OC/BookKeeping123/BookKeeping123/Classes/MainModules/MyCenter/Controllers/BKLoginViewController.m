//
//  BKLoginViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKLoginViewController.h"
#import "BKRegisterViewController.h"
#import "BKUserInfo.h"

@interface BKLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation BKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"登录";
    BKCornerRadius(self.loginButton, 5);
    
    BKUserInfo *userInfo = [BKUserInfo shareInstance];
    self.userNameTextField.text = userInfo.phoneNumber;
    self.passwordTextField.text = userInfo.password;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!empty(userInfo.phoneNumber) && !empty(userInfo.password)) {
            [self handleLogin];
        }
    });
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


- (IBAction)handleLogin {
    
    if (empty(_userNameTextField.text)) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
        return;
    }
    
    if (empty(_passwordTextField.text)) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"登录中..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![self.userNameTextField.text isEqualToString:@"18688886666"]) {
            [SVProgressHUD showErrorWithStatus:@"该号码尚未注册！"];
            return;
        }
        if (![self.passwordTextField.text isEqualToString:@"111111"]) {
            [SVProgressHUD showErrorWithStatus:@"密码错误！"];
            return;
        }
        [SVProgressHUD dismiss];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        BKUserInfo *userInfo = [BKUserInfo shareInstance];
        userInfo.phoneNumber = self.userNameTextField.text;
        userInfo.password = self.passwordTextField.text;
        [userInfo saveCache];
    });
}

- (IBAction)handleRegister {
    BKRegisterViewController *vc = [[BKRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
