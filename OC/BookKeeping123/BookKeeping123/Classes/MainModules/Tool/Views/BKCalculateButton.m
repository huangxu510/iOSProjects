//
//  BKCalculateButton.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/19.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKCalculateButton.h"

@interface BKCalculateButton ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation BKCalculateButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.button setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    BKCalculateButton *button = [[NSBundle mainBundle] loadNibNamed:@"BKCalculateButton" owner:nil options:nil].firstObject;
    button.titleLabel.text = title;
    button.imageView.image = IMG(imageName);
    return button;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events {
    [self.button addTarget:target action:action forControlEvents:events];
}

- (void)setTag:(NSInteger)tag {
    self.button.tag = tag;
}

@end
