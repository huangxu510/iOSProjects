//
//  JCHProductDetailViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHProductDetailViewController : JCHBaseViewController

- (id)initWithName:(NSString *)productUUID
          unitUUID:(NSString *)unitUUID
       warehouseID:(NSString *)warehouseID;

@end
