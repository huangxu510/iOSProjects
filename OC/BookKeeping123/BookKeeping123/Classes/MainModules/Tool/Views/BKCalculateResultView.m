//
//  BKCalculateResultView.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/18.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCalculateResultView.h"
#import <pop/POP.h>

#define kRowHeight 35
#define kMaxTableViewHeight 180

@interface BKCalculateResultView () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *backgroundMaskView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (nonatomic, copy) NSArray *dataSource;

@end
@implementation BKCalculateResultView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BKCornerRadius(_contentView, 8);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BKCalculateResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"BKCalculateResultTableViewCell"];
}

+ (void)showWithDataSource:(NSArray<BKCalculateResultTableViewCellModel *> *)dataSource {
    BKCalculateResultView *view = [[NSBundle mainBundle] loadNibNamed:@"BKCalculateResultView" owner:nil options:nil].firstObject;
    view.frame = kKeyWindow.bounds;
    [kKeyWindow addSubview:view];
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    anim.springBounciness = 10.f;
    [view.contentView.layer pop_addAnimation:anim forKey:nil];
    
//    anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
//    anim.fromValue = @(0);
//    anim.toValue = @(.3);
//    anim.springBounciness = 0;
//    [view.backgroundMaskView.layer pop_addAnimation:anim forKey:nil];
    
    CGFloat totalHeight = kRowHeight * dataSource.count;
    view.tableHeightConstraint.constant = MIN(totalHeight, kMaxTableViewHeight);
    view.dataSource = dataSource;
    [view.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BKCalculateResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BKCalculateResultTableViewCell"];
    cell.data = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}
- (IBAction)dismiss:(UITapGestureRecognizer *)sender {
    [self removeFromSuperview];
}

@end
