//
//  JCHTableOperationView.h
//  jinchuhuo
//
//  Created by apple on 2017/1/4.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHTableOperationViewDelegate <NSObject>

#pragma mark -
#pragma mark 撤台
- (void)handleCancelTable:(NSInteger)itemIndex;

#pragma mark -
#pragma mark 预订
- (void)handleReserveTable:(NSInteger)itemIndex;

#pragma mark -
#pragma mark 点菜
- (void)handleChooseDish:(NSInteger)itemIndex;

#pragma mark -
#pragma mark 换台
- (void)handleChangeTable:(NSInteger)itemIndex;

#pragma mark -
#pragma mark 改单
- (void)handleChangeManifest:(NSInteger)itemIndex;

@end

@interface JCHTableOperationView : UIView

@property (assign, nonatomic, readwrite) id<JCHTableOperationViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
      contentOffset:(CGFloat)contentOffset
          cellIndex:(NSInteger)cellIndex
         leftOffset:(CGFloat)leftOffset;

@end
