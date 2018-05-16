//
//  JCHPrinterViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHPrinterItemModel : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *detail;
@property (retain, nonatomic) NSString *imageName;

@end

@interface JCHPrinterViewController : JCHBaseViewController

@end
