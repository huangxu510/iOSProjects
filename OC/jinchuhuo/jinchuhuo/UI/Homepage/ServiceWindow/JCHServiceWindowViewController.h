//
//  JCHServiceWindowViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/10/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHServiceWindowModel : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) NSInteger order;

@end


@interface JCHServiceWindowViewController : JCHBaseViewController

@end
