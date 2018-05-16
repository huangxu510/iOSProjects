//
//  JCHRestaurantOpenTableCollectionViewCell.m
//  jinchuhuo
//
//  Created by apple on 2017/1/3.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestaurantOpenTableCollectionViewCell.h"
#import "CommonHeader.h"


@implementation JCHRestaurantOpenTableCollectionViewCellData

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    self.regionName = nil;
    self.tableName = nil;
    [super dealloc];
    return;
}

@end



@interface JCHRestaurantOpenTableCollectionViewCell ()
{
    UILabel *titleLabel;
    UILabel *detailLabel;
}
@end


@implementation JCHRestaurantOpenTableCollectionViewCell

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
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"A区03"
                                      font:JCHFont(16.0)
                                 textColor:nil
                                    aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    detailLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"0/0"
                                       font:JCHFont(10.0)
                                  textColor:nil
                                     aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:detailLabel];
    detailLabel.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_centerY).with.offset(7);
        make.height.mas_equalTo(28);
    }];
    
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_centerY).with.offset(3);
        make.height.mas_equalTo(16);
    }];
    
    return;
}

- (void)setCellData:(JCHRestaurantOpenTableCollectionViewCellData *)cellData
{
    UIColor *borderColor = nil;
    UIColor *backgroundColor = nil;
    UIColor *titleColor = nil;
    UIColor *detailColor = nil;
    
    switch (cellData.enumType) {
        case kJCHRestaurantOpenTableCollectionViewCellAvaliable:
        {
            borderColor = UIColorFromRGB(0XD5D5D5);
            backgroundColor = [UIColor whiteColor];
            titleColor = UIColorFromRGB(0XA4A4A4);
            detailColor = UIColorFromRGB(0XA4A4A4);
        }
            break;
            
        case kJCHRestaurantOpenTableCollectionViewCellLock:
        {
            borderColor = UIColorFromRGB(0XDD4041);
            backgroundColor = [UIColor whiteColor];
            titleColor = UIColorFromRGB(0XDD4041);
            detailColor = UIColorFromRGB(0XDD4041);
        }
            break;
            
        case kJCHRestaurantOpenTableCollectionViewCellReserved:
        {
            borderColor = JCHColorHeaderBackground;
            backgroundColor = JCHColorHeaderBackground;
            titleColor = [UIColor whiteColor];
            detailColor = [UIColor whiteColor];
        }
            break;
            
        case kJCHRestaurantOpenTableCollectionViewCellInUse:
        {
            borderColor = UIColorFromRGB(0X6FA13C);
            backgroundColor = UIColorFromRGB(0X88C14E);
            titleColor = [UIColor whiteColor];
            detailColor = [UIColor whiteColor];
        }
            break;
            
        default:
            break;
    }
    
    self.contentView.layer.cornerRadius = 2.78;
    self.contentView.layer.borderWidth = kSeparateLineWidth;
    self.contentView.layer.borderColor = [borderColor CGColor];
    self.contentView.backgroundColor = backgroundColor;
    
    titleLabel.textColor = titleColor;
    detailLabel.textColor = detailColor;
    titleLabel.text = [NSString stringWithFormat:@"%@%@", cellData.regionName, cellData.tableName];
    detailLabel.text = [NSString stringWithFormat:@"%d/%d", (int)cellData.peopleCount, (int)cellData.seatCount];
}

@end
