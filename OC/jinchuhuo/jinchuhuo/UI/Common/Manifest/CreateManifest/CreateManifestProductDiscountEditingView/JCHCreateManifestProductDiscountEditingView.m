//
//  JCHCreateManifestProductDiscountEditingView.m
//  jinchuhuo
//
//  Created by huangxu on 16/9/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCreateManifestProductDiscountEditingView.h"
#import "CommonHeader.h"

@implementation JCHCreateManifestProductDiscountEditingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *closeButton = [JCHUIFactory createButton:CGRectZero
                                                    target:self
                                                    action:@selector(hideView)
                                                     title:nil
                                                titleColor:nil
                                           backgroundColor:nil];
        [closeButton setImage:[UIImage imageNamed:@"addgoods_btn_keyboardclose"] forState:UIControlStateNormal];
        [self addSubview:closeButton];
        
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(self);
            make.width.mas_equalTo([JCHSizeUtility calculateWidthWithSourceWidth:52.0f]);
        }];
        
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"单品折扣"
                                                     font:JCHFont(14.0)
                                                textColor:JCHColorAuxiliary
                                                   aligin:NSTextAlignmentLeft];
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kStandardLeftMargin);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self.mas_centerX);
        }];
        
        self.discountLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"折扣"
                                                  font:JCHFont(14.0)
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentCenter];
        [self addSubview:self.discountLabel];
        
        [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel.mas_right).offset(kStandardLeftMargin);
            make.top.bottom.equalTo(self);
            make.right.equalTo(closeButton.mas_left);
        }];
    }
    return self;
}

- (void)dealloc
{
    self.discountLabel = nil;
    self.hideViewBlock = nil;
    [super dealloc];
}

- (void)hideView
{
    if (self.hideViewBlock) {
        self.hideViewBlock();
    }
}

@end
