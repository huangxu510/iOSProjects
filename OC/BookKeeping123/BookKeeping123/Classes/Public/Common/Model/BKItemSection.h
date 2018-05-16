//
//  MPItemSection.h
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BKWordItem;
@interface BKItemSection : NSObject

/** 段头标题 */
@property (nonatomic, copy) NSString *headerTitle;

/** 段尾标题 */
@property (nonatomic, copy) NSString *footerTitle;

@property (nonatomic, strong) NSMutableArray<BKWordItem *> *items;

+ (instancetype)sectionWithItems:(NSArray<BKWordItem *> *)items andHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;
@end
