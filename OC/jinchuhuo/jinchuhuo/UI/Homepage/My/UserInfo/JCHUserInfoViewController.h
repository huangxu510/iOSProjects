//
//  JCHUserInfoViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/6.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

@interface JCHUserInfoViewController : JCHBaseViewController

- (void)doUpdateUserProfile;

//! @brief 用户退出登录时，清理用户登录状态
+ (void)clearUserLoginStatus;

@end
