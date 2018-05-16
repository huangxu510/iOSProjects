//
//  JCHManifestDetailViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "CommonHeader.h"

@interface JCHManifestDetailViewController : JCHBaseViewController<UITableViewDataSource,
                                                                    UITableViewDelegate >

- (id)initWithManifestRecord:(ManifestRecord4Cocoa *)manifestRecord;

@end
