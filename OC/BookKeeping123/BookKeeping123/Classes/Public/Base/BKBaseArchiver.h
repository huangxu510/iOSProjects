//
//  BKBaseArchiver.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/20.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKBaseArchiver : NSObject

- (id)loadCache;

- (void)saveCache;

- (void)deleteCache;

@end
