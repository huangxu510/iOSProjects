//
//  JCHTitleDetailView.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHTitleDetailLabel : UIView

@property (nonatomic, retain) UILabel *detailLabel;
@property (nonatomic, retain) UIView *bottomLine;

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                    textColor:(UIColor *)textColor
                       detail:(NSString *)detail
             bottomLineHidden:(BOOL)hidden;

@end
