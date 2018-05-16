//
//  JCHClientDetailAnalyseHeaderView.h
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHClientDetailAnalyseHeaderComponentView : UIView

@property (nonatomic, retain) UIImageView *headImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *detailLabel;

@end



@interface JCHClientDetailAnalyseHeaderViewData : NSObject

@property (nonatomic, retain) NSString *headImageName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *dateRange;
@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) CGFloat receivableAmount;
@property (nonatomic, assign) NSInteger receivableCount;

@end

@interface JCHClientDetailAnalyseHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   isReturned:(BOOL)isReturned;

- (void)setViewData:(JCHClientDetailAnalyseHeaderViewData *)data;

@end
