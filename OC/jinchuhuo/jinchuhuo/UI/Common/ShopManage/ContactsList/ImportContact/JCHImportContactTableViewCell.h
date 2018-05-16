//
//  JCHImportContactTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"

@interface JCHImportContactTableViewCell : JCHBaseTableViewCell

@property (nonatomic, retain) UILabel *titleLabel;

- (void)setCheckMarkSelected:(BOOL)selected;

@end
