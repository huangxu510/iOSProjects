//
//  JCHCategoryListTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@interface JCHMutipleSelectedTableViewCell : SWTableViewCell

@property (nonatomic, retain) UIImageView *arrowImageView;

- (void)moveBottomLineLeft:(BOOL)left;
- (void)moveLastBottomLineLeft:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)hideLastBottomLine:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
