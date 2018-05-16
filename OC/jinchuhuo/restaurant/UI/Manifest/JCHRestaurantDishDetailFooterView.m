//
//  JCHRestaurantDishDetailFooterView.m
//  jinchuhuo
//
//  Created by apple on 2017/1/12.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantDishDetailFooterView.h"
#import "CommonHeader.h"

@interface JCHRestaurantDishDetailFooterView ()
{
    UILabel *detailLabel;
    UIButton *addButton;
    UIButton *completeButton;
}
@end

@implementation JCHRestaurantDishDetailFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)setPeopleCount:(NSInteger)peopleCount totalAmount:(CGFloat)totalAmount
{
    NSString *title = [NSString stringWithFormat:@"就餐人数: %d人    合计: %.2f元",
                       (int)peopleCount, totalAmount];
    detailLabel.text = title;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    detailLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"就餐人数: 0人    合计: 0.00元"
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:detailLabel];
    
    addButton = [JCHUIFactory createButton:CGRectZero target:self
                                    action:@selector(handleAdd:)
                                     title:@"加菜"
                                titleColor:[UIColor whiteColor]
                           backgroundColor:UIColorFromRGB(0XF94C07)];
    [self addSubview:addButton];
    addButton.layer.cornerRadius = 0.0;
    
    completeButton = [JCHUIFactory createButton:CGRectZero target:self
                                         action:@selector(handleComplete:)
                                          title:@"完成"
                                     titleColor:[UIColor whiteColor]
                                backgroundColor:JCHColorHeaderBackground];
    [self addSubview:completeButton];
    completeButton.layer.cornerRadius = 0.0;
    
    self.backgroundColor = UIColorFromRGB(0XFFFED4);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.33);
    }];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(detailLabel.mas_bottom);
        make.width.equalTo(self).multipliedBy(0.5);
        make.bottom.equalTo(self);
    }];
    
    [completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addButton.mas_right);
        make.top.equalTo(detailLabel.mas_bottom);
        make.width.equalTo(self).multipliedBy(0.5);
        make.bottom.equalTo(self);
    }];
}

- (void)handleAdd:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleRestaurantAddDish)]) {
        [self.delegate handleRestaurantAddDish];
    }
}

- (void)handleComplete:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleRestaurantFinish)]) {
        [self.delegate handleRestaurantFinish];
    }
}

@end
