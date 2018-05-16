//
//  MTSeatSelectionView.m
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import "MTSeatSelectionView.h"
#import "MTSeatsView.h"
#import "UIView+Extension.h"
#import "MTRowIndexView.h"
#import "MTTimeGraduationView.h"

@interface MTSeatSelectionView () <UIScrollViewDelegate>

@property (nonatomic, copy) void(^actionBlock)(MTSeatButton *);
@property (nonatomic, copy) void(^roomIndexActionBlock)(NSInteger);
@property (nonatomic, retain) UIScrollView *seatScrollView;
@property (nonatomic, retain) MTSeatsView *seatsView;
@property (nonatomic, retain) MTRowIndexView *rowIndexView;
@property (nonatomic, retain) MTTimeGraduationView *timeGraduationView;

@end

@implementation MTSeatSelectionView

- (instancetype)initWithFrame:(CGRect)frame
                   SeatsArray:(NSMutableArray *)seatsArray
           seatBtnActionBlock:(void (^)(MTSeatButton *))actionBlock
         roomIndexActionBlock:(void (^)(NSInteger))roomIndexActionBlock {
    
    if (self = [super initWithFrame:frame]) {//初始化操作
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.actionBlock = actionBlock;
        self.roomIndexActionBlock = roomIndexActionBlock;
        [self initScrollView];
        [self initSeatsView:seatsArray];
        [self initRowIndexView:seatsArray];
        [self addCoverView];
        [self initTimeGraduationView:seatsArray];
        
        //        [self initRowIndexView:seatsArray];
        //        [self initcenterLine:seatsArray];
        //        [self inithallLogo:hallName];
        [self startAnimation];//开场动画
    }
    return self;
}

- (void)initScrollView {
    UIScrollView *seatScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kMTRowIndexViewWidth, kMTTimeGraduationViewHeight, self.width - kMTRowIndexViewWidth, self.height)];
    NSLog(@"scrollViewFrame = %@", NSStringFromCGRect(self.bounds));
    seatScrollView.backgroundColor = [UIColor redColor];
    self.seatScrollView = seatScrollView;
    self.seatScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.seatScrollView.delegate = self;
    self.seatScrollView.showsHorizontalScrollIndicator = NO;
    self.seatScrollView.showsVerticalScrollIndicator = NO;
//    self.seatScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.seatScrollView];
}

- (void)initSeatsView:(NSMutableArray *)seatsArray {
    __weak typeof(self) weakSelf = self;
    MTSeatsView *seatsView = [[MTSeatsView alloc] initWithSeatsArray:seatsArray
                                                       maxNomarWidth:self.width
                                                  seatBtnActionBlock:^(MTSeatButton *seatButton) {
                                                      if (weakSelf.actionBlock) {
                                                          weakSelf.actionBlock(seatButton);
                                                      }
                                                  }];
    self.seatsView = seatsView;
    seatsView.frame = CGRectMake(kMTSeatsViewLeftMargin, kMTSeatsViewTopMargin, seatsView.seatViewWidth, seatsView.seatViewHeight);
    [self.seatScrollView insertSubview:seatsView atIndex:0];
    self.seatScrollView.maximumZoomScale = kMTSeatBtnMaxW_H / seatsView.seatBtnWidth;
    //    self.seatScrollView.contentInset = UIEdgeInsetsMake(kMTSeatsViewTopMargin, (self.width - seatsView.seatViewWidth) / 2, kMTSeatsViewTopMargin, (self.width - seatsView.seatViewWidth) / 2);
}

- (void)initRowIndexView:(NSArray *)seatsArray;
{
    __weak typeof(self) weakSelf = self;
    MTRowIndexView *rowIndexView = [[MTRowIndexView alloc] initWithFrame:CGRectMake(0, -kMTSmallMargin + kMTTimeGraduationViewHeight, kMTRowIndexViewWidth, self.seatsView.height + 2 * kMTSmallMargin)];
    self.rowIndexView = rowIndexView;
    [self addSubview:rowIndexView];
    NSMutableArray *indexesArray = [NSMutableArray array];
    for (NSArray *seatsArrayInRow in seatsArray) {
        [indexesArray addObject:[seatsArrayInRow.firstObject roomNumber]];
    }
    rowIndexView.indexesArray = indexesArray;
    
    rowIndexView.labelTapAction = ^(NSInteger index) {
        if (weakSelf.roomIndexActionBlock) {
            weakSelf.roomIndexActionBlock(index);
        }
    };
}

- (void)initTimeGraduationView:(NSArray *)seatsArray
{
    MTTimeGraduationView *timeGraduationView = [[MTTimeGraduationView alloc] initWithFrame:CGRectMake(kMTRowIndexViewWidth, 0, self.seatsView.seatViewWidth + 2 * kMTSeatsViewLeftMargin, kMTTimeGraduationViewHeight)];
    timeGraduationView.backgroundColor = [UIColor whiteColor];
    self.timeGraduationView = timeGraduationView;
    [self addSubview:timeGraduationView];
    
    timeGraduationView.timeArray = @[@"09:00", @"10:00", @"11:00", @"12:00", @"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00"];
}

- (void)addCoverView
{
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMTRowIndexViewWidth, kMTTimeGraduationViewHeight)];
    coverView.backgroundColor = [UIColor whiteColor];
    [self addSubview:coverView];
}

- (void)startAnimation{
    
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect zoomRect = [self _zoomRectInView:self.seatScrollView
                                                        forScale:kMTSeatBtnNomarW_H / self.seatsView.seatBtnHeight
                                                      withCenter:CGPointMake(self.seatsView.seatViewWidth / 2 + kMTSeatsViewLeftMargin, 0)];
                         [self.seatScrollView zoomToRect:zoomRect
                                                animated:NO];
                     } completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.seatsView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    self.rowIndexView.y = -kMTSmallMargin - self.seatScrollView.contentOffset.y + kMTTimeGraduationViewHeight;
    self.rowIndexView.height = self.seatsView.height + 2 * kMTSmallMargin;
    self.rowIndexView.scale = scrollView.zoomScale;
    
    self.timeGraduationView.x = kMTRowIndexViewWidth - self.seatScrollView.contentOffset.x;
    self.timeGraduationView.width = self.seatsView.width + 2 * kMTSeatsViewLeftMargin;
    
    scrollView.contentSize = CGSizeMake(self.timeGraduationView.width, self.seatsView.height);
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndDecelerating");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScroll");
    self.rowIndexView.y = -kMTSmallMargin - self.seatScrollView.contentOffset.y + kMTTimeGraduationViewHeight;
    self.timeGraduationView.x = kMTRowIndexViewWidth - self.seatScrollView.contentOffset.x;
}


- (CGRect)_zoomRectInView:(UIView *)view forScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = view.bounds.size.height / scale;
    zoomRect.size.width = view.bounds.size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}
@end
