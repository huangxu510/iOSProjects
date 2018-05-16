//
//  JCHRestaurantOpenTableViewController.h
//  jinchuhuo
//
//  Created by apple on 2017/1/3.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCHBaseViewController.h"
#import "DiningTableRecord4Cocoa.h"

enum JCHRestaurantOpenTableOperationType
{
    kJCHRestaurantOpenTableOperationTypeOpenTable = 0,      // 开台
    kJCHRestaurantOpenTableOperationTypeChangeTable = 1,    // 换台
};

@interface JCHRestaurantOpenTableViewController : JCHBaseViewController

- (id)initWithOperationType:(enum JCHRestaurantOpenTableOperationType)enumType
                tableRecord:(DiningTableRecord4Cocoa *)tableRecord;

@end
