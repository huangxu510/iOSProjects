//
//  JCHArrowTapView.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHArrowTapView : UIView
{
@public;
    UIImageView *_arrowImageView;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UILabel *detailLabel;
@property (nonatomic, retain) UIView *bottomLine;

@property (nonatomic, assign) BOOL enable;

@end
