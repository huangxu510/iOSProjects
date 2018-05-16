//
//  JCHTakeoutPutawayViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ProductRecord4Cocoa.h"
#import "JCHTakeoutDataConstant.h"

@interface JCHTakeoutPutawayViewController : JCHBaseViewController

- (instancetype)initWithProductRecord:(ProductRecord4Cocoa *)productRecord
                      takeoutResource:(JCHTakeoutResource)takeoutResource;

@end
