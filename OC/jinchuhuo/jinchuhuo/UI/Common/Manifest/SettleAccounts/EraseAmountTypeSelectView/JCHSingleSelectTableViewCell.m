//
//  JCHSingleSelectTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSingleSelectTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHSingleSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"]] autorelease];
        self.accessoryView.hidden = NO;
        
        self.textLabel.backgroundColor = JCHColorMainBody;
        self.textLabel.font = JCHFont(14.0);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.accessoryView.hidden = !selected;
}

@end
