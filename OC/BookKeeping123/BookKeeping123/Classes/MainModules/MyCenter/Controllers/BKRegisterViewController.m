//
//  BKRegisterViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKRegisterViewController.h"
#import "BKSetPasswordViewController.h"

@interface BKRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation BKRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"注册";
    BKCornerRadius(self.registerButton, 5);
}

- (IBAction)handleGetVerificationCode {
    
    if (!self.userNameTextField.text || [self.userNameTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码"];
        return;
    }
    self.getCodeButton.enabled = NO;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleCountDown:) userInfo:nil repeats:YES];
}

- (void)handleCountDown:(NSTimer *)timer {
    NSInteger num = self.getCodeButton.currentTitle.integerValue;
    num--;
    if (num == 0) {
        [self.getCodeButton setTitle:@"60" forState:UIControlStateDisabled];
        self.getCodeButton.enabled = YES;
        [self.timer invalidate];
        self.timer = nil;
    } else {
        NSString *title = [NSString stringWithFormat:@"%ld", num];
        [self.getCodeButton setTitle:title forState:UIControlStateDisabled];
    }
}

- (IBAction)handleRegister {
    if (empty(self.verificationCodeTextField.text)) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
    }
    [SVProgressHUD showWithStatus:@"注册中..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        BKSetPasswordViewController *vc = [[BKSetPasswordViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (IBAction)handlePop {
    [self.navigationController popViewControllerAnimated:YES];
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
