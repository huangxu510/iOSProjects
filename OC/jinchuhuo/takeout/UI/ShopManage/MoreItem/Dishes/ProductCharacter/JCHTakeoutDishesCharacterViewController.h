//
//  JCHDishCharacterViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/2.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHTakeoutDishesCharacterViewController : JCHBaseViewController

- (instancetype)initWithString:(NSString *)jsonString;

@property (copy, nonatomic) void(^saveCharacterBlock)(NSString *characterJSONString);

@end
