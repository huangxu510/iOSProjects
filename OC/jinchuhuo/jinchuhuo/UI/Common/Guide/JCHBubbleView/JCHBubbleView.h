//
//  JCHBubbleView.h
//  jinchuhuo
//
//  Created by huangxu on 16/2/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHBubbleView : UIImageView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) UILabel *topLabel;
@property (nonatomic, retain) UILabel *bottomLabel;

@end
