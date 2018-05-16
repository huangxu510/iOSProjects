//
//  JCHAddRestaurantCategoryViewController.h
//  restaurant
//
//  Created by apple on 2016/11/30.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHBaseViewController.h"
#import "ServiceFactory.h"


enum JCHRestaurantCategoryType
{
    kJCHRestaurantCategoryTypeAddCategory = 0,
    kJCHRestaurantCategoryTypeModifyCategory
};

@interface JCHAddRestaurantCategoryViewController : JCHBaseViewController

@property (nonatomic, retain) CategoryRecord4Cocoa *categoryRecord;
@property (nonatomic, assign) enum JCHRestaurantCategoryType categoreType;
@property (nonatomic, copy) void(^sendValueBlock)(NSString *categoryName);

- (id)initWithTitle:(NSString *)title;

@end

