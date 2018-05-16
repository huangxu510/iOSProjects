//
//  JCHBottomLineSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSeparateLineSectionView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@interface JCHSeparateLineSectionView ()
{
    BOOL _topLine;
    BOOL _bottomLine;
}
@end
@implementation JCHSeparateLineSectionView

- (instancetype)initWithTopLine:(BOOL)topLine BottomLine:(BOOL)bottomLine
{
    self = [super init];
    if (self) {
        self.backgroundColor = JCHColorGlobalBackground;
        _topLine = topLine;
        _bottomLine = bottomLine;
        self.frame = CGRectMake(0, 0, kScreenWidth, 20);

        UIView *topLine = [[[UIView alloc] init] autorelease];
        topLine.backgroundColor = JCHColorSeparateLine;
        
        [self addSubview:topLine];
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        
        UIView *bottomLine = [[[UIView alloc] init] autorelease];
        bottomLine.backgroundColor = JCHColorSeparateLine;
        
        [self addSubview:bottomLine];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        if (!_topLine) {
            topLine.hidden = YES;
        }
        
        if (!_bottomLine) {
            bottomLine.hidden = YES;
        }
    }
    return self;
}


@end
