//
//  AnalyseIntroductionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/21.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalyseIntroductionView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "CommonHeader.h"

@interface JCHAnalyseIntroductionView () <UIScrollViewDelegate>
{
    UIScrollView *_contentScrollView;
    UIButton *_knowButton;
    UIView *_maskView;
    UIPageControl *_pageControl;
}

@property (nonatomic, retain) NSArray *imageNames;
@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSArray *details;

@end

@implementation JCHAnalyseIntroductionView

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                      details:(NSArray *)details
                   imageNames:(NSArray *)imageNames
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.details = details;
        self.imageNames = imageNames;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.buttonClick = nil;
    self.titles = nil;
    self.details = nil;
    self.imageNames = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    CGFloat scrollViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:312.0f];
    CGFloat scrollViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:367.0f];
    CGFloat imageViewHeight = [JCHSizeUtility calculateWidthWithSourceWidth:208.0f];
    
    CGFloat titlaLabelTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
    CGFloat titleLabelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:40.0f];
    
    CGFloat detailLabelHeight = [JCHSizeUtility calculateWidthWithSourceWidth:70.0f];
    //CGFloat buttonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:kStandardButtonHeight];
    
    _contentScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)] autorelease];
    _contentScrollView.contentSize = CGSizeMake(scrollViewWidth * 5, 0);
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.backgroundColor = [UIColor whiteColor];
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_contentScrollView];
    
    
    for (NSInteger i = 0; i < self.titles.count; i++) {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:self.imageNames[i]]] autorelease];
        imageView.frame = CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, imageViewHeight);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_contentScrollView addSubview:imageView];
        
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:self.titles[i]
                                                  font:JCHFont(18.0f)
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentCenter];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 0;
        [_contentScrollView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).with.offset(titlaLabelTopOffset);
            make.height.mas_equalTo(titleLabelHeight);
            make.left.equalTo(imageView).with.offset(kStandardLeftMargin * 1.5);
            make.right.equalTo(imageView).with.offset(-kStandardLeftMargin * 1.5);
        }];
        
        UILabel *detailLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:self.details[i]
                                                    font:JCHFont(13.0)
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentLeft];
        detailLabel.numberOfLines = 0;
        [_contentScrollView addSubview:detailLabel];
        
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom);
            make.height.mas_equalTo(detailLabelHeight);
            make.left.right.equalTo(titleLabel);
        }];
        
        NSMutableParagraphStyle *para = [[[NSMutableParagraphStyle alloc] init] autorelease];
        para.lineSpacing = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:5.0f];
        NSAttributedString *detailText = [[[NSAttributedString alloc] initWithString:self.details[i]
                                                                          attributes:@{NSParagraphStyleAttributeName : para, NSForegroundColorAttributeName : JCHColorMainBody,
                                                                                       NSFontAttributeName : JCHFont(13.0)}] autorelease];
        detailLabel.attributedText = detailText;
    }
    
    _knowButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(hide)
                                       title:@"知道了"
                                  titleColor:JCHColorMainBody
                             backgroundColor:nil];
    _knowButton.backgroundColor = [UIColor whiteColor];
    _knowButton.layer.borderColor = [UIColor clearColor].CGColor;
    [_knowButton addSeparateLineWithMasonryTop:YES bottom:NO];
    [self addSubview:_knowButton];
    
    [_knowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.top.equalTo(_contentScrollView.mas_bottom).with.offset(-1);
    }];
    
    _pageControl = [[[UIPageControl alloc] init] autorelease];
    _pageControl.numberOfPages = self.titles.count;
    _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xd5d5d5);
    _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xa4a4a4);
    _pageControl.enabled = NO;
    [self addSubview:_pageControl];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_knowButton.mas_top);
        make.width.centerX.equalTo(_knowButton);
        make.height.mas_equalTo(30);
    }];
}

- (void)hide
{
    if (self.buttonClick) {
        self.buttonClick();
    }
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    _pageControl.currentPage = index;
    [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.frame.size.width * index, 0)];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)scrollView.contentOffset.x / (NSInteger)scrollView.frame.size.width;
    _pageControl.currentPage = index;
}

@end
