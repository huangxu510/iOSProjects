//
//  JCHIndexSelectDropdownMenu.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    kJCHIndexSelectDropdownMenuHeight = 44,
};

@interface JCHArrowButton : UIButton

@end

@class JCHIndexSelectDropdownMenu;

@protocol JCHIndexSelectDropdownMenuDelegate <NSObject>

- (void)indexSelectDropdownMenuDidShow;
- (void)indexSelectDropdownMenuDidHide;
- (void)indexSelectDropdownMenuSortData:(BOOL)ascending;
- (void)indexSelectDropdownMenuDidHideSelectIndexPath:(NSIndexPath *)indexPath;

@end

@interface JCHIndexSelectDropdownMenu : UIView

@property (nonatomic, assign) id <JCHIndexSelectDropdownMenuDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL ascending;
@property (nonatomic, assign, getter=isShow) BOOL show;

@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, assign) CGFloat defaultOrignY;


- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView;
- (void)setManifestCount:(NSInteger)manifestCount;
- (void)hideView;

@end
