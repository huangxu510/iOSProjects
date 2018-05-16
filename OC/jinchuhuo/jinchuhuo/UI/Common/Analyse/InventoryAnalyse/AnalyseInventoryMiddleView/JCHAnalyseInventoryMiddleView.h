//
//  JCHAnalyseInventoryMiddleView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHAnalyseInventoryMiddleViewData : NSObject

@property (nonatomic, retain) NSString *categoryName;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *rate;

@end

@interface JCHAnalyseInventoryMiddleView : UIView

- (void)setData:(JCHAnalyseInventoryMiddleViewData *)data;

@end
