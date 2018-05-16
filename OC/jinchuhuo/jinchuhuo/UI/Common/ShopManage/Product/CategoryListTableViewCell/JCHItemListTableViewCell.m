//
//  JCHCategoryListTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHItemListTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHItemListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        self.selectImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"]] autorelease];
        self.selectImageView.hidden = YES;
        [self.contentView addSubview:self.selectImageView];
        
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
            make.width.height.mas_equalTo(23);
            make.centerY.equalTo(self.contentView);
        }];
        
        _goTopButton = [JCHUIFactory createButton:CGRectZero
                                             target:self
                                             action:@selector(handleGoTopAction)
                                              title:nil
                                         titleColor:nil
                                    backgroundColor:nil];
        [_goTopButton setImage:[UIImage imageNamed:@"itemSort_top"] forState:UIControlStateNormal];
        [self addSubview:_goTopButton];
  
        [_goTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
            make.top.bottom.equalTo(self.contentView);
            make.width.mas_equalTo(kStandardItemHeight);
        }];
        
    }
    return self;
}

- (void)dealloc
{
    self.selectImageView = nil;
    self.goTopBlock = nil;
    [super dealloc];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (self.autoHiddenArrowImageViewWhileEditing) {
        self.arrowImageView.hidden = editing;
    }
    
    if (self.frame.origin.x == 0) {
        _goTopButton.hidden = !editing;
    }
}

- (void)handleGoTopAction
{
    if (self.goTopBlock) {
        self.goTopBlock(self);
    }
}


@end
