//
//  JCHBottomLineTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/10.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@implementation JCHBaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _topLine = [[[UIView alloc] init] autorelease];
        _topLine.backgroundColor = JCHColorSeparateLine;
        _topLine.hidden = YES;
        [self.contentView addSubview:_topLine];
        
        [_topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.contentView.mas_top);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        _bottomLineLeftOffset = kStandardLeftMargin;
        
        _bottomLine = [[[UIView alloc] init] autorelease];
        _bottomLine.backgroundColor = JCHColorSeparateLine;
        [self.contentView addSubview:_bottomLine];
        
        
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(_bottomLineLeftOffset).priorityLow();
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)dealloc
{
    [self.arrowImageView release];
    
    [super dealloc];
}

- (void)moveBottomLineLeft:(BOOL)left
{
    if (left) {
        _bottomLineLeftOffset = 0;
    }
    else
    {
        _bottomLineLeftOffset = kStandardLeftMargin;
    }
}

- (void)moveLastBottomLineLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
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
        _bottomLine.hidden = YES;
    }
    else
    {
        _bottomLine.hidden = NO;
    }
}

- (void)addTopLineForFirstCell:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        _topLine.hidden = NO;
    } else {
        _topLine.hidden = YES;
    }
}

@end
