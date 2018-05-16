//
//  JCHAddContactsViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHAddContactsViewController : JCHBaseViewController

//在关系选择界面选择关系后通过该属性传回已选的关系
@property (nonatomic, retain) NSArray *currentRelationship;

//新建联系人contactsUUID传nil   新建指定关系的联系人传对应relationship，其他传nil
- (instancetype)initWithContactsUUID:(NSString *)contactsUUID
                        relationship:(NSString *)relationship;



@end
