//
//  BKHomePageViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKHomePageViewController.h"
#import "BKBookKeepingModel.h"

@interface BKHomePageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *billInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;
@property (weak, nonatomic) IBOutlet UITextField *textField4;
@property (weak, nonatomic) IBOutlet UITextField *textField5;
@property (weak, nonatomic) IBOutlet UITextField *textField6;
@property (weak, nonatomic) IBOutlet UITextField *textField7;
@property (weak, nonatomic) IBOutlet UITextField *textField8;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;


@end



@implementation BKHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"记账";
    
    BKCornerRadius(self.saveButton, 5);
    BKCornerRadius(self.containerView, 5);
    BKShadow(self.containerView, 3, 0.1);
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (IBAction)handleCalculate {
    CGFloat trafficFee = _textField1.text.doubleValue;
    CGFloat homeFee = _textField2.text.doubleValue;
    CGFloat medicalFee = _textField3.text.doubleValue;
    CGFloat socialFee = _textField4.text.doubleValue;
    CGFloat otherFee = _textField5.text.doubleValue;
    CGFloat salaryIncome = _textField6.text.doubleValue;
    CGFloat otherIncome = _textField7.text.doubleValue;
    
    CGFloat totalAmount = salaryIncome + otherIncome - trafficFee - homeFee - medicalFee - socialFee - otherFee;
    _textField8.text = [NSString stringWithFormat:@"%.2f", totalAmount];
    _billInfoLabel.text = [NSString stringWithFormat:@"¥ %.2f", totalAmount];
    
    [self saveData];
}


- (void)loadData {
    BKBookKeepingModel *model = [[BKBookKeepingModel alloc] init];
    model = [model loadCache];
    
    [self setTextFieldValue:_textField1 fee:model.trafficFee];
    [self setTextFieldValue:_textField2 fee:model.homeFee];
    [self setTextFieldValue:_textField3 fee:model.medicalFee];
    [self setTextFieldValue:_textField4 fee:model.socialFee];
    [self setTextFieldValue:_textField5 fee:model.otherFee];
    [self setTextFieldValue:_textField6 fee:model.salaryIncome];
    [self setTextFieldValue:_textField7 fee:model.otherIncome];
    _textField8.text = [NSString stringWithFormat:@"%.2f", model.totalAmount];
    _billInfoLabel.text = [NSString stringWithFormat:@"¥ %.2f", model.totalAmount];
}

- (void)setTextFieldValue:(UITextField *)textField fee:(CGFloat)fee {
    if (fee != 0) {
        textField.text = [NSString stringWithFormat:@"%.2f", fee];
    }
}

- (void)saveData {
    BKBookKeepingModel *model = [[BKBookKeepingModel alloc] init];
    model.trafficFee = _textField1.text.doubleValue;
    model.homeFee = _textField2.text.doubleValue;
    model.medicalFee = _textField3.text.doubleValue;
    model.socialFee = _textField4.text.doubleValue;
    model.otherFee = _textField5.text.doubleValue;
    model.salaryIncome = _textField6.text.doubleValue;
    model.otherIncome = _textField7.text.doubleValue;
    model.totalAmount = _textField8.text.doubleValue;
    [model saveCache];
}


@end
