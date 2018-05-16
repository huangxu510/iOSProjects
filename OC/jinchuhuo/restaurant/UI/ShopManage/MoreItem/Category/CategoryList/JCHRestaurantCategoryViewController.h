//
//  JCHRestaurantCategoryViewController.h
//  restaurant
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "CategoryRecord4Cocoa.h"

typedef NS_ENUM(NSInteger, JCHRestaurantCategoryListType)
{
    kJCHRestaurantCategoryListTypeNormal,
    kJCHRestaurantCategoryListTypeSelect,
};

@interface JCHRestaurantCategoryViewController : JCHBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void(^sendValueBlock)(CategoryRecord4Cocoa *categoryRecord);
@property (nonatomic, retain) CategoryRecord4Cocoa *selectCategoryRecord;

- (instancetype)initWithType:(JCHRestaurantCategoryListType)type;

@end

