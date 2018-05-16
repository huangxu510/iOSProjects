//
//  JCHCreateManifestHeaderView.m
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHCreateManifestHeaderView.h"
#import "JCHInputAccessoryView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHUIDebugger.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "Masonry.h"
#import "CommonHeader.h"

@implementation JCHCreateManifestHeaderViewData

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.orderID release];
    [self.orderDate release];
    
    [super dealloc];
    return;
}

@end


@interface JCHCreateManifestHeaderView ()
{
    UILabel *orderIDLabel;
    UILabel *orderDateLabel;
    UIButton *orderDateResponseButton;

    UIView *dataBackgroundView;
}
@end


@implementation JCHCreateManifestHeaderView

- (id)initWithFrame:(CGRect)frame isCommonManifest:(BOOL)isCommonManifest
{
    self = [super initWithFrame:frame];
    if (self) {
        if (isCommonManifest) {
            [self createDefaultUI];
        } else {
            [self createOtherUI];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createDefaultUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    const CGFloat labelWidth = self.frame.size.width / 2;
    const CGFloat titleLabelHeight = self.frame.size.height * 2 / 5;
    const CGFloat valueLabelHeight = self.frame.size.height * 3 / 5;
    UIFont *titleFont = [UIFont systemFontOfSize:14.0f];
    UIFont *valueFont = [UIFont systemFontOfSize:13.0f];
    UIColor *titleColor = UIColorFromRGB(0xb0b0b0);
    UIColor *valueColor = UIColorFromRGB(0x5f5f5f);
    
    const CGFloat widthOffset = [JCHSizeUtility calculateWidthWithSourceWidth:1.0f];
    
    {
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"单号"
                                                font:titleFont
                                           textColor:titleColor
                                              aligin:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(labelWidth);
            make.height.mas_equalTo(titleLabelHeight);
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top).with.offset(3);
        }];
        
        orderIDLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"Z2345678998765432"
                                         font:valueFont
                                    textColor:valueColor
                                       aligin:NSTextAlignmentCenter];
        orderIDLabel.numberOfLines = 2;
        orderIDLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:orderIDLabel];
        
        [orderIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(labelWidth - 16 * widthOffset);
            make.height.mas_equalTo(valueLabelHeight);
            make.left.equalTo(self.mas_left).with.offset(widthOffset * 8);
            make.top.equalTo(titleLabel.mas_bottom).with.offset(-2);
        }];
        
    }
    
    const CGFloat arrowImageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:14.0f];
    
    {
        dataBackgroundView = [[[UIView alloc] init] autorelease];
        
        [self addSubview:dataBackgroundView];
        
        [dataBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(orderIDLabel.mas_right).with.offset(8 * widthOffset);
            make.width.mas_equalTo(labelWidth);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"时间"
                                                font:titleFont
                                           textColor:titleColor
                                              aligin:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(labelWidth);
            make.height.mas_equalTo(titleLabelHeight);
            make.left.equalTo(orderIDLabel.mas_right).with.offset(8 * widthOffset);
            make.top.equalTo(self.mas_top).with.offset(3);
        }];

        
        orderDateLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:valueFont
                                          textColor:valueColor
                                             aligin:NSTextAlignmentCenter];
        orderDateLabel.numberOfLines = 2;
     
        [self addSubview:orderDateLabel];
        
        [orderDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(labelWidth);
            make.height.mas_equalTo(valueLabelHeight);
            make.left.equalTo(titleLabel.mas_left);
            make.top.equalTo(titleLabel.mas_bottom).with.offset(-2);
        }];
        
        UIImageView *arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createManifest_DatePickBtn"]] autorelease];
        [self addSubview:arrowImageView];
        
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(orderDateLabel.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(arrowImageViewHeight);
            make.height.mas_equalTo(arrowImageViewHeight);
        }];
        
        orderDateResponseButton = [JCHUIFactory createButton:CGRectZero
                                                           target:self
                                                      action:@selector(handleChooseDate:)
                                                            title:nil titleColor:nil
                                                  backgroundColor:[UIColor clearColor]];
        
        [orderDateResponseButton addTarget:self
                                        action:@selector(handleDataButtonTouchDown:)
                              forControlEvents:UIControlEventTouchDown];
        
        [orderDateResponseButton addTarget:self
                                    action:@selector(handleDataButtonDragExit:)
                          forControlEvents:UIControlEventTouchDragExit];
        
        [orderDateResponseButton addTarget:self
                                        action:@selector(handleDataButtonTouchUp:)
                              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:orderDateResponseButton];
        
        [orderDateResponseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(dataBackgroundView);
        }];
    }
    
    UIView *middleLine = [[[UIView alloc] init] autorelease];
    middleLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:middleLine];
    
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.mas_equalTo(kSeparateLineWidth);
        make.centerX.equalTo(self);
    }];
}

- (void)createOtherUI
{
    UIButton *backgroundButton = [JCHUIFactory createButton:CGRectZero
                                                     target:self
                                                     action:@selector(handleChooseDate:)
                                                      title:@""
                                                 titleColor:JCHColorMainBody
                                            backgroundColor:[UIColor whiteColor]];
    [backgroundButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf8f8f6)] forState:UIControlStateHighlighted];
    [self addSubview:backgroundButton];
    
    [backgroundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UILabel *titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"盘点时间"
                                               font:JCHFont(14.0)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    [self addSubview:titleLabel];
    
    CGSize fitSize = [titleLabel sizeThatFits:CGSizeZero];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(fitSize.width + 10);
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self);
    }];
    
    orderDateLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(14.0)
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentRight];
    
    [self addSubview:orderDateLabel];
    
    [orderDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(kStandardLeftMargin);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self);
    }];
    
    UIImageView *arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createManifest_DatePickBtn"]] autorelease];
    [self addSubview:arrowImageView];
    
    const CGFloat arrowImageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:14.0f];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.width.mas_equalTo(arrowImageViewHeight);
        make.height.mas_equalTo(arrowImageViewHeight);
    }];
    
    JCHManifestMemoryStorage *manifestStorate = [JCHManifestMemoryStorage sharedInstance];
    if (manifestStorate.currentManifestType == kJCHManifestMigrate) {
        titleLabel.text = @"移库时间";
    } else if (manifestStorate.currentManifestType == kJCHManifestAssembling) {
        titleLabel.text = @"拼装时间";
        backgroundButton.enabled = NO;
        arrowImageView.hidden = YES;
    } else if (manifestStorate.currentManifestType == kJCHManifestDismounting) {
        titleLabel.text = @"拆装时间";
        backgroundButton.enabled = NO;
        arrowImageView.hidden = YES;
    }
}

- (void)setData:(JCHCreateManifestHeaderViewData *)data
{
    orderIDLabel.text = data.orderID;
    orderDateLabel.text = data.orderDate;
}

- (void)setOrderDate:(NSString *)orderDate
{
    orderDateLabel.text = orderDate;
}

- (NSString *)getOrderDate
{
    return orderDateLabel.text;
}

- (void)handleChooseDate:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handleChooseDate)]) {
        [self.delegate performSelector:@selector(handleChooseDate)];
    }
    
    return;
}

- (void)handleDataButtonTouchDown:(UIButton *)sender
{
    dataBackgroundView.backgroundColor = UIColorFromRGB(0xf8f8f6);
}

- (void)handleDataButtonTouchUp:(UIButton *)sender
{
    dataBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)handleDataButtonDragExit:(UIButton *)sender
{
    dataBackgroundView.backgroundColor = [UIColor clearColor];
}
@end

