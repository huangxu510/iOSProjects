//
//  JCHRestaurantOpenTableTopView.m
//  jinchuhuo
//
//  Created by apple on 2017/1/13.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantOpenTableTopView.h"
#import "CommonHeader.h"


@interface JCHRestaurantOpenTableTopItemView : UIView

- (id)initWithFrame:(CGRect)frame
    backgroundColor:(UIColor *)backgroundColor
        borderColor:(UIColor *)borderColor
              title:(NSString *)title;

@end

@interface JCHRestaurantOpenTableTopItemView ()
{
    UILabel *imageLabel;
    UILabel *titleLabel;
}
@end

@implementation JCHRestaurantOpenTableTopItemView

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI:backgroundColor
           borderColor:borderColor
                 title:title];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor title:(NSString *)title
{
    imageLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:nil
                                 textColor:nil
                                    aligin:NSTextAlignmentCenter];
    [self addSubview:imageLabel];
    
    imageLabel.layer.cornerRadius = 2.0;
    imageLabel.backgroundColor = backgroundColor;
    imageLabel.layer.borderColor = [borderColor CGColor];
    imageLabel.layer.borderWidth = kSeparateLineWidth;
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:title
                                      font:JCHFont(13.0)
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self addSubview:titleLabel];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(17);
        make.width.mas_equalTo(17);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageLabel.mas_right).with.offset(8.0);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(20);
        make.right.equalTo(self.mas_right);
    }];
    
    return;
}

@end



////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////


@interface JCHRestaurantOpenTableTopView()
{
    JCHRestaurantOpenTableTopItemView *firstView;
    JCHRestaurantOpenTableTopItemView *secondView;
    JCHRestaurantOpenTableTopItemView *thirdView;
    JCHRestaurantOpenTableTopItemView *fourthView;
    UIView *bottomSeperatorView;
}
@end

@implementation JCHRestaurantOpenTableTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    self.backgroundColor = [UIColor whiteColor];
    
    firstView = [[[JCHRestaurantOpenTableTopItemView alloc] initWithFrame:CGRectZero
                                                          backgroundColor:[UIColor whiteColor]
                                                              borderColor:UIColorFromRGB(0XD5D5D5)
                                                                    title:@"可选"] autorelease];
    [self addSubview:firstView];
    
    secondView = [[[JCHRestaurantOpenTableTopItemView alloc] initWithFrame:CGRectZero
                                                           backgroundColor:[UIColor whiteColor]
                                                               borderColor:UIColorFromRGB(0XDD4041)
                                                                     title:@"锁定"] autorelease];
    [self addSubview:secondView];
    
//    thirdView = [[[JCHRestaurantOpenTableTopItemView alloc] initWithFrame:CGRectZero
//                                                          backgroundColor:JCHColorHeaderBackground
//                                                              borderColor:JCHColorHeaderBackground
//                                                                    title:@"预订"] autorelease];
//    [self addSubview:thirdView];
    
    fourthView = [[[JCHRestaurantOpenTableTopItemView alloc] initWithFrame:CGRectZero
                                                           backgroundColor:UIColorFromRGB(0X88C14E)
                                                               borderColor:UIColorFromRGB(0X6FA13C)
                                                                     title:@"就餐中"] autorelease];
    [self addSubview:fourthView];
    
    bottomSeperatorView = [JCHUIFactory createSeperatorLine:1.0];
    bottomSeperatorView.backgroundColor = UIColorFromRGB(0XD5D5D5);
    [self addSubview:bottomSeperatorView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat labelWidth = (kScreenWidth - 2 * kStandardLeftMargin) / 3;
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(3 * kStandardLeftMargin);
        make.top.and.bottom.equalTo(self);
        make.width.mas_equalTo(labelWidth);
    }];
    
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstView.mas_right);
        make.top.and.bottom.equalTo(self);
        make.width.mas_equalTo(labelWidth);
    }];
    
//    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(secondView.mas_right);
//        make.top.and.bottom.equalTo(self);
//        make.width.mas_equalTo(labelWidth);
//    }];
    
    [fourthView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(secondView.mas_right);
        make.top.and.bottom.equalTo(self);
        make.width.mas_equalTo(labelWidth);
    }];
    
    [bottomSeperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_offset(kSeparateLineWidth);
    }];
}

@end
