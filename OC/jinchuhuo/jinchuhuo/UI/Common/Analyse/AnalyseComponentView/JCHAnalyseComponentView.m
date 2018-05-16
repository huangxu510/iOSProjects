//
//  JCHAnalyseComponentView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAnalyseComponentView.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import <Masonry.h>

@interface JCHAnalyseComponentView ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
}
@end
@implementation JCHAnalyseComponentView

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
    _imageView = [[[UIImageView alloc] init] autorelease];
    [self addSubview:_imageView];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont boldSystemFontOfSize:17]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_titleLabel];
    
    _detailLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:[UIFont jchSystemFontOfSize:12]
                                   textColor:RGBColor(128, 128, 128, 1)
                                      aligin:NSTextAlignmentLeft];
    _detailLabel.numberOfLines = 0;

    [self addSubview:_detailLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat imageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:92.0f];
    const CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:107.0f];
    const CGFloat labelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:26.0f];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(1.3 * kStandardWidthOffset);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(imageViewHeight);
        make.width.mas_equalTo(imageViewWidth);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_imageView.mas_right).with.offset(1.5 * kStandardWidthOffset);
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(labelTopOffset);
        make.height.mas_equalTo(kHeight / 5);
    }];
    
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.right.equalTo(_titleLabel).with.offset(-3 * kStandardWidthOffset);
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(0.5 * kStandardWidthOffset);
        make.height.mas_equalTo(kHeight / 3);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setImage:(NSString *)imageName title:(NSString *)title detail:(NSString *)detail titleColor:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:imageName];
    _imageView.image = image;
    _titleLabel.text = title;
    _titleLabel.textColor = color;
    
    NSMutableParagraphStyle *para = [[[NSMutableParagraphStyle alloc] init] autorelease];
    para.lineSpacing = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:3.0f];
    NSAttributedString *detailText = [[[NSAttributedString alloc] initWithString:detail attributes:@{NSParagraphStyleAttributeName : para, NSForegroundColorAttributeName : RGBColor(128, 128, 128, 1)}] autorelease];
    _detailLabel.attributedText = detailText;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    switch (self.tag) {
        case kJCHAnalyseComponentViewPurchaseTag:
        {
            self.backgroundColor = UIColorFromRGB(0xf9f6c4);
        }
            break;
        case kJCHAnalyseComponentViewShipmentTag:
        {
             self.backgroundColor = UIColorFromRGB(0xe8f5d6);
        }
            break;
        case kJCHAnalyseComponentViewProfitTag:
        {
             self.backgroundColor = UIColorFromRGB(0xfcf1e0);
        }
            break;
        case kJCHAnalyseComponentViewInventoryTag:
        {
             self.backgroundColor = UIColorFromRGB(0xd4eff9);
        }
            break;
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    switch (self.tag) {
        case kJCHAnalyseComponentViewPurchaseTag:
        {
            self.backgroundColor = RGBColor(255, 253, 223, 1);
        }
            break;
        case kJCHAnalyseComponentViewShipmentTag:
        {
            self.backgroundColor = RGBColor(245, 255, 232, 1);
        }
            break;
        case kJCHAnalyseComponentViewProfitTag:
        {
            self.backgroundColor = RGBColor(255, 248, 237, 1);
        }
            break;
        case kJCHAnalyseComponentViewInventoryTag:
        {
            self.backgroundColor = RGBColor(230, 248, 255, 1);
        }
            break;
        default:
            break;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    switch (self.tag) {
        case kJCHAnalyseComponentViewPurchaseTag:
        {
            self.backgroundColor = RGBColor(255, 253, 223, 1);
        }
            break;
        case kJCHAnalyseComponentViewShipmentTag:
        {
            self.backgroundColor = RGBColor(245, 255, 232, 1);
        }
            break;
        case kJCHAnalyseComponentViewProfitTag:
        {
            self.backgroundColor = RGBColor(255, 248, 237, 1);
        }
            break;
        case kJCHAnalyseComponentViewInventoryTag:
        {
            self.backgroundColor = RGBColor(230, 248, 255, 1);
        }
            break;
        default:
            break;
    }
}

@end
