//
//  JCHShopsContainerView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    kJCHShopsComponentViewHeight = 115,
    kJCHPageControlHeight = 15,
};

@protocol JCHShopsContainerViewDelegate <NSObject, UIScrollViewDelegate>

- (void)handleSwitchShop:(NSInteger)buttonTag data:(NSArray *)data;

@end

@interface JCHShopsComponentView : UIView

@property (nonatomic, retain) UIButton *shopButton;
@property (nonatomic, retain) UIImageView *arrowImageView;
@property (nonatomic, retain) UILabel *titleLabel;

@end

@interface JCHShopsContainerView : UIScrollView

@property (nonatomic, assign) id <JCHShopsContainerViewDelegate> delegate;

- (void)setViewData:(NSArray *)data;

//选择某个店铺
- (void)selectShop:(NSInteger)index;
- (void)updatePageControl:(NSInteger)index;

@end
