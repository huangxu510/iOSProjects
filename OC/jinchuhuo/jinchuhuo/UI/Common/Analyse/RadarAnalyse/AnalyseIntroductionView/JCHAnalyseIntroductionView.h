//
//  AnalyseIntroductionView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/21.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAnalyseIntroductionView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                      details:(NSArray *)details
                   imageNames:(NSArray *)imageNames;

@property (nonatomic, copy) void(^buttonClick)(void);
@property (nonatomic, assign) NSInteger index;

@end
