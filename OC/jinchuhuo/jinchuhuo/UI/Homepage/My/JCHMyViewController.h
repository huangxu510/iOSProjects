//
//  JCHMyViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "JCHBaseViewController.h"

@interface JCHMyViewController : JCHBaseViewController<UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    MFMailComposeViewControllerDelegate,
                                                    UIAlertViewDelegate>

@end
