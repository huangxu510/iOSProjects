//
//  JCHAddProductCategorySelectView.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddProductCategorySelectView.h"
#import "JCHAddProductTitleLabel.h"
#import "CommonHeader.h"

@interface JCHAddProductCategorySelectView ()

@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) JCHAddProductTitleLabel *selectTitleLabel;
@property (nonatomic, retain) JCHAddProductTitleLabel *lastSelectTitleLabel;
@property (nonatomic, retain) UIButton *selectButton;
@property (nonatomic, retain) UIView *backgroundMaskView;

@end

@implementation JCHAddProductCategorySelectView
{
    UIScrollView *_topContainerScrollView;
    UIScrollView *_bottomContainerScrollView;
    UIButton *_showButton;
}
- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSArray *)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = dataSource;
        self.clipsToBounds = YES;
        [self createUI];
        
        self.lastSelectTitleLabel = [_topContainerScrollView.subviews firstObject];
        self.lastSelectTitleLabel.scale = 1.0;
        self.selectTitleLabel = self.lastSelectTitleLabel;
    }
    return self;
}

- (void)dealloc
{
    self.titleLabelClickAction = nil;
    self.dataSource = nil;
    self.selectTitleLabel = nil;
    self.lastSelectTitleLabel = nil;
    self.backgroundMaskView = nil;
    self.selectButton = nil;
    
    [super dealloc];
}

- (void)createUI
{
    CGFloat arrowButtonWidth = 40;
    CGFloat topContainerScrollViewHeight = 40;
    _topContainerScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - arrowButtonWidth, topContainerScrollViewHeight)] autorelease];
    _topContainerScrollView.showsHorizontalScrollIndicator = NO;
    _topContainerScrollView.showsVerticalScrollIndicator = NO;
    _topContainerScrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_topContainerScrollView];
    
    

    _showButton = [JCHUIFactory createButton:CGRectMake(kScreenWidth - arrowButtonWidth, 0, arrowButtonWidth, topContainerScrollViewHeight)
                                      target:self
                                      action:@selector(showAllCategory:)
                                       title:@""
                                  titleColor:JCHColorMainBody
                             backgroundColor:[UIColor whiteColor]];
    [_showButton setImage:[UIImage imageNamed:@"icon_analysis_date_close"] forState:UIControlStateNormal];
    [_showButton setImage:[UIImage imageNamed:@"icon_analysis_date_open"] forState:UIControlStateSelected];
    [self addSubview:_showButton];
    
    UIView *seprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, topContainerScrollViewHeight - kSeparateLineWidth, kScreenWidth, kSeparateLineWidth)] autorelease];
    seprateLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:seprateLine];
    
    UIView *verticalLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kSeparateLineWidth, topContainerScrollViewHeight)] autorelease];
    verticalLine.backgroundColor = JCHColorSeparateLine;
    [_showButton addSubview:verticalLine];
    
    CGFloat contentSizeWidth = 0;
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        
        NSString *title = self.dataSource[i];
        CGRect labelFrame = [title boundingRectWithSize:CGSizeMake(1000, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]} context:nil];
        CGFloat labelW = labelFrame.size.width + 30;
        CGFloat labelH = topContainerScrollViewHeight;
        CGFloat labelY = 0;
        CGFloat labelX = contentSizeWidth;
        contentSizeWidth += labelW;
        JCHAddProductTitleLabel *titleLabel = [[[JCHAddProductTitleLabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)] autorelease];
        titleLabel.text = self.dataSource[i];
        titleLabel.tag = i;
        
        [titleLabel addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelClick:)] autorelease]];
        [_topContainerScrollView addSubview:titleLabel];
    }
    _topContainerScrollView.contentSize = CGSizeMake(contentSizeWidth, 0);
    
    
    _bottomContainerScrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    _bottomContainerScrollView.showsVerticalScrollIndicator = NO;
    _bottomContainerScrollView.backgroundColor = JCHColorGlobalBackground;
    [self addSubview:_bottomContainerScrollView];
    CGFloat buttonGap = 15.0f;
    CGFloat buttonHeight = 30.0f;
    CGFloat buttonWidth = (kScreenWidth - 5 * buttonGap) / 4;
    
    CGFloat bottomContainerScrollViewHeight = 0;
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        CGFloat buttonX = i % 4 * buttonWidth + (i % 4 + 1) * buttonGap;
        CGFloat buttonY = i / 4 * buttonHeight + (i / 4 + 1) * buttonGap;
        UIButton *button = [JCHUIFactory createButton:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)
                                               target:self
                                               action:@selector(titleButtonClick:)
                                                title:self.dataSource[i]
                                           titleColor:JCHColorMainBody
                                      backgroundColor:[UIColor whiteColor]];
        button.tag = i;
        button.titleLabel.font = JCHFont(13.0);
        button.layer.borderWidth = kSeparateLineWidth;
        button.layer.borderColor = JCHColorSeparateLine.CGColor;
        [button setTitleColor:JCHColorHeaderBackground forState:UIControlStateSelected];
        [_bottomContainerScrollView addSubview:button];
        
        bottomContainerScrollViewHeight = CGRectGetMaxY(button.frame);
    }
    bottomContainerScrollViewHeight += buttonGap;
    
    bottomContainerScrollViewHeight = MIN(bottomContainerScrollViewHeight, kScreenHeight - 64 - topContainerScrollViewHeight);
    _bottomContainerScrollView.frame = CGRectMake(0, topContainerScrollViewHeight, kScreenWidth, bottomContainerScrollViewHeight);
}


- (void)titleLabelClick:(UITapGestureRecognizer *)sender
{
    JCHAddProductTitleLabel *titleLabel = (JCHAddProductTitleLabel *)sender.view;
    if (titleLabel == self.lastSelectTitleLabel) {
        return;
    }
    
    [self handleTitleLabelClick:titleLabel.tag];
}

- (void)handleTitleLabelClick:(NSInteger)labelTag
{
    JCHAddProductTitleLabel *titleLabel = _topContainerScrollView.subviews[labelTag];
    
    if (self.selectTitleLabel.tag == labelTag) {
        return;
    }
    self.selectTitleLabel = titleLabel;
    
    CGFloat offsetX = titleLabel.center.x - _topContainerScrollView.frame.size.width / 2;
    CGFloat offsetMax = _topContainerScrollView.contentSize.width - _topContainerScrollView.frame.size.width;
    if (offsetX < 0) {
        offsetX = 0;
    }else if (offsetX > offsetMax){
        offsetX = offsetMax;
    }
    
    CGPoint offsetPoint = CGPointMake(offsetX, 0);
    CGFloat searchButtonWidth = 40.0f;
    if (_topContainerScrollView.contentSize.width > kScreenWidth - searchButtonWidth)
    {
        [_topContainerScrollView setContentOffset:offsetPoint animated:YES];
    }
    
    CADisplayLink *increaseDisplayLink = [CADisplayLink displayLinkWithTarget:self
                                                                     selector:@selector(handleIncreaseLabelScale:)];
    [increaseDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    CADisplayLink *decreaseDisplayLink = [CADisplayLink displayLinkWithTarget:self
                                                                     selector:@selector(handleDecreaseLabelScale:)];
    [decreaseDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    
    if (self.titleLabelClickAction) {
        self.titleLabelClickAction(titleLabel.tag);
    }
    
    if (_showButton.selected) {
        [self hideBottomView];
    }
}


- (void)titleButtonClick:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    [self handleTitleLabelClick:tag];
}


//渐减
- (void)handleDecreaseLabelScale:(CADisplayLink *)displayLink
{
    self.lastSelectTitleLabel.scale -= 1.0 / 15;
    if (self.lastSelectTitleLabel.scale <= 0) {
        self.lastSelectTitleLabel.scale = 0;
        [displayLink invalidate];
        displayLink = nil;
        self.lastSelectTitleLabel = self.selectTitleLabel;
    }
}

//渐增
- (void)handleIncreaseLabelScale:(CADisplayLink *)displayLink
{
    self.selectTitleLabel.scale += 1.0 / 15;
    if (self.selectTitleLabel.scale >= 1) {
        self.selectTitleLabel.scale = 1;
        [displayLink invalidate];
        displayLink = nil;
    }
}

- (void)setTitleLabelScale:(CGFloat)value
{
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    //NSLog(@"offsetX = %g", scrollView.contentOffset.x);
    //NSLog(@"scaleLeft = %g", scaleLeft);
    JCHAddProductTitleLabel *leftLabel = _topContainerScrollView.subviews[leftIndex];
    
   
    leftLabel.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < _topContainerScrollView.subviews.count) {
        JCHAddProductTitleLabel *rightLabel = _topContainerScrollView.subviews[rightIndex];
        
        rightLabel.scale = scaleRight;
        
        if (rightLabel.scale == 1) {
            self.lastSelectTitleLabel = rightLabel;
        }
    }
    
    if (leftLabel.scale == 1) {
        self.lastSelectTitleLabel = leftLabel;
        
        JCHAddProductTitleLabel *titleLabel = _topContainerScrollView.subviews[leftIndex];
        CGFloat offsetX = titleLabel.center.x - _topContainerScrollView.frame.size.width / 2;
        CGFloat offsetMax = _topContainerScrollView.contentSize.width - _topContainerScrollView.frame.size.width;
        if (offsetX < 0) {
            offsetX = 0;
        }else if (offsetX > offsetMax){
            offsetX = offsetMax;
        }
        
        CGPoint offsetPoint = CGPointMake(offsetX, 0);
        CGFloat searchButtonWidth = 50.0f;
        if (_topContainerScrollView.contentSize.width > kScreenWidth - searchButtonWidth)
        {
            [_topContainerScrollView setContentOffset:offsetPoint animated:YES];
        }
    }
}


- (void)showAllCategory:(UIButton *)sender
{
    if (sender.selected) {
        [self hideBottomView];
    } else {
        [self showBottomView];
    }
}

- (void)showBottomView
{
    _showButton.selected = YES;
    
    CGFloat maskViewHeight = kScreenHeight - 64 - CGRectGetMaxY(self.frame);
    self.backgroundMaskView = [[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame), kScreenWidth, maskViewHeight)] autorelease];
    self.backgroundMaskView.backgroundColor = [UIColor blackColor];
    self.backgroundMaskView.alpha = 0;
    [self.superview addSubview:self.backgroundMaskView];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBottomView)] autorelease];
    [self.backgroundMaskView addGestureRecognizer:tap];
    
    [self.superview bringSubviewToFront:self];
    CGRect frame = self.frame;
    frame.size.height += _bottomContainerScrollView.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.backgroundMaskView.alpha = 0.3;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideBottomView
{
    _showButton.selected = NO;
    
    CGRect frame = self.frame;
    frame.size.height -= _bottomContainerScrollView.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.backgroundMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundMaskView removeFromSuperview];
        self.backgroundMaskView = nil;
    }];
}

- (void)setLastSelectTitleLabel:(JCHAddProductTitleLabel *)lastSelectTitleLabel
{
    if (_lastSelectTitleLabel != lastSelectTitleLabel) {
        [_lastSelectTitleLabel release];
        _lastSelectTitleLabel = [lastSelectTitleLabel retain];
        
        self.selectButton.selected = NO;
        
        NSInteger tag = lastSelectTitleLabel.tag;
        UIButton *selectButton = _bottomContainerScrollView.subviews[tag];
        selectButton.selected = YES;
        self.selectButton = selectButton;
    }
}

@end
