//
//  JCHTextView.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTextView.h"
#import "JCHInputAccessoryView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHTextView ()
@property (nonatomic, retain) UILabel *placeholderLabel;
@end

@implementation JCHTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIEdgeInsets edgeInsets = self.textContainerInset;
        edgeInsets.left = kStandardLeftMargin;
        edgeInsets.right = kStandardLeftMargin;
        self.textContainerInset = edgeInsets;

        UILabel *placeholderLabel = [[[UILabel alloc] init] autorelease];
        
        placeholderLabel.textColor = [UIColor lightGrayColor];
        placeholderLabel.hidden = YES;
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.font = self.font;
        [self insertSubview:placeholderLabel atIndex:0];
        self.placeholderLabel = placeholderLabel;

        [JCHNotificationCenter addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
        
        const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, kJCHInputAccessoryViewHeight);
        self.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [self.placeholderLabel release];
    [self.placeholder release];
    [self.placeholderColor release];
    [JCHNotificationCenter removeObserver:self];
    [super dealloc];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.placeholderLabel.text = placeholder;
    if (placeholder.length) { // 需要显示
        self.placeholderLabel.hidden = NO;
        
        UIEdgeInsets edgeInsets = self.textContainerInset;
        // 计算frame
        CGFloat placeholderX = edgeInsets.left + 4;
        CGFloat placeholderY = edgeInsets.top;
        CGFloat maxW = self.frame.size.width - 2 * placeholderX;
        CGFloat maxH = self.frame.size.height - 2 * placeholderY;
        
        CGRect fitRect = [placeholder boundingRectWithSize:CGSizeMake(maxW, maxH)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSForegroundColorAttributeName : self.placeholderLabel.font}
                                                   context:nil];
        
        self.placeholderLabel.frame = CGRectMake(placeholderX, placeholderY, maxW, fitRect.size.height + 4);
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeholderLabel.font = font;
    self.placeholder = self.placeholder;
}

- (void)textDidChange
{
    self.placeholderLabel.hidden = (self.text.length != 0);
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    self.placeholderLabel.hidden = (self.text.length != 0);
}

- (void)setIsAutoHeight:(BOOL)isAutoHeight
{
    _isAutoHeight = isAutoHeight;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets edgeInsets = self.textContainerInset;
    CGRect textFrame = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width - 10 - 2 * edgeInsets.left,MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.font,NSFontAttributeName, nil] context:nil];
    
    
    if (textFrame.size.height + self.textContainerInset.top + self.textContainerInset.bottom > self.minHeight && self.isAutoHeight) {
        
        //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, textFrame.size.height);
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(textFrame.size.height + self.textContainerInset.top + self.textContainerInset.bottom);
        }];
    }

}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (!self.isDragging) {
        contentOffset = CGPointZero;
    }
    [super setContentOffset:contentOffset];
}


@end
