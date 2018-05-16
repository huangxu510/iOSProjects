//
//  JCHRestaurantPeopleCountInputView.h
//  jinchuhuo
//
//  Created by apple on 2017/2/7.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCHRestaurantPeopleCountInputView;
@protocol JCHRestaurantPeopleCountInputViewDelegate <NSObject>

- (void)countInputViewDidHide:(JCHRestaurantPeopleCountInputView *)keyboardView;

@end

@interface JCHRestaurantPeopleCountInputView : UIView

@property (assign, nonatomic, readwrite) id<JCHRestaurantPeopleCountInputViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame tableName:(NSString *)tableName;

- (NSString *)getInputString;

@end
