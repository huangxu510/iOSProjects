//
//  JCHInventoryPullDownView.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHInventoryPullDownBaseView.h"

typedef void(^CompletionBlock)(void);

@protocol JCHInventoryPullDownContainerViewDelegate <NSObject>

@optional

- (void)clickMaskView;
- (void)showAlertView;

@end

@interface JCHInventoryPullDownContainerView : UIView
@property (nonatomic, assign) id <JCHInventoryPullDownContainerViewDelegate> delegate;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) BOOL isShow;


- (void)show:(JCHInventoryPullDownBaseView *)view;
- (void)hideCompletion:(CompletionBlock)completion;

@end
