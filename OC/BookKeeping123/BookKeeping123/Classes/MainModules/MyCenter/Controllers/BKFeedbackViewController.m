//
//  BKFeedbackViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/16.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKFeedbackViewController.h"

@interface BKFeedbackViewController ()

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) YYTextView *textView;

@end

@implementation BKFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"意见反馈";
    
    
    BKCornerRadius(self.submitButton, 5);
    
    YYTextView *textView = [[YYTextView alloc] init];
    textView.placeholderText = @"您的意见是我们进步的动力";
    textView.backgroundColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:15];
    textView.placeholderFont = textView.font;
    [self.view addSubview:textView];
    self.textView = textView;
    BKCornerRadius(self.textView, 5);
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.top.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(16);
        make.height.mas_equalTo(200);
    }];
    
    
}

- (IBAction)handleSubmit {
    if (empty(self.textView.text)) {
        [SVProgressHUD showErrorWithStatus:@"请输入意见"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"提交中..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:@"提交成功"];
        [self.navigationController popViewControllerAnimated:YES];
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
