//
//  JCHValueAddedServiceView.h
//  jinchuhuo
//
//  Created by huangxu on 16/5/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAddedServicePackageViewData : NSObject

@property (nonatomic, retain) NSString *duration;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) BOOL hotMarkImageHidden;

@end

@interface JCHAddedServicePackageView : UIView

- (void)setViewData:(JCHAddedServicePackageViewData *)data;

@end
