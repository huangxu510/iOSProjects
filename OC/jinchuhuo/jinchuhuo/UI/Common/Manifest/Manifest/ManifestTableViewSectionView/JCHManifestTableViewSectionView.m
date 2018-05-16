//
//  JCHManifestTableViewSectionView.m
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestTableViewSectionView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "Masonry.h"


@implementation JCHManifestTableViewSectionView

- (instancetype)initWithTopLine:(BOOL)topLine BottomLine:(BOOL)bottomLine
{
    self = [super initWithTopLine:topLine BottomLine:bottomLine];
    if (self) {
        [self createUI];
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    self.backgroundColor = JCHColorGlobalBackground;
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero title:@"" font:[UIFont systemFontOfSize:12.0f] textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    [self addSubview:self.titleLabel];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}


@end
