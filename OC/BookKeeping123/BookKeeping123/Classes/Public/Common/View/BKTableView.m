//
//  BKTableView.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/18.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKTableView.h"

@implementation BKTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}

@end
