//
//  JCHSettingSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSettingSectionView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHSettingSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = JCHColorGlobalBackground;
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:nil
                                               font:[UIFont systemFontOfSize:13.0f]
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self.mas_centerX);
        }];
        

        self.moreButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:nil
                                               title:nil
                                          titleColor:nil
                                     backgroundColor:nil];
        self.moreButton.hidden = YES;
        [self addSubview:self.moreButton];
        
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(30);
        }];
        
        self.bottomLine = [[[UIView alloc] init] autorelease];
        self.bottomLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:self.bottomLine];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        
        [self addSeparateLineWithMasonryTop:YES bottom:NO];
    }
    return self;
}


- (void)dealloc
{
    [self.titleLabel release];
    [self.moreButton release];
    [self.bottomLine release];
    [super dealloc];
}

    
@end
