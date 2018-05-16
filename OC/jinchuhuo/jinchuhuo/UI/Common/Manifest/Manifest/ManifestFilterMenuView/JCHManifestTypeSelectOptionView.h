//
//  JCHManifestTypeSelectOptionView.h
//  jinchuhuo
//
//  Created by huangxu on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHManifestTypeSelectOptionView : UIView

@property (nonatomic, assign, readonly) CGFloat viewHeight;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) void(^buttonClick)(UIButton *button);

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                   dataSource:(NSArray *)dataSource;

- (void)cancleSelect;

@end
