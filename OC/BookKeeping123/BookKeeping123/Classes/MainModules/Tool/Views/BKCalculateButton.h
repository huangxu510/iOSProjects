//
//  BKCalculateButton.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/19.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKCalculateButton : UIView

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events;

@end
