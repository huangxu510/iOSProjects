//
//  JCHPinYinUtility.h
//  jinchuhuo
//
//  Created by apple on 15/10/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHPinYinUtility : NSObject

//! @brief 基于汉字的UTF-8编码，获取汉字的拼音首字母
//! @note 如果未找到chineseCharacter对应的拼音字母，返回'#'
+ (char)getPinYinForChineseCharacter:(unsigned short)chineseCharacter;


//! @brief 传入商品名称(汉字形式)，返回当前商品名称的首个汉字的拼音首字母, 以字符串形式传出，形如 "A", "B", "C", "#"
+ (NSString *)getFirstPinYinLetterForProductName:(NSString *)productName;

+ (NSArray *)sortProductNameByFirstLetter:(NSArray *)allProductNameList;

@end
