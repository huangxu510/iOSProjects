//
//  JCHAddSpecificationTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "JCHMutipleSelectedTableViewCell.h"

@interface JCHAddSKUValueTableViewCell : JCHMutipleSelectedTableViewCell

@property (nonatomic, retain) UITextField *attributeNameTextField;
@property (nonatomic, copy) void(^deleteAction)(void);

@end
