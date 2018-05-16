//
//  NSString+JCHString.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JCHDateStringType)
{
    kJCHDateStringType1 = 0,    //yyyy-MM-dd
    kJCHDateStringType2,        //MM-dd HH:mm
    kJCHDateStringType3,        //yyyy年MM月
    kJCHDateStringType4,        //yyyy/MM/dd
    kJCHDateStringType5,        //yyyy-MM-dd HH:mm:ss
    kJCHDateStringType6,        //yyyy年MM月dd日
    kJCHDateStringType7,        //HH:mm
    kJCHDateStringType8,        //yyyy-MM-dd HH:mm
};

@interface NSString (JCHString)

//! @brief 秒数转化成string时间
+ (NSString *)stringFromSeconds:(NSInteger)seconds dateStringType:(JCHDateStringType)type;
- (NSInteger)stringToSecondsEndTime:(BOOL)endTime;

//! @brief 数量和单位转换成string
+ (NSString *)stringFromCount:(CGFloat)count unitDigital:(NSInteger)digital;

//! @brief 取string的长度
- (int)charNumber;

- (BOOL)isEmptyString;

//! @brief json字符串转为数组或字典
- (id)jsonStringToArrayOrDictionary;

@end
