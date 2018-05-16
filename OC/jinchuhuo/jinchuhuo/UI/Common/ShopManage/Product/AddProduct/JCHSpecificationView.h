//
//  JCHSecificationView.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JCHSpecificationView;

@protocol JCHSpecificationViewDelegate <NSObject>
- (void)specificationViewAddItem:(JCHSpecificationView *)view;
@end

@interface JCHSpecificationView : UIView

@property (nonatomic, assign) id<JCHSpecificationViewDelegate>delegate;
@property (nonatomic, assign) CGFloat labelContainerViewHeight;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setLabelData:(NSDictionary *)data;
- (void)hideBottomLine:(BOOL)hidden;

@end
