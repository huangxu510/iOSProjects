//
//  JCHProductDetailView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductDetailViewData : NSObject

@property (nonatomic, retain) NSString *productCategory;
@property (nonatomic, retain) NSString *productUnit;
@property (nonatomic, retain) NSString *productCount;
@property (nonatomic, retain) NSString *productAmount;

@end

@interface JCHProductDetailView : UIView

- (void)setViewData:(JCHProductDetailViewData *)data;

@end
