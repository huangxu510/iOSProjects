//
//  JCHInventoryTableViewSectionView.m
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHInventoryTableViewSectionView.h"
#import "CommonHeader.h"
#import "Masonry.h"

enum {
    kInventoryCellCountLabelWidth = 55,
};

@interface JCHInventoryTableViewSectionView ()
{
    UIView *_buttonsContentView;
    UIButton *_searchButton;
    UIView *_bottomLineView;
}

@property (nonatomic, retain) NSMutableArray *arrowImageViews;
@property (nonatomic, retain) NSArray *titles;

@end

@implementation JCHInventoryTableViewSectionView

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.arrowImageViews = [NSMutableArray array];
        [self createUI];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)dealloc
{
    [self.arrowImageViews release];
    [self.selectedButton release];
    [self.titles release];
    [self.searchBar release];
    
    NSLog(@"call %s", __PRETTY_FUNCTION__);
    
    [super dealloc];
    return;
}

- (void)createUI
{
    
    UIFont *titleFont = [UIFont systemFontOfSize:14.0f];
    UIColor *titleColor = JCHColorMainBody;
    UIColor *selectedTitleColor = JCHColorHeaderBackground;
    CGFloat buttonHeight = 44;
    CGFloat buttonWidth = (self.frame.size.width - buttonHeight) / self.titles.count;
    CGFloat edgeInsetOffset = 16.0f;
    
    _buttonsContentView = [[[UIView alloc] init] autorelease];
    _buttonsContentView.frame = CGRectMake(0, 0, 2 * kScreenWidth, buttonHeight);
    [self addSubview:_buttonsContentView];
    _buttonsContentView.clipsToBounds = NO;
    
    

    for (NSInteger i = 0; i < self.titles.count; i++) {
        
        CGRect frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
        
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleButtonClickAction:)
                                                title:self.titles[i]
                                           titleColor:titleColor
                                      backgroundColor:[UIColor whiteColor]];
        button.titleLabel.font = titleFont;
        button.tag = kJCHInventoryTableViewSectionViewButtonFirstTag + i;
        button.frame = frame;
        [button setImage:[UIImage imageNamed:@"inventory_multiselect_open_icon"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"inventory_multiselect_close_icon"] forState:UIControlStateSelected];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -edgeInsetOffset, 0, edgeInsetOffset)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 2 * edgeInsetOffset, 0, -2 * edgeInsetOffset)];
        [button setTitleColor:selectedTitleColor forState:UIControlStateSelected];
        [_buttonsContentView addSubview:button];
    }

    
    _searchButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleButtonClickAction:)
                                         title:nil
                                    titleColor:titleColor
                               backgroundColor:[UIColor whiteColor]];
    _searchButton.titleLabel.font = titleFont;
    _searchButton.tag = kJCHInventoryTableViewSectionViewSearchButtonTag;
    _searchButton.frame = CGRectMake(self.titles.count * buttonWidth, 0, buttonHeight, buttonHeight);
    [_searchButton setImage:[UIImage imageNamed:@"inventory_ic_search"] forState:UIControlStateNormal];
    [_buttonsContentView addSubview:_searchButton];

    
    UIView *verticalSeprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kSeparateLineWidth, buttonHeight)] autorelease];
    verticalSeprateLine.backgroundColor = JCHColorSeparateLine;
    [_searchButton addSubview:verticalSeprateLine];
    
    _bottomLineView = [[[UIView alloc] init] autorelease];
    _bottomLineView.backgroundColor = JCHColorSeparateLine;
    _bottomLineView.frame = CGRectMake(0, 44 - kSeparateLineWidth, self.frame.size.width, kSeparateLineWidth);
    [_buttonsContentView addSubview:_bottomLineView];
    
    self.searchBar = [[[JCHSearchBar alloc] initWithFrame:CGRectZero] autorelease];
    self.searchBar.frame = CGRectMake(self.frame.size.width, 0, kScreenWidth, buttonHeight);
    NSAttributedString *placeHolder = [[[NSAttributedString alloc] initWithString:@"请输入商品名称/拼音首字母" attributes:@{NSForegroundColorAttributeName : JCHColorAuxiliary, NSFontAttributeName : [UIFont systemFontOfSize:13.0f]}] autorelease];
    self.searchBar.textField.attributedPlaceholder = placeHolder;
    [_buttonsContentView addSubview:self.searchBar];
    
    
    
    return;
}


- (void)handleButtonClickAction:(UIButton *)sender
{
    //本次点击和上次不是同一个
    if (self.selectedButton != sender && self.selectedButton) {
        self.selectedButtonChanged = YES;
        self.selectedButton.selected = NO;
    } else {
        self.selectedButtonChanged = NO;
    }
    
    self.selectedButton = sender;
    
    self.searchBar.delegate = self.searchDelegate;
    
    
    if ([self.delegate respondsToSelector:@selector(handleButtonClick:)]) {
        [self.delegate handleButtonClick:sender];
    }
}


- (void)showSearchBar:(BOOL)showFlag
{
    CGRect buttonsContentFrame = _buttonsContentView.frame;
    if (showFlag) {
        buttonsContentFrame.origin.x -= kScreenWidth;
    } else {
        buttonsContentFrame.origin.x += kScreenWidth;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _buttonsContentView.frame = buttonsContentFrame;
    }];
    
    return;
}

@end
