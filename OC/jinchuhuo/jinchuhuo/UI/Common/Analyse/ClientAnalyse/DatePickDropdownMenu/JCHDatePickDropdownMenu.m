//
//  JCHDatePickDropdownMenu.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDatePickDropdownMenu.h"
#import "JCHPullDownMenuTableViewCell.h"
#import "CommonHeader.h"

@interface JCHDatePickDropdownMenu () <UITableViewDelegate, UITableViewDataSource>

//避免循环引用 用assign
@property (nonatomic, assign) UIView *fatherView;
@property (nonatomic, retain) UIButton *datePickButton;
@property (nonatomic, retain) UITableView *contentTableView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *maskView;

@end

@implementation JCHDatePickDropdownMenu

- (instancetype)initWithFrame:(CGRect)frame controllerView:(UIView *)controllerView;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.fatherView = controllerView;
        
        self.datePickButton = [JCHUIFactory createButton:CGRectMake(0, 0, kScreenWidth, kStandardItemHeight)
                                                     target:self
                                                     action:@selector(handleSelectDateRange:)
                                                      title:@"2016-01-01 至 2016-03-31"
                                                 titleColor:JCHColorMainBody
                                            backgroundColor:[UIColor whiteColor]];
        [self.datePickButton setImage:[UIImage imageNamed:@"icon_analysis_date_close"] forState:UIControlStateNormal];
        [self.datePickButton setImage:[UIImage imageNamed:@"icon_analysis_date_open"] forState:UIControlStateSelected];
        self.datePickButton.titleLabel.font = JCHFont(14.0f);

        CGSize labelSize = [self.datePickButton.titleLabel sizeThatFits:CGSizeZero];
        CGSize imageSize = self.datePickButton.imageView.image.size;
        
        [self.datePickButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageSize.width, 0, imageSize.width)];
        [self.datePickButton setImageEdgeInsets:UIEdgeInsetsMake(0, labelSize.width + 10, 0, -labelSize.width)];
        
        [self addSubview:self.datePickButton];
        [self.datePickButton addSeparateLineWithMasonryTop:NO bottom:YES];
        
        self.contentTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        self.contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self.contentTableView registerClass:[JCHPullDownMenuTableViewCell class] forCellReuseIdentifier:@"JCHPullDownMenuTableViewCell"];
        
        self.backgroundView = [[[UIView alloc] init] autorelease];
        self.backgroundView.clipsToBounds = YES;
        [self.backgroundView addSubview:self.contentTableView];
        
        self.maskView = [[[UIView alloc] init] autorelease];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0;
        [self.fatherView addSubview:self.maskView];
    
        
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)] autorelease];
        [self.maskView addGestureRecognizer:tap];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.datePickButton.backgroundColor = backgroundColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        [_textColor release];
        _textColor = [textColor retain];
        [self.datePickButton setTitleColor:textColor forState:UIControlStateNormal];

        UIImage *normalImage = [UIImage imageNamed:@"icon_analysis_date_close"];
        UIImage *selectedImage = [UIImage imageNamed:@"icon_analysis_date_open"];
        [self.datePickButton setImage:[normalImage imageWithTintColor:textColor]  forState:UIControlStateNormal];
        [self.datePickButton setImage:[selectedImage imageWithTintColor:textColor] forState:UIControlStateSelected];
    }
}

- (void)dealloc
{
    self.dataSource = nil;
    self.datePickButton = nil;
    self.contentTableView = nil;
    self.backgroundView = nil;
    self.maskView = nil;
    self.textColor = nil;
    
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.right.bottom.equalTo(self.fatherView);
    }];
}

- (void)setOffsetY:(CGFloat)offsetY
{
    if (_offsetY != offsetY) {
        _offsetY = offsetY;
        [self.maskView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).with.offset(-offsetY);
        }];
    }
}


- (void)handleSelectDateRange:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    CGFloat contentTableViewHeight = kStandardItemHeight * self.dataSource.count;
    //展开
    if (sender.selected) {
        
        if ([self.delegate respondsToSelector:@selector(datePickDropdownMenuWillShow)]) {
            [self.delegate datePickDropdownMenuWillShow];
        }
        
        [self.fatherView bringSubviewToFront:self.maskView];
        [self.fatherView addSubview:self.backgroundView];
        [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).with.offset(-self.offsetY);
            make.left.right.equalTo(self.fatherView);
            make.height.mas_equalTo(0);
        }];
        
        [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.backgroundView);
            make.height.mas_equalTo(contentTableViewHeight);
        }];
        
        [self.backgroundView layoutIfNeeded];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(contentTableViewHeight);
                }];
                [self.backgroundView.superview layoutIfNeeded];
                self.maskView.alpha = 0.3;
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(datePickDropdownMenuDidShow)]) {
                    [self.delegate datePickDropdownMenuDidShow];
                }
            }];
        });
        
    } else {
        
        [self hideView];
    }
}

- (void)hideView
{
    [self hideViewCompletion:nil];
}

- (void)hideViewCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.backgroundView.superview layoutIfNeeded];
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(datePickDropdownMenuDidHide)]) {
            [self.delegate datePickDropdownMenuDidHide];
        }
        if (completion) {
            completion();
        }
    }];
    self.datePickButton.selected = NO;
}


- (void)setDataSource:(NSArray *)dataSource
{
    if (_dataSource != dataSource) {
        [_dataSource release];
        _dataSource = [dataSource retain];
        if (self.dataSource.count > self.defaultRow) {
            [self.contentTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.defaultRow inSection:0]
                                               animated:YES
                                         scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)setDefaultRow:(NSInteger)defaultRow
{
    _defaultRow = defaultRow;
    [self.contentTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:defaultRow inSection:0]
                                       animated:YES
                                 scrollPosition:UITableViewScrollPositionNone];
}

- (void)setTitle:(NSString *)title
{
    [_datePickButton setTitle:title forState:UIControlStateNormal];
}

- (NSString *)startTime
{
    NSArray *array = [_datePickButton.currentTitle componentsSeparatedByString:@" 至 "];
    if (array.count > 0) {
        return array[0];
    } else {
        return @"";
    }
}

- (NSString *)endTime
{
    NSArray *array = [_datePickButton.currentTitle componentsSeparatedByString:@" 至 "];
    if (array.count > 1) {
        return array[1];
    } else {
        return @"";
    }
}

- (NSString *)dateRange
{
    return _datePickButton.currentTitle;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHPullDownMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHPullDownMenuTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNameLabel:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHPullDownMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    
    [self hideViewCompletion:^{
        if ([self.delegate respondsToSelector:@selector(datePickDropdownMenuDidHideSelectRow:)]) {
            [self.delegate datePickDropdownMenuDidHideSelectRow:indexPath.row];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHPullDownMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}


@end
