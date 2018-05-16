//
//  JCHBindResultStatusAlertView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBindResultStatusAlertView.h"
#import "CommonHeader.h"
#import <TTTAttributedLabel.h>
#import <Masonry.h>

@implementation JCHBindResultStatusAlertViewData

- (void)dealloc
{
    [self.imageName release];
    [self.titleText release];
    [self.detailText release];
    [self.buttonTitle release];
    
    [super dealloc];
}


@end

@interface JCHBindResultStatusAlertView () <TTTAttributedLabelDelegate>
{
    UIImageView *_statusImageView;
    UILabel *_statusTitleLabel;
    TTTAttributedLabel *_detailLabel;
    UIButton *_bottomButton;
}
@end

@implementation JCHBindResultStatusAlertView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        _statusImageView = [[[UIImageView alloc] init] autorelease];
        [self addSubview:_statusImageView];
        
        CGFloat imageViewLeftOffset =  [JCHSizeUtility calculateWidthWithSourceWidth:63.0f];
        CGFloat imageViewTopOffset =  [JCHSizeUtility calculateWidthWithSourceWidth:43.0f];
        CGFloat imageViewWidth =  [JCHSizeUtility calculateWidthWithSourceWidth:60.0f];
        
        [_statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(imageViewTopOffset);
            make.height.and.width.mas_equalTo(imageViewWidth);
            make.left.equalTo(self).with.offset(imageViewLeftOffset);
        }];
        
        _statusTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"绑定成功!"
                                                 font:[UIFont jchSystemFontOfSize:21.0f]
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
        [self addSubview:_statusTitleLabel];
        
        CGFloat titleLabelLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:16.0f];
        
        [_statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_statusImageView.mas_right).with.offset(titleLabelLeftOffset);
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
            make.centerY.equalTo(_statusImageView);
            make.height.equalTo(_statusImageView);
        }];
        
        _bottomButton = [JCHUIFactory createButton:CGRectZero
                                            target:self
                                            action:@selector(bottomButtonAction)
                                             title:@"好的"
                                        titleColor:JCHColorMainBody
                                   backgroundColor:[UIColor whiteColor]];
        [self addSubview:_bottomButton];
        
        CGFloat bottomButtonHeight = [JCHSizeUtility calculateWidthWithSourceWidth:48.0f];
        
        [_bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(self);
            make.height.mas_equalTo(bottomButtonHeight);
        }];
        
        [_bottomButton addSeparateLineWithMasonryTop:YES bottom:NO];
        
        
        _detailLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
        _detailLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _detailLabel.font = [UIFont jchSystemFontOfSize:15.0f];
        _detailLabel.textColor = JCHColorMainBody;
        _detailLabel.numberOfLines = 0;
        _detailLabel.delegate = self;
        _detailLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        //_detailLabel.linkAttributes =[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString *)kCTUnderlineStyleAttributeName];
        //_detailLabel.linkAttributes = @{kCTForegroundColorAttributeName : JCHColorBlueButton,
                                        //NSUnderlineStyleAttributeName : (NSNumber *)(long: NSUnderlineStyle.StyleSingle.rawValue)};

        
        _detailLabel.text = @"您可以在以后的交易中使用微信扫码或是微信条码收款了。也可以在账户里面查看微信账户的交易流水。";
       
        [self addSubview:_detailLabel];
        
        CGFloat detailLabelTopOffset = [JCHSizeUtility calculateWidthWithSourceWidth:24.0f];
        
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_statusTitleLabel.mas_bottom).with.offset(detailLabelTopOffset);
            make.bottom.equalTo(_bottomButton.mas_top).with.offset(-detailLabelTopOffset);
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        }];
    }
    return self;
}


- (void)setViewData:(JCHBindResultStatusAlertViewData *)data
{
    _statusImageView.image = [UIImage imageNamed:data.imageName];
    _statusTitleLabel.text = data.titleText;
    _detailLabel.text = data.detailText;
    [_bottomButton setTitle:data.buttonTitle forState:UIControlStateNormal];
}

                         
- (void)bottomButtonAction
{
    if ([self.delegate respondsToSelector:@selector(handleButtonClick:)]) {
        [self.delegate handleButtonClick:self];
    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

@end
