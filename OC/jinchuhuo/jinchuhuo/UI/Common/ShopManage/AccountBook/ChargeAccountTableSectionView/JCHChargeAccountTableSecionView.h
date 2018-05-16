//
//  JCHChargeAccountTableSecionView.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHChargeAccountTableSecionViewData : NSObject

@property (nonatomic, retain) NSString *headImageName;
@property (nonatomic, retain) NSString *memberName;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *manifestCountInfo;

@end

@interface JCHChargeAccountTableSecionView : UIView

- (void)setViewData:(JCHChargeAccountTableSecionViewData *)data;

@end
