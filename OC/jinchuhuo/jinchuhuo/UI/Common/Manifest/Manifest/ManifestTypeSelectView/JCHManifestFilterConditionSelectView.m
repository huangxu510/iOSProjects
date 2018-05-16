//
//  JCHManifestTypeSelectView.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHManifestFilterConditionSelectView.h"
#import "CommonHeader.h"
#import "UIImage+JCHImage.h"

@interface JCHManifestFilterConditionSelectView ()


@property (nonatomic, retain) UIButton *selectedButton;

@end

@implementation JCHManifestFilterConditionSelectView


- (void)dealloc
{
    [self.data release];
    [self.selectedButton release];
    [super dealloc];
}


- (void)setData:(NSArray *)data
{
    _data = [data retain];
    self.viewHeight = 0;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIFont *titleFont = [UIFont jchSystemFontOfSize:12.0f];
    CGRect previousFrame = CGRectZero;
    CGFloat buttonHeight = 24.0f;
    CGFloat widthOffset = 10;
    CGFloat heightOffset = 10;
    self.viewHeight = 2 * heightOffset + buttonHeight;
    for (NSInteger i = 0; i < data.count; i ++) {
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(selectManifest:)
                                                title:data[i]
                                           titleColor:JCHColorMainBody
                                      backgroundColor:JCHColorGlobalBackground];
        button.tag = i - 1;
        button.layer.cornerRadius = buttonHeight / 2;
        button.clipsToBounds = YES;
        button.titleLabel.font = titleFont;
        [button setBackgroundImage:[UIImage imageWithColor:JCHColorHeaderBackground] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self addSubview:button];
        
        if (i == 0) {
            [self selectManifest:button];
        }
        
        NSDictionary *attr = @{NSFontAttributeName : titleFont};
        CGSize size = CGSizeMake(1000, buttonHeight);
        CGRect resultFrame = [data[i] boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        CGFloat currentButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:resultFrame.size.width + 3 * widthOffset];
        CGFloat currentButtonHeight = buttonHeight;
        if (i == 0) {
            button.frame = CGRectMake(0, heightOffset, currentButtonWidth, currentButtonHeight);
        } else {
            
            if ((previousFrame.origin.x + previousFrame.size.width + currentButtonWidth + 2 * widthOffset) > self.frame.size.width) {
                previousFrame.origin.x = 0;
                previousFrame.origin.y += heightOffset + currentButtonHeight;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
                self.viewHeight += heightOffset + currentButtonHeight;
            } else {
                previousFrame.origin.x += widthOffset + previousFrame.size.width;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
            }
        }
        
        previousFrame = button.frame;
    }
}

- (void)selectManifest:(UIButton *)sender
{
    _selectedTag = sender.tag;
    
  
    self.selectedButton.selected = NO;
    sender.selected = YES;
    
    self.selectedButton = sender;
}

- (void)setSelectedTag:(NSInteger)selectedTag
{
    _selectedTag = selectedTag;
    UIButton *button = self.subviews[selectedTag + 1];
    [self selectManifest:button];
}

@end
