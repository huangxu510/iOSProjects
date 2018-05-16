//
//  JCHProductDetailComponentView.h
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductDetailComponentViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *title;
@property (retain, nonatomic, readwrite) NSString *value;

@end

@interface JCHProductDetailComponentView : UIView

- (void)setViewData:(JCHProductDetailComponentViewData *)viewData;

@end
