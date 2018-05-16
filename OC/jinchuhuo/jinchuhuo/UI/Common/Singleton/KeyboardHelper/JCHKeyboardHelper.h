//
//  JCHKeyboardHelper.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHKeyboardHelper : NSObject
{
    BOOL _isVisible;
}
+ (instancetype)shareHelper;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@end
