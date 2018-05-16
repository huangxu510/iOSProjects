//
//  MTRowIndexView.h
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTRowIndexView : UIView

@property (nonatomic, copy) NSArray *indexesArray;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) void(^labelTapAction)(NSInteger index);

@end
