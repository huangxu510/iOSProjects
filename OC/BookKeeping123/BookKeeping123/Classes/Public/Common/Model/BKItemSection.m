//
//  MPItemSection.m
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKItemSection.h"

@implementation BKItemSection

+ (instancetype)sectionWithItems:(NSArray<BKWordItem *> *)items andHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    BKItemSection *item = [[self alloc] init];
    if (items.count) {
        [item.items addObjectsFromArray:items];
    }
    
    item.headerTitle = headerTitle;
    item.footerTitle = footerTitle;
    
    return item;
}

- (NSMutableArray<BKWordItem *> *)items
{
    if(!_items)
    {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end
