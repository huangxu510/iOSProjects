//
//  JCHValueAddedServiceInfoView.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAddedServiceInfoViewData : NSObject

@property (nonatomic, retain) NSString *iconName;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, assign) BOOL markLabelHidden;

@end

@interface JCHAddedServiceInfoView : UIView

- (void)setViewData:(JCHAddedServiceInfoViewData *)data;

@end
