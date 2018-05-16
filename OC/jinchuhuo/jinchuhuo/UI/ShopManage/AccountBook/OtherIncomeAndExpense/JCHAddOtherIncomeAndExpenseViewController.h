//
//  JCHAddOtherIncomeAndExpenseViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/10/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ManifestRecord4Cocoa.h"

typedef enum : NSUInteger {
    kCreateIncomeExpense,
    kModifyIncomeExpense,
} JCHIncomeExpenseOperation;

@interface JCHAddOtherIncomeAndExpenseViewController : JCHBaseViewController

- (id)initWithType:(JCHIncomeExpenseOperation)operationType transaction:(AccountTransactionRecord4Cocoa *)record;

@end
