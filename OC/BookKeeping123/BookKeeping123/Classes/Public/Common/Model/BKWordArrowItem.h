//
//  MPWordArrowItem.h
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKWordItem.h"

@interface BKWordArrowItem : BKWordItem

/** 要跳转的VC */
@property (nonatomic, assign) Class destVC;
@property (nonatomic, copy) NSDictionary *keyValueInfo;

@end
