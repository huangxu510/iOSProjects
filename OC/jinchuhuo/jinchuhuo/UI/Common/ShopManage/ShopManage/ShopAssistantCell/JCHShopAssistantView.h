//
//  JCHShopAssistantView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHShopAssistantViewData : NSObject
@property (nonatomic, retain) NSString *headImage;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *markImage;
@end

@class JCHShopAssistantView;
@protocol JCHShopAssistantViewDelegate <NSObject>

- (void)handleClickView:(JCHShopAssistantView *)view;

@end

@interface JCHShopAssistantView : UIView

@property (nonatomic, assign) id <JCHShopAssistantViewDelegate> delegate;
@property (nonatomic, retain) UIButton *headImageButton;
- (void)setData:(JCHShopAssistantViewData *)data;

@end
