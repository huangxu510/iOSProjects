//
//  BKCalculateResultView.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/18.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKCalculateResultTableViewCell.h"

@interface BKCalculateResultView : UIView

+ (void)showWithDataSource:(NSArray<BKCalculateResultTableViewCellModel *> *)dataSource;

@end
