//
//  JCHBottomLineTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/10.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@interface JCHBaseTableViewCell : UITableViewCell
{
    @public
    UIView *_bottomLine;
    UIView *_topLine;
    CGFloat _bottomLineLeftOffset;
}

@property (nonatomic, retain) UIImageView *arrowImageView;

- (void)moveBottomLineLeft:(BOOL)left;
- (void)moveLastBottomLineLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)hideLastBottomLine:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)addTopLineForFirstCell:(NSIndexPath *)indexPath;
@end
