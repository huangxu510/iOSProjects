//
//  JCHMenuView.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBaseTableViewCell.h"

typedef void(^dismissCompletion)(void);



typedef enum : NSUInteger {
    kLeftTriangle,
    kRightTriangle,
    kCenterTriangle,
} TriangleDirection;

@class JCHMenuView;
@protocol JCHMenuViewDelegate <NSObject>

@optional
- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath*)indexPath;
- (void)menuViewDidHide;

@end

@interface JCHMenuViewCell : JCHBaseTableViewCell

@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *titleLabel;

@end


@interface JCHMenuView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <JCHMenuViewDelegate> delegate;
@property (nonatomic, assign) BOOL hideAnimation;
@property (nonatomic, assign) NSTextAlignment titleLabelTextAlignment;

/**
 *  初始化方法
 *
 *  @param titleArray 每个title
 *  @param imageArray 每个title对应的imageName
 *  @param origin     菜单的起始点
 *  @param width      菜单的宽度
 *  @param rowHeight  每个item的高度
 *  @param maxHeight  最大高度
 *  @param direct     TriangleDirection三角位置kLeftTriangle左，kRightTriangle右
 */
- (id)initWithTitleArray:(NSArray*)titleArray
              imageArray:(NSArray*)imageArray
                  origin:(CGPoint)origin
                   width:(CGFloat)width
               rowHeight:(CGFloat)rowHeight
               maxHeight:(CGFloat)maxHeight
                  Direct:(TriangleDirection)triDirect;

/**
 *  隐藏
 *  
 *  @param animation  隐藏是是否有动画
 *  @param completion 隐藏后block
 */
- (void)dismissMenuView:(BOOL)animation completion:(dismissCompletion)completion;
@end
