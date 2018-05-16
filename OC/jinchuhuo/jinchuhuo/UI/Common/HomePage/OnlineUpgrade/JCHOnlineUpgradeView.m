//
//  JCHOnlineUpgradeView.m
//  jinchuhuo
//
//  Created by apple on 16/3/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHOnlineUpgradeView.h"
#import "JCHUIFactory.h"
#import "CommonHeader.h"

@interface JCHOnlineUpgradeView ()
{
    UILabel *statusMessageLabel;
    UIActivityIndicatorView *progressView;
    UIButton *retryButton;
    UIView *lineView;
}
@end

@implementation JCHOnlineUpgradeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    CGRect frameRect = CGRectMake(0, 12, self.frame.size.width, self.frame.size.height / 3.0f);
    CGRect labelRect = frameRect;
    labelRect.size.width -= 20 * 2;
    labelRect.origin.x = 20;
    statusMessageLabel = [JCHUIFactory createLabel:labelRect
                                             title:@"正在进行在线升级...\n请勿退出应用，请勿删除应用，\n否则可能导致丢失数据"
                                              font:[UIFont systemFontOfSize:14.0f]
                                         textColor:[UIColor whiteColor]
                                            aligin:NSTextAlignmentCenter];
    statusMessageLabel.numberOfLines = 3;
    [self addSubview:statusMessageLabel];
    
    frameRect.origin.y += self.frame.size.height / 3.0f;
    progressView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    progressView.frame = frameRect;
    [self addSubview:progressView];
    
    CGRect lineFrame = frameRect;
    lineFrame.size.height = kSeparateLineWidth;
    lineFrame.size.width = self.frame.size.width;
    lineFrame.origin.y = self.frame.size.height - self.frame.size.height / 4.0f;
    lineView = [JCHUIFactory createSeperatorLine:1.0];
    lineView.frame = lineFrame;
    lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView];
    [self bringSubviewToFront:lineView];
    lineView.hidden = YES;
    
    frameRect.size.height = self.frame.size.height / 4.0f - kSeparateLineWidth;
    frameRect.origin.y = self.frame.size.height - self.frame.size.height / 4.0f + kSeparateLineWidth;
    retryButton = [JCHUIFactory createButton:frameRect
                                      target:self
                                      action:@selector(handleClickRetryButton:)
                                       title:@"重    试"
                                  titleColor:[UIColor whiteColor]
                             backgroundColor:[UIColor clearColor]];
    retryButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    retryButton.hidden = YES;
    
    [self addSubview:retryButton];
    
    self.layer.cornerRadius = 4.0f;
    
    return;
}

- (void)handleClickRetryButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleClickRetryButton)]) {
        [self.delegate performSelector:@selector(handleClickRetryButton)];
    }
    
    return;
}

- (void)setStatusMessage:(NSString *)statusMessage
{
    statusMessageLabel.text = statusMessage;
    return;
}

- (void)startProgressAnimation
{
    [progressView startAnimating];
    return;
}

- (void)stopProgressAnimation
{
    [progressView stopAnimating];
    return;
}

- (void)showRetryButton:(BOOL)show
{
    retryButton.hidden = !show;
    lineView.hidden = !show;
    
    return;
}

@end
