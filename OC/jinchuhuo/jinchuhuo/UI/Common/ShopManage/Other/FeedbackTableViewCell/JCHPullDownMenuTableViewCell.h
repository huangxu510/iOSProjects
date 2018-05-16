//
//  JCHFeedbackTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHPullDownMenuTableViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setNameLabel:(NSString *)text;
- (NSString *)nameLabelText;
- (void)setCheckmarkImageViewSelected:(BOOL)selected;
- (void)setNameLabelTextColor:(UIColor *)textColor;

@end
