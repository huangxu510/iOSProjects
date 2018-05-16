//
//  JCHImportContactsViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHContactsInfo : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *pinyin;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, assign) BOOL selected;

@end

@interface JCHImportContactsViewController : JCHBaseViewController

@end
