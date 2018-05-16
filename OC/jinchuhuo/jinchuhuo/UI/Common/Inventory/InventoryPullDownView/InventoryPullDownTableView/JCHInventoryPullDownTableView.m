//
//  JCHInventoryPullDownView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInventoryPullDownTableView.h"
#import "JCHPullDownMenuTableViewCell.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"

#import <Masonry.h>

@interface JCHInventoryPullDownTableView () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_contentTableView;
}
@property (nonatomic, retain) NSArray *dataSource;
@end

@implementation JCHInventoryPullDownTableView

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
    [self.dataSource release];
    
    [super dealloc];
}

- (void)createUI
{
    _contentTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0) style:UITableViewStylePlain] autorelease];
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
    _contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    
    [self addSubview:_contentTableView];
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *pullDownTableViewCell = @"PullDownTableViewCell";
    JCHPullDownMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pullDownTableViewCell];
    if (cell == nil) {
        cell =  [[[JCHPullDownMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pullDownTableViewCell] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setNameLabel:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iPhone4) {
        return 35;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selectedRow: buttonTag:)]) {
        [self.delegate selectedRow:indexPath.row buttonTag:self.tag];
        JCHPullDownMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = YES;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHPullDownMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}


- (void)setData:(NSArray *)data
{
    self.dataSource = data;
    [_contentTableView reloadData];
    
    CGRect frame = _contentTableView.frame;
    frame.size.height = _contentTableView.contentSize.height;
    _contentTableView.frame = frame;
    self.maxHeight = _contentTableView.contentSize.height;
    
    //默认选中最后一个cell （不排序）
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [_contentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

//手动选择某一个cell
- (void)selectCell:(NSInteger)index
{
    NSIndexPath *originalIndexPath = [_contentTableView indexPathForSelectedRow];
    JCHPullDownMenuTableViewCell *originalCell = [_contentTableView cellForRowAtIndexPath:originalIndexPath];
    originalCell.selected = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_contentTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    JCHPullDownMenuTableViewCell *cell = [_contentTableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
}


@end
