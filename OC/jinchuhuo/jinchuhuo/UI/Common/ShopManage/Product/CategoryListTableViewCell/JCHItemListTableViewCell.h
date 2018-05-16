//
//  JCHCategoryListTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHMutipleSelectedTableViewCell.h"

@interface JCHItemListTableViewCell : JCHMutipleSelectedTableViewCell
{
    UIButton *_goTopButton;
}
@property (nonatomic, copy) void(^goTopBlock)(JCHItemListTableViewCell *cell);

//从添加商品页面跳转到单位、分类列表,当前选择的箭头
@property (nonatomic, retain) UIImageView *selectImageView;

//是否随着cell的editing状态自动隐藏箭头
@property (nonatomic, assign) BOOL autoHiddenArrowImageViewWhileEditing;

@end
