//
//  NSString+JCHString.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "NSString+JCHString.h"

@implementation NSString (JCHString)

+ (NSString *)stringFromSeconds:(NSInteger)seconds dateStringType:(JCHDateStringType)type
{
    NSTimeInterval time = (double)seconds;
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    if (type == kJCHDateStringType1) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else if (type == kJCHDateStringType2)  {
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    } else if (type == kJCHDateStringType3) {
        [dateFormatter setDateFormat:@"yyyy年MM月"];
    } else if (type == kJCHDateStringType4) {
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    } else if (type == kJCHDateStringType5) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else if (type == kJCHDateStringType6) {
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    } else if (type == kJCHDateStringType7) {
        [dateFormatter setDateFormat:@"HH:mm"];
    } else if (type == kJCHDateStringType8){
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    } else {
        // pass
    }
    
    NSString *currentDateStr = [dateFormatter stringFromDate:detailDate];
    return currentDateStr;
}

+ (NSString *)stringTimeFromSeconds:(NSInteger)seconds
{
    NSTimeInterval time = (double)seconds;
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate:detailDate];
    return currentDateStr;
}

- (NSInteger)stringToSecondsEndTime:(BOOL)endTime
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (endTime) {
        NSString *startTimeStr = [NSString stringWithFormat:@"%@ 23:59:59", self];
        NSDate *date = [dateFormater dateFromString:startTimeStr];
        return [date timeIntervalSince1970];
    }
    else
    {
        NSString *startTimeStr = [NSString stringWithFormat:@"%@ 00:00:00", self];
        NSDate *date = [dateFormater dateFromString:startTimeStr];
        return [date timeIntervalSince1970];
    }
}

+ (NSString *)stringFromCount:(CGFloat)count unitDigital:(NSInteger)digital
{
    switch (digital) {
        case 0:
        {
            return [NSString stringWithFormat:@"%.0f", count];
        }
            break;
        case 1:
        {
            return [NSString stringWithFormat:@"%.1f", count];
        }
            break;
        case 2:
        {
            return [NSString stringWithFormat:@"%.2f", count];
        }
            break;
        case 3:
        {
            return [NSString stringWithFormat:@"%.3f", count];
        }
            break;
        case 4:
        {
            return [NSString stringWithFormat:@"%.4f", count];
        }
            break;
        case 5:
        {
            return [NSString stringWithFormat:@"%.5f", count];
        }
            break;
            
        default:
            break;
    }
    return nil;
}


- (int)charNumber
{
#if 0
    int strlength = 0;
    char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++)
    {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
#endif
    float number = 0.0;
    for (int index = 0; index < [self length]; index++)
    {
        NSString *character = [self substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return (int)(number * 2);
}

- (BOOL)isEmptyString
{
    if ([self isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)jsonStringToArrayOrDictionary
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (data) {
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        
        if (jsonObject != nil && error == nil){
            return jsonObject;
        }else{
            // 解析错误
            return nil;
        }
    } else {
        return nil;
    }
}

@end
