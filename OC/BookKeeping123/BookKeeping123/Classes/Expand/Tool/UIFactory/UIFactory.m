//
//  MPUIFactory.m
//  MobileProject2
//
//  Created by huangxu on 2018/4/13.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "UIFactory.h"

@implementation UIFactory

#pragma mark - make View
+ (UIView *)createViewWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    return [self createViewWithBorderWidth:borderWidth cornerRadius:0 borderColor:borderColor];
}

+ (UIView *)createViewWithBorderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius borderColor:(UIColor *)borderColor
{
    UIView *view = [[UIView alloc] init];
    
    if (borderColor) {
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor.CGColor;
        
        if (cornerRadius > 0)
        {
            view.layer.cornerRadius = cornerRadius;
            view.layer.masksToBounds = YES;
        }
    }
    
    return view;
}

#pragma mark - make Button
+ (UIButton *)createButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize
                             target:(id)target action:(SEL)aSelect
{
    return [self createButtonWithTitle:title titleColor:titleColor fontSize:fontSize normalImage:nil hightLigthImage:nil target:target action:aSelect];
}

+ (UIButton *)createButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize
                        normalImage:(UIImage *)normalImage hightLigthImage:(UIImage *)hightLightImage
                             target:(id)target action:(SEL)aSelect
{
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        [button setTitleColor:[titleColor colorWithAlphaComponent:0.3] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    
    if (normalImage) {
        [button setImage:normalImage forState:UIControlStateNormal];
    }
    
    if (hightLightImage) {
        [button setImage:hightLightImage forState:UIControlStateHighlighted];
    }
    
    if (target) {
        [button addTarget:target action:aSelect forControlEvents:UIControlEventTouchUpInside];
    }
    
    return button;
}

#pragma mark - make Label
+ (UILabel *)createLabelWithColor:(UIColor *)textColor fontSize:(CGFloat)fontSize
{
    return [self createLabelWithColor:textColor fontSize:fontSize alignment:NSTextAlignmentLeft];
}

+ (UILabel *)createLabelWithColor:(UIColor *)textColor fontSize:(CGFloat)fontSize alignment:(NSTextAlignment)alignment
{
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [label setTextColor:textColor];
    [label setTextAlignment:alignment];
    
    return label;
}

#pragma mark - make textField
+ (UITextField *)createTextFieldWithTextColor:(UIColor *)textColor fontSize:(CGFloat)fontSize placeHodler:(NSString *)placeHodler
{
    UITextField *textField = [[UITextField alloc] init];
    [textField setFont:[UIFont systemFontOfSize:fontSize]];
    [textField setTextColor:textColor];
    [textField setPlaceholder:placeHodler];
    
    return textField;
}



#pragma mark - make textView
+ (UITextView *)createTextViewWithTextColor:(UIColor *)textColor fontSize:(CGFloat)fontSize
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setFont:[UIFont systemFontOfSize:fontSize]];
    [textView setTextColor:textColor];
    
    return textView;
}

#pragma mark - make imageView
+ (UIImageView *)createImageViewWithImage:(UIImage *)image
{
    return [self createImageViewWithImage:image hightLightedImage:nil];
}

+ (UIImageView *)createImageViewWithImage:(UIImage *)n_image hightLightedImage:(UIImage *)h_image
{
    UIImageView *imageView  = [[UIImageView alloc] initWithImage:n_image];
    if (h_image) imageView.highlightedImage = h_image;
    
    return imageView;
}

#pragma mark - attributionString
+ (NSAttributedString *)createAttributedWithText:(NSString *)text alignment:(NSTextAlignment)alignment lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = alignment;
    
    if (lineSpacing > 0)
    {
        paragraphStyle.lineSpacing = lineSpacing;
    }
    
    if (paragraphSpacing > 0)
    {
        paragraphStyle.paragraphSpacing = paragraphSpacing;
    }
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName : paragraphStyle}];
    
    return attributedString;
}

#pragma mark - makeNavigationItem

+ (UIBarButtonItem *)createBarButtonItemWithImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action {
    return [UIFactory createBarButtonItemWithImageName:imageName title:title titleColor:titleColor fontSize:fontSize isLeft:NO space:0 target:target action:action];
}


+ (UIBarButtonItem *)createBarButtonItemWithImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize isLeft:(BOOL)isLeft space:(CGFloat)space target:(id)target action:(SEL)action {
    
    NSDictionary *dic = @{NSFontAttributeName : @(fontSize)};
    
    CGSize textSize = [title boundingRectWithSize:[[UIScreen mainScreen] bounds].size
                                          options:(NSStringDrawingUsesLineFragmentOrigin |
                                                   NSStringDrawingTruncatesLastVisibleLine)
                                       attributes:dic context:nil].size;
    
    UIButton *button = [UIFactory createButtonWithTitle:title titleColor:titleColor fontSize:fontSize normalImage:[UIImage imageNamed:imageName] hightLigthImage:nil target:target action:action];
    button.frame = CGRectMake(0, 0, textSize.width + space + button.imageView.image.size.width < 20 ? 20 : textSize.width + space + button.imageView.image.size.width, 40);
    
    if (isLeft) {
        
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0f, 0, space/2.0f)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0f, 0, -space/2.0f)];
        
    } else {
        
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, space/2.0f + textSize.width, 0, -space/2.0f - textSize.width)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -space/2.0f - button.imageView.image.size.width, 0, space/2.0f + button.imageView.image.size.width)];
    }
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return buttonItem;
}

@end
