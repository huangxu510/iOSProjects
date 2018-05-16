//
//  JCHCategoryListTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/8/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHCategoryListTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHCategoryListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = JCHColorGlobalBackground;
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:JCHFont(12.0)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentCenter];
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin / 2);
            make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin / 2);
            make.top.bottom.equalTo(self.contentView);
        }];
        
        [self.contentView addSeparateLineWithMasonryTop:NO bottom:YES];
        
        
#if !MMR_RESTAURANT_VERSION
        self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_leftmenu_selected"]] autorelease];
#else
        self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"restaurant_bg_leftmenu_selected"]] autorelease];
#endif
    }
    return self;
}

- (void)dealloc
{
    self.titleLabel = nil;
    [super dealloc];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.titleLabel.textColor = JCHColorHeaderBackground;
    } else {
        self.titleLabel.textColor = JCHColorMainBody;
    }
}

@end
