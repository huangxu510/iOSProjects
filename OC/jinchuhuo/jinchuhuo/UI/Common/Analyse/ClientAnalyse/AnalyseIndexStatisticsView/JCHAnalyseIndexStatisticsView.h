//
//  JCHAnalyseIndexStatisticsView.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JCHAnalyseIndexStatisticsViewData : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *middleText;
@property (nonatomic, retain) NSString *bottomText;

@end

@interface JCHAnalyseIndexStatisticsView : UIView

- (void)setViewData:(JCHAnalyseIndexStatisticsViewData *)data;

@end
