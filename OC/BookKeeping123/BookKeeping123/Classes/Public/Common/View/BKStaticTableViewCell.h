//
//  MPStaticTableViewCell.h
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BKWordItem;
@interface BKStaticTableViewCell : UITableViewCell

/** 静态单元格模型 */
@property (nonatomic, strong) BKWordItem *item;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
