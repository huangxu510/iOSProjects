//
//  JCHAddDishesTakeoutInfoViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHTakeoutInfoSetView.h"


@interface JCHAddDishesTakeoutInfoViewController : JCHBaseViewController

- (instancetype)initWithProductSKUMode:(JCHProductSKUMode)mode
                       takeoutInfoList:(NSArray *)takeoutInfoList;

@end
