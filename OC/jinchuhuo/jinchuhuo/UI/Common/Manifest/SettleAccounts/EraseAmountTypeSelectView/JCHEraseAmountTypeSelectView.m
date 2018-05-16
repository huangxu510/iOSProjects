//
//  JCHEraseAmountTypeSelectView.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHEraseAmountTypeSelectView.h"
#import "JCHSingleSelectTableViewCell.h"
#import "CommonHeader.h"

@interface JCHEraseAmountTypeSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *contentTableView;
@property (nonatomic, retain) UIView *maskView;

@end

@implementation JCHEraseAmountTypeSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.contentTableView = nil;
    self.dataSource = nil;
    self.selectBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kJCHEraseAmountTypeSelectViewItemHeight)] autorelease];
    [headerView addSeparateLineWithMasonryTop:NO bottom:YES];
    UIButton *closeButton = [JCHUIFactory createButton:CGRectZero
                                                target:self
                                                action:@selector(hideView)
                                                 title:nil
                                            titleColor:nil
                                       backgroundColor:nil];
    [closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose"] forState:UIControlStateNormal];
    [headerView addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(headerView);
        make.width.mas_equalTo(kStandardItemHeight);
    }];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"选择抹零方式"
                                               font:JCHFont(15.0)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(headerView);
        make.centerX.equalTo(headerView);
        make.width.mas_equalTo(200);
    }];
    
    
    self.contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    self.contentTableView.tableHeaderView = headerView;
    self.contentTableView.scrollEnabled = NO;
    
    [self addSubview:self.contentTableView];
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UIWindow *)keyWindow
{
    return [UIApplication sharedApplication].windows[0];
}

- (void)showView
{
    [[self keyWindow] addSubview:self];
    self.maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)] autorelease];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    [[self keyWindow] addSubview:self.maskView];
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)] autorelease];
    [self.maskView addGestureRecognizer:tap];
    
    
    [self.superview bringSubviewToFront:self];
    CGRect frame = self.frame;
    frame.origin.y -= frame.size.height;
    
    CGRect maskFrame = self.maskView.frame;
    maskFrame.size.height = kScreenHeight;
    self.maskView.frame = maskFrame;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.maskView.alpha = 0.3;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)hideView
{
    CGRect frame = self.frame;
    frame.origin.y += frame.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.maskView.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.maskView removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataSource[indexPath.row];
    if ((fmod(self.totalAmount, 1) == self.totalAmount && indexPath.row == 0) ||
        (fmod(self.totalAmount, 10) == self.totalAmount && indexPath.row == 1) ||
        (fmod(self.totalAmount, 100) == self.totalAmount && indexPath.row == 2)) {
        cell.textLabel.textColor = JCHColorDisableButton;
    } else {
        cell.textLabel.textColor = JCHColorMainBody;
    }
    cell.textLabel.font = JCHFont(14);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kJCHEraseAmountTypeSelectViewItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((fmod(self.totalAmount, 1) == self.totalAmount && indexPath.row == 0) ||
        (fmod(self.totalAmount, 10) == self.totalAmount && indexPath.row == 1) ||
        (fmod(self.totalAmount, 100) == self.totalAmount && indexPath.row == 2)) {
        return;
    }
    if (self.selectBlock) {
        self.selectBlock(indexPath.row);
    }
    [self hideView];
}

@end
