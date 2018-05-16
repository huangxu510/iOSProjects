//
//  JCHAddedServiceManager.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddedServiceManager.h"
#import "CommonHeader.h"

static NSString *kLevelKey = @"addedServiceManager.level";
static NSString *kEndTimeKey = @"addedServiceManager.endtime";
static NSString *kRemainingDaysKey = @"addedServiceManager.remainingDays";
static NSString *kNotVerifiedTransactionIDListKey = @"addedServiceManager.notVerifiedTransactionIDList";
static NSString *kLastQueryInfoDateKey = @"kLastQueryInfoDateKey";

@implementation JCHAddedServiceManager

+ (id)shareInstance
{
    static dispatch_once_t dispatchOnce;
    static JCHAddedServiceManager *addedServuceManager = nil;
    dispatch_once(&dispatchOnce, ^{
        addedServuceManager = [[JCHAddedServiceManager alloc] init];
    });
    
    [addedServuceManager calculateRemaningDays];
    return addedServuceManager;
}

- (void)setLevel:(NSInteger)level
{
    [JCHUserDefaults setObject:@(level) forKey:kLevelKey];
    [JCHUserDefaults synchronize];
}

- (NSInteger)level
{
    if ([JCHUserDefaults objectForKey:kLevelKey] == nil) {
        return 0;
    }
    return [[JCHUserDefaults objectForKey:kLevelKey] integerValue];
}

- (void)setEndTime:(NSString *)endTime
{
    [JCHUserDefaults setObject:JCH_CHECK_IF_NIL_AND_SET_EMPTY(endTime) forKey:kEndTimeKey];
    [JCHUserDefaults synchronize];
}

- (NSString *)endTime
{
    return [JCHUserDefaults objectForKey:kEndTimeKey];
}

- (void)setRemainingDays:(NSInteger)remainingDays
{
    [JCHUserDefaults setObject:@(remainingDays) forKey:kRemainingDaysKey];
    [JCHUserDefaults synchronize];
}

- (NSInteger)remainingDays
{
    return [[JCHUserDefaults objectForKey:kRemainingDaysKey] integerValue];
}

- (void)setNotVerifiedTransactionIDList:(NSArray *)notVerifiedTransactionIDList
{
    if (notVerifiedTransactionIDList == nil) {
        notVerifiedTransactionIDList = @[];
    }
    [JCHUserDefaults setObject:notVerifiedTransactionIDList forKey:kNotVerifiedTransactionIDListKey];
    [JCHUserDefaults synchronize];
}

- (NSArray *)notVerifiedTransactionIDList
{
    if ([JCHUserDefaults objectForKey:kNotVerifiedTransactionIDListKey]) {
        return [JCHUserDefaults objectForKey:kNotVerifiedTransactionIDListKey];
    } else {
        return @[];
    }
}

- (void)setLastQueryInfoDate:(NSDate *)lastQueryInfoDate
{
    [JCHUserDefaults setObject:lastQueryInfoDate forKey:kLastQueryInfoDateKey];
    [JCHUserDefaults synchronize];
}

- (NSDate *)lastQueryInfoDate
{
    return [JCHUserDefaults objectForKey:kLastQueryInfoDateKey];
}

- (void)calculateRemaningDays
{
    if (self.level == kJCHAddedServiceNormalLevel || self.level == kJCHAddedServiceCopperLevel) {
        self.remainingDays = 0;
    } else {
        if (!self.endTime || [self.endTime isEqualToString:@""]) {
            self.remainingDays = 0;
        } else {
            //yyyy-MM-dd HH:mm:ss
            NSString *endTime = self.endTime;
            
            NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [dateFormater dateFromString:endTime];
            NSInteger endTimeIntervalSinceNow = [date timeIntervalSinceNow];
            
            if (endTimeIntervalSinceNow < 0) {
                self.remainingDays = 0;
                self.level = kJCHAddedServiceNormalLevel;
            } else {
                self.remainingDays = endTimeIntervalSinceNow / 3600 / 24;
            }
        }
    }
}

+ (void)clearStatus
{
    NSLog(@"clear AddedServiceManager status!");
    JCHAddedServiceManager *addedServiceManager = [JCHAddedServiceManager shareInstance];
    addedServiceManager.level = kJCHAddedServiceNormalLevel;
    addedServiceManager.remainingDays = 0;
    addedServiceManager.endTime = nil;
}

@end
