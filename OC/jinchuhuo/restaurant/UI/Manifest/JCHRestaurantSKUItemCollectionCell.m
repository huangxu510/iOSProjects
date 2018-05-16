//
//  JCHRestaurantSKUItemCollectionCellCollectionViewCell.m
//  jinchuhuo
//
//  Created by apple on 2017/1/11.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantSKUItemCollectionCell.h"
#import "CommonHeader.h"

@implementation JCHRestaurantSKUItemCollectionCellData

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    self.skuItemName = nil;
    [super dealloc];
    return;
}

@end


@interface JCHRestaurantSKUItemCollectionCell ()
{
    UIButton *nameButton;
}
@end


@implementation JCHRestaurantSKUItemCollectionCell

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
    nameButton = [JCHUIFactory createButton:CGRectZero
                                     target:self
                                     action:@selector(handleClickButton:)
                                      title:@""
                                 titleColor:JCHColorMainBody
                            backgroundColor:[UIColor whiteColor]];
    [nameButton.titleLabel setFont:JCHFont(12.0)];

    [self.contentView addSubview:nameButton];
    
    nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameButton.clipsToBounds = YES;
    nameButton.layer.borderWidth = 1.0;
    nameButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat verticalOffset = 8.0;
    
    [nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(verticalOffset);
        make.bottom.equalTo(self.contentView).with.offset(-verticalOffset);
    }];
    
    nameButton.layer.cornerRadius = (self.contentView.frame.size.height - 2 * verticalOffset) / 2;
    
    return;
}

- (void)setCellData:(JCHRestaurantSKUItemCollectionCellData *)data
{
    [nameButton setTitle:data.skuItemName forState:UIControlStateNormal];
    [self setSelected:data.isSelected];
}

- (void)handleClickButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleCellClick:)]) {
        [self.delegate handleCellClick:self];
    }
}

- (void)setSelected:(BOOL)isSelected
{
    if (isSelected) {
        [nameButton setTitleColor:JCHColorHeaderBackground forState:UIControlStateNormal];
        nameButton.layer.borderColor = [JCHColorHeaderBackground CGColor];
    } else {
        [nameButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
        nameButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
}

@end
