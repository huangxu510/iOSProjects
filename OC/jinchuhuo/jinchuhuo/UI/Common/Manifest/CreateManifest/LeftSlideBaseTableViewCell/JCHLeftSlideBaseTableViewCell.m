//
//  JCHLeftSlideBaseTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHLeftSlideBaseTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHLeftSlideBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.showMenuButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(showMenuButtonClick:)
                                              title:nil
                                         titleColor:nil
                                    backgroundColor:nil];
        [self.showMenuButton setImage:[UIImage imageNamed:@"manifest_more_normal"] forState:UIControlStateNormal];
        [self.showMenuButton setImage:[UIImage imageNamed:@"manifest_more_active"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.showMenuButton];
        
        [self.showMenuButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        
        [self.showMenuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
            make.width.mas_equalTo(26);
            make.height.mas_equalTo(21);
            make.centerY.equalTo(self.contentView).priorityLow();
        }];
    }
    return self;
}

- (void)dealloc
{
    self.showMenuButton = nil;
    
    [super dealloc];
}

- (void)showMenuButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self showRightUtilityButtonsAnimated:YES];
    } else {
        [self hideUtilityButtonsAnimated:YES];
    }
}


@end
