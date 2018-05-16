//
//  NSObject+JCHObject.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "NSObject+JCHObject.h"

@implementation NSObject (JCHObject)

- (NSString *)dataToJSONString
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    }
    return jsonString;
}


@end
