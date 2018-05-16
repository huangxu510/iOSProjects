//
//  BKMyCenterViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKMyCenterViewController.h"
#import "BKAboutViewController.h"
#import "BKFeedbackViewController.h"
#import "BKLoginViewController.h"

@interface BKMyCenterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (nonatomic, assign) BOOL appearFromPop;

@end

@implementation BKMyCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"我的";
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:_appearFromPop];
    _appearFromPop = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)setupUI {
    BKCornerRadius(self.headImageView, 35);
    
    WeakSelf;
    BKWordArrowItem *item0 = [BKWordArrowItem itemWithTitle:@"关于我们" subTitle:@""];
    item0.image = IMG(@"me_about");
    [item0 setItemOperation:^(NSIndexPath *indexPath) {
        weakSelf.appearFromPop = YES;
        BKAboutViewController *vc = [[BKAboutViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    BKWordArrowItem *item1 = [BKWordArrowItem itemWithTitle:@"意见反馈" subTitle:@""];
    item1.image = IMG(@"me_feedback");
    [item1 setItemOperation:^(NSIndexPath *indexPath) {
        weakSelf.appearFromPop = YES;
        BKFeedbackViewController *vc = [[BKFeedbackViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    BKWordArrowItem *item2 = [BKWordArrowItem itemWithTitle:@"常见问题" subTitle:@""];
    item2.image = IMG(@"me_question");
    [item2 setItemOperation:^(NSIndexPath *indexPath) {
        weakSelf.appearFromPop = YES;
    }];
    
    BKWordArrowItem *item3 = [BKWordArrowItem itemWithTitle:@"退出登录" subTitle:@""];
    item3.image = IMG(@"me_logout");
    [item3 setItemOperation:^(NSIndexPath *indexPath) {
        BKLoginViewController *vc = [[BKLoginViewController alloc] init];
        BKBaseNavigationController *nav = [[BKBaseNavigationController alloc] initWithRootViewController:vc];
        [weakSelf.navigationController presentViewController:nav animated:YES completion:nil];
    }];
    

    BKItemSection *section0 = [BKItemSection sectionWithItems:@[item0, item1, item2, item3] andHeaderTitle:nil footerTitle:nil];
    
    [self.sections addObject:section0];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}


@end
