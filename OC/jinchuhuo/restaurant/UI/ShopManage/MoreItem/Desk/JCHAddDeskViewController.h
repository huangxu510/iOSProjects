//
//  JCHAddDeskViewController.h
//  restaurant
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//


#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

enum JCHAddDeskType{
    kJCHAddDeskTypeAdd,
    kJCHAddDeskTypeModify
};

@interface JCHAddDeskViewController : JCHBaseViewController

@property (assign, nonatomic, readwrite) enum JCHAddDeskType enumAddType;
@property (retain, nonatomic, readwrite) DiningTableRecord4Cocoa *currentTableRecord;

@end


