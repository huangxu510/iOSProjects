//
//  RadarView.h
//  drawRectTest
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHRadarViewDelegate <NSObject>

- (void)handleVertexViewClick:(NSInteger)tag;

@end

@interface JCHRadarView : UIView

@property (nonatomic, assign) id <JCHRadarViewDelegate>delegate;

@property (nonatomic, assign) NSInteger manageScore;
- (void)startAnimation;
- (void)setViewData:(NSArray *)scores;

@end
