//
//  JCHProductTitleComponentView.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductTitleComponentViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productLogoName;

@end

@interface JCHProductTitleComponentView : UIView

- (void)setViewData:(JCHProductTitleComponentViewData *)viewData;

@end
