//
//  JCHTextView.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

//! @brief 带placeholder的textView
@interface JCHTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic, assign) BOOL isAutoHeight;
@property (nonatomic, assign) CGFloat minHeight;

@end
