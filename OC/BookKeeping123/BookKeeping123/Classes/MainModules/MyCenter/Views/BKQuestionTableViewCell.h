//
//  BKQuestionTableViewCell.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/19.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKQuestionTableViewCellModel : NSObject

@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *answer;

@end

@interface BKQuestionTableViewCell : UITableViewCell

@property (nonatomic, strong) BKQuestionTableViewCellModel *data;
@property (nonatomic, assign) CGFloat height;

@end
