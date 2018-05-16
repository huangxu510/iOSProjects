//
//  JCHAddCategoryViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"


enum JCHCategoryType
{
    kJCHCategoryTypeAddCategory = 0,
    kJCHCategoryTypeModifyCategory
};

@interface JCHAddCategoryViewController : JCHBaseViewController

@property (nonatomic, retain) CategoryRecord4Cocoa *categoryRecord;
@property (nonatomic, assign) enum JCHCategoryType categoreType;
@property (nonatomic, copy) void(^sendValueBlock)(NSString *categoryName);

- (id)initWithTitle:(NSString *)title;

@end
