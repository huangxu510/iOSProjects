//
//  JCHAddSpecificationViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "SKURecord4Cocoa.h"

typedef NS_ENUM(NSInteger, JCHSKUType)
{
    kJCHSKUTypeAdd,
    kJCHSKUTypeModify,
};

@interface JCHAddSKUViewController : JCHBaseViewController<UITextFieldDelegate>

- (instancetype)initWithType:(JCHSKUType)type skuTypeRecord:(SKUTypeRecord4Cocoa *)skuTypeRecord;

@end
