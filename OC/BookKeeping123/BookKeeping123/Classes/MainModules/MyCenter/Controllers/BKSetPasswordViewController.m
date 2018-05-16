//
//  BKSetPasswordViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKSetPasswordViewController.h"

@interface BKSetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField1;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField2;

@end

@implementation BKSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)submit {
    if (empty(_passwordTextField2.text)) {
        [SVProgressHUD showErrorWithStatus:@"请填写密码"];
        return;
    }
    if (![_passwordTextField1.text isEqualToString:_passwordTextField2.text]) {
        [SVProgressHUD showErrorWithStatus:@"两次密码不一致"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    });
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
