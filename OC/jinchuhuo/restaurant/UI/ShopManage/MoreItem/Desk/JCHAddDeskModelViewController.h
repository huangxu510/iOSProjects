//
//  JCHAddDeskModelViewController.h
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

enum JCHAddDeskModelType
{
    kJCHAddDeskModelTypeAddCategory = 0,
    kJCHAddDeskModelTypeModifyCategory
};

@interface JCHAddDeskModelViewController : JCHBaseViewController

@property (nonatomic, retain) TableTypeRecord4Cocoa *tableTypeRecord;
@property (nonatomic, assign) enum JCHAddDeskModelType categoreType;
@property (nonatomic, copy) void(^sendValueBlock)(NSString *categoryName);

- (id)initWithTitle:(NSString *)title;

@end


