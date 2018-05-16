//
//  JCHImportContactTableSectionView.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHImportContactTableSectionView.h"
#import "CommonHeader.h"

@implementation JCHImportContactTableSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UILabel *infoLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"根据右侧色彩提示对新增通讯录成员进行分组"
                                              font:[UIFont jchSystemFontOfSize:13.0]
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    infoLabel.numberOfLines = 0;
    //infoLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:infoLabel];
    
    CGSize size = [infoLabel sizeThatFits:CGSizeZero];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.height.equalTo(self);
        make.width.mas_equalTo((size.width + 10) / 2);
        make.centerY.equalTo(self);
    }];
    
   
    
    
    UILabel *colleagueLabel = [JCHUIFactory createLabel:CGRectZero
                                                  title:@"同事"
                                                   font:[UIFont jchSystemFontOfSize:15.0]
                                              textColor:[UIColor whiteColor]
                                                 aligin:NSTextAlignmentCenter];
    colleagueLabel.backgroundColor = UIColorFromRGB(0x97c26b);
    colleagueLabel.layer.cornerRadius = 3;
    colleagueLabel.clipsToBounds = YES;
    [self addSubview:colleagueLabel];
    
    CGFloat labelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    
    [colleagueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(labelWidth);
    }];
    
    UILabel *supplierLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"供应商"
                                                  font:[UIFont jchSystemFontOfSize:15.0]
                                             textColor:[UIColor whiteColor]
                                                aligin:NSTextAlignmentCenter];
    supplierLabel.backgroundColor = UIColorFromRGB(0x87a1d0);
    supplierLabel.layer.cornerRadius = 3;
    supplierLabel.clipsToBounds = YES;
    [self addSubview:supplierLabel];
    
    [supplierLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(colleagueLabel.mas_left).with.offset(-15);
        make.top.and.bottom.equalTo(colleagueLabel);
        make.width.mas_equalTo(labelWidth);
    }];
    
    UILabel *clientLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"客户"
                                                font:[UIFont jchSystemFontOfSize:15.0]
                                           textColor:[UIColor whiteColor]
                                              aligin:NSTextAlignmentCenter];
    clientLabel.backgroundColor = UIColorFromRGB(0xffbe3a);
    clientLabel.layer.cornerRadius = 3;
    clientLabel.clipsToBounds = YES;
    [self addSubview:clientLabel];
    
    
    [clientLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(supplierLabel.mas_left).with.offset(-15);
        make.top.and.bottom.equalTo(supplierLabel);
        make.width.mas_equalTo(labelWidth);
    }];
}
@end
