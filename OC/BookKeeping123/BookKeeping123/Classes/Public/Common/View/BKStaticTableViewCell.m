//
//  MPStaticTableViewCell.m
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKStaticTableViewCell.h"
#import "BKWordItem.h"
#import "BKWordArrowItem.h"
#import "BKItemSection.h"

@interface BKStaticTableViewCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImageViewWidthConsraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftConstraint;

@end

@implementation BKStaticTableViewCell


- (void)setItem:(BKWordItem *)item
{
    _item = item;
    
    self.titleLabel.text = self.item.title;
    self.detailLabel.text = self.item.subTitle;
    
    self.titleLabel.font = self.item.titleFont;
    self.titleLabel.textColor = self.item.titleColor;
    
    self.detailLabel.font = self.item.subTitleFont;
    self.detailLabel.textColor = self.item.subTitleColor;
    
    if (self.item.image) {
        self.iconImageView.image = self.item.image;
        self.iconImageView.hidden = NO;
        self.titleLabelLeftConstraint.constant = 48;
    } else {
        self.iconImageView.image = nil;
        self.iconImageView.hidden = YES;
        self.titleLabelLeftConstraint.constant = 10;
    }
    
    if (self.item.hasTextField) {
        self.textField.keyboardType = _item.keyboardType;
    }
    
    
    if ([self.item isKindOfClass:[BKWordArrowItem class]]) {
        self.arrowImageViewWidthConsraint.constant = 30;
    } else {
        self.arrowImageViewWidthConsraint.constant = 0;
    }
    
    if (self.item.itemOperation || [self.item isKindOfClass:[BKWordArrowItem class]]) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string].stringByTrim;
    NSLog(@"%@", current);
    
    self.item.subTitle = current;
    
    self.detailLabel.text = self.item.subTitle;
    
    return YES;
}



@end
