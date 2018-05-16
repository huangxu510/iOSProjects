//
//  JCHOnlineUpgradeView.h
//  jinchuhuo
//
//  Created by apple on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHOnlineUpgradeViewDelegate <NSObject>

- (void)handleClickRetryButton;

@end

@interface JCHOnlineUpgradeView : UIView
@property (assign, nonatomic, readwrite) id<JCHOnlineUpgradeViewDelegate> delegate;

- (void)setStatusMessage:(NSString *)statusMessage;
- (void)startProgressAnimation;
- (void)stopProgressAnimation;
- (void)showRetryButton:(BOOL)show;


@end
