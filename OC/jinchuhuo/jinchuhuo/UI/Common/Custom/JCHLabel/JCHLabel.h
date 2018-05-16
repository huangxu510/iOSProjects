//
//  JCHLabel.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VerticalAlignment) {
    kVerticalAlignmentTop = 0,
    kVerticalAlignmentMiddle,
    kVerticalAlignmentBottom,
};

@interface JCHLabel : UILabel

@property (nonatomic, assign) VerticalAlignment verticalAlignment;
@property (nonatomic, assign) UIEdgeInsets textInset;

@end
