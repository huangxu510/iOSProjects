//
//  BKBaseArchiver.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/20.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKBaseArchiver.h"

@implementation BKBaseArchiver

- (id)loadCache {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archieverPath]];
}

- (void)saveCache {
    [NSKeyedArchiver archiveRootObject:self toFile:[self archieverPath]];
}

- (void)deleteCache {
    [[NSFileManager defaultManager] removeItemAtPath:[self archieverPath] error:nil];
}


// 归档路径
- (NSString *)archieverPath{
    NSString *className = NSStringFromClass([self class]);
    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), className];
    return path;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    return [self modelInitWithCoder:coder];
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [self modelEncodeWithCoder:aCoder];
}


- (id)copyWithZone:(NSZone*)zone {
    return [self modelCopy];
}

- (NSUInteger)hash {
    return [self modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self modelIsEqual:object];
}

@end
