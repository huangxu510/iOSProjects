//
//  JCHJournalAccountDetailViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/10/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ManifestRecord4Cocoa.h"

@interface JCHJournalAccountDetailViewController : JCHBaseViewController

- (instancetype)initWithAccountTransactionRecord:(AccountTransactionRecord4Cocoa *)record;

@end
