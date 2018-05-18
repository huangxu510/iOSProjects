//
//  BKCalculateResultTableViewCell.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/18.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKCalculateResultTableViewCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, strong) UIColor *detailColor;

@end

@interface BKCalculateResultTableViewCell : UITableViewCell

@property (nonatomic, strong) BKCalculateResultTableViewCellModel *data;

@end



