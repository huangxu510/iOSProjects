//
//  MPStaticTableViewController.h
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKBaseViewController.h"
#import "BKStaticTableViewCell.h"
#import "BKItemSection.h"
#import "BKWordItem.h"
#import "BKWordArrowItem.h"

// 继承自这个基类, 设置组模型就行了
@interface BKStaticTableViewController : BKBaseViewController

/** 需要把组模型添加到数据中 */
@property (nonatomic, strong) NSMutableArray<BKItemSection *> *sections;

- (BKStaticTableViewController *(^)(BKWordItem *item))addItem;

@end
