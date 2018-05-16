//
//  JCHSearchBar.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCHSearchBar;
@protocol JCHSearchBarDelegate <NSObject>

@optional
- (void)searchBarCancelButtonClicked:(JCHSearchBar *)searchBar;
- (void)searchBarTextChanged:(JCHSearchBar *)searchBar;
- (void)searchBarDidBeginEditing:(JCHSearchBar *)searchBar;
- (void)searchBarDidEndEditing:(JCHSearchBar *)searchBar;

@end

@interface JCHSearchBar : UIView

@property (nonatomic, assign) id<JCHSearchBarDelegate> delegate;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIColor *cancleButtonTitleColor;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)showCancelButton:(BOOL)showButton;

@end
