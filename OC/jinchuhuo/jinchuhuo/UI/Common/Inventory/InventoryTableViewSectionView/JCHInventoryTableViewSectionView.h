//
//  JCHInventoryTableViewSectionView.h
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHSearchBar.h"

typedef NS_ENUM(NSInteger, JCHInventoryTableViewSectionViewButtonTag)
{
    kJCHInventoryTableViewSectionViewButtonFirstTag = 10000,
    kJCHInventoryTableViewSectionViewButtonSecondTag,
    kJCHInventoryTableViewSectionViewButtonThirdTag,
    kJCHInventoryTableViewSectionViewButtonFourthTag,
    kJCHInventoryTableViewSectionViewSearchButtonTag = 20000,
};

@protocol  JCHInventoryTableViewSectionViewDelegate <NSObject>

- (void)handleButtonClick:(UIButton *)sender;

@end

@interface JCHInventoryTableViewSectionView : UIView


@property (nonatomic, assign, readwrite) id <JCHInventoryTableViewSectionViewDelegate>delegate;
@property (nonatomic, assign, readwrite) id <JCHSearchBarDelegate>searchDelegate;

//当前选择的按钮
@property (nonatomic, retain) UIButton *selectedButton;
@property (nonatomic, retain) JCHSearchBar *searchBar;
//记录上次点击的按钮和本次的是否一样
@property (nonatomic, assign, readwrite) BOOL selectedButtonChanged;

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
- (void)showSearchBar:(BOOL)showFlag;
- (void)handleButtonClickAction:(UIButton *)sender;

@end
