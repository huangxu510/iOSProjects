//
//  JCHUserInfoTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBaseTableViewCell.h"

@interface JCHUserInfoTableViewCell : JCHBaseTableViewCell

- (void)setTitleLabelText:(NSString *)title;
- (void)setDetailLabelText:(NSString *)detail;
- (void)setArrowImageViewHidden:(BOOL)hide;

@end
