//
//  JCHUserInfoView.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(void);

@interface JCHUserInfoViewData : NSObject

@property (nonatomic, retain) NSString *headImageName;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *maimaiNumber;

@end

@interface JCHUserInfoView : UIImageView

@property (nonatomic, copy) ClickBlock openAddedService;

- (void)setViewData:(JCHUserInfoViewData *)data;

@end
