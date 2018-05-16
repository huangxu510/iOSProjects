//
//  JCHIconTextTapView.h
//  jinchuhuo
//
//  Created by huangxu on 16/10/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHIconTextTapView : UIView

@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, copy) void (^tapBlock)(void);

@end
