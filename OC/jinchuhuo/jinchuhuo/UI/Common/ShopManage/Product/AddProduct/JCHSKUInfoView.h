//
//  JCHSKUInfoView.h
//  jinchuhuo
//
//  Created by huangxu on 16/6/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHSKUInfoView : UIView

@property (nonatomic, copy) void(^deleteSKUBlock)(NSDictionary *data);

- (void)setViewData:(NSDictionary *)data;
- (void)hideBottomLine:(BOOL)hidden;

@end
