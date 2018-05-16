//
//  JCHScrollMenu.h
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHScrollMenuDelegate <NSObject>

- (void)handleClickScrollMenu:(NSNumber *)menuIndex;

@end

@interface JCHScrollMenu : UIView

@property (assign, nonatomic, readwrite) id<JCHScrollMenuDelegate> delegate;

- (id)initWithFrame:(CGRect)frame menuTitles:(NSArray<NSString *> *)titlesArray;

@end
