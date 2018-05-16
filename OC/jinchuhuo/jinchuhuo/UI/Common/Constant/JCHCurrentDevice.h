//
//  JCHCurrentDevice.h
//  jinchuhuo
//
//  Created by huangxu on 15/8/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef jinchuhuo_JCHCurrentDevice_h
#define jinchuhuo_JCHCurrentDevice_h

//#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),  [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334),  [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6PlusEnlarger ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)





#ifndef JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7                               
#define JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7                               \
do                                                                      \
{                                                                       \
    /* check iOS < 8 */                                                 \
    if([UIDevice currentDevice].systemVersion.doubleValue < 8.0) {      \
        [super layoutSubviews];                                         \
    }                                                                   \
} while( 0 )
#endif


#define kCurrentSystemVersion [UIDevice currentDevice].systemVersion.doubleValue


#endif

//#endif
