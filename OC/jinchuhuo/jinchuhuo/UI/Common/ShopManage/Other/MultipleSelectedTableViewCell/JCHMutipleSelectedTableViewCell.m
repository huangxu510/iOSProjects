//
//  JCHCategoryListTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHMutipleSelectedTableViewCell.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import <Masonry.h>

@interface JCHMutipleSelectedTableViewCell ()
{
    UIImageView *_bottomView;
    CGFloat _currentkStandardLeftMargin;
}
@end

@implementation JCHMutipleSelectedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _currentkStandardLeftMargin = kStandardLeftMargin;
        //[self createUI];
        //设置多选cell的背景view
        UIView *backGroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.multipleSelectionBackgroundView = backGroundView;
        
        
        _bottomView = [[[UIImageView alloc] init] autorelease];
        _bottomView.image = [UIImage imageNamed:@"icon_bottomLine"];
        [self.contentView addSubview:_bottomView];
        
        
        CGFloat arrowImageViewWidth = 7;
        CGFloat arrowImageViewHeight = 12;
        self.arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_btn_next"]] autorelease];
        self.arrowImageView.hidden = YES;
        [self.contentView addSubview:self.arrowImageView];
        
        [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-kStandardLeftMargin);
            make.width.mas_equalTo(arrowImageViewWidth);
            make.height.mas_equalTo(arrowImageViewHeight);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        UIView *selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.contentView.frame.size.height)] autorelease];
        selectedBackgroundView.backgroundColor = JCHColorSelectedBackground;
        self.selectedBackgroundView = selectedBackgroundView;
    }
    
    return self;
}

- (void)dealloc
{
    self.arrowImageView = nil;
    [super dealloc];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.contentView bringSubviewToFront:_bottomView];
    [_bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(_currentkStandardLeftMargin);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)moveBottomLineLeft:(BOOL)left
{
    if (left) {
        _currentkStandardLeftMargin = 0;
    }
    else
    {
        _currentkStandardLeftMargin = kStandardLeftMargin;
    }
}

- (void)moveLastBottomLineLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    _bottomView.hidden = NO;
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        [self moveBottomLineLeft:YES];
    }
    else
    {
        [self moveBottomLineLeft:NO];
    }
}

- (void)hideLastBottomLine:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        _bottomView.hidden = YES;
    }
    else
    {
        _bottomView.hidden = NO;
    }
}


@end






