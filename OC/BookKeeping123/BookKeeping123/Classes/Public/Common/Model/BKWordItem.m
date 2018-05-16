//
//  MPWordItem.m
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKWordItem.h"

@implementation BKWordItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _titleColor = HexColor(0x33333);
        _subTitleColor = [UIColor lightGrayColor];
        
        _cellHeight = AdaptedWidth(50);
        _titleFont = AdaptedFontSize(14);
        _subTitleFont = AdaptedFontSize(14);
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    BKWordItem *item = [[self alloc] init];
    item.subTitle = subTitle;
    item.title = title;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle itemOperation:(void(^)(NSIndexPath *indexPath))itemOperation {
    BKWordItem *item = [self itemWithTitle:title subTitle:subTitle];
    item.itemOperation = itemOperation;
    return item;
}

@end
