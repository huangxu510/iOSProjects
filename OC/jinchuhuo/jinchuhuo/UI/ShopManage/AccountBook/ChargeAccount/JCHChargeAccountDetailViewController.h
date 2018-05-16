//
//  JCHChargeAccountDetailViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHChargeAccountViewController.h"

@interface JCHChargeAccountDetailViewController : JCHBaseViewController

@property (nonatomic, retain) NSMutableArray *allManifest;

- (instancetype)initWithContactsUUID:(NSString *)contactsUUID
                   chargeAccountType:(JCHChargeAccountType)chargeAccountType;

@end
