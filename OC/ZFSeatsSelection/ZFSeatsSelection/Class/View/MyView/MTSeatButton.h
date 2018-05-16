//
//  MTSeatButton.h
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTSeatModel : NSObject

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;

//状态 0:可选 1:当前用户已预订且审批已通过 2:当前用户已预订且正在审批中 3:其它用户已预订且审批已通过 4:其它用户已预订且正在审批中
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, copy) NSString *roomNumber;

@end

@interface MTSeatButton : UIButton

@property (nonatomic, retain) MTSeatModel *seatModel;

@end
