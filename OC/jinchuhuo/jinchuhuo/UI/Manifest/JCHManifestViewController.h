//
//  JCHManifestViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHManifestViewController : JCHBaseViewController<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, assign) BOOL isNeedReloadPartData;

- (void)clearData;

@end
