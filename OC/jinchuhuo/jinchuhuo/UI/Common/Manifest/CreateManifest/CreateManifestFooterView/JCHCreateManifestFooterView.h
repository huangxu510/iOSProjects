//
//  JCHCreateManifestFooterView.h
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol JCHCreateManifestFooterViewDelegate <NSObject>
@optional
- (void)handleClickSaveOrderList;
- (void)handleEditRemark;
- (void)handleEditTotalDiscount;
@end

@interface JCHCreateManifestFooterViewData : NSObject
@property (retain, nonatomic, readwrite) NSString *totalPrice;
@property (retain, nonatomic, readwrite) NSString *remark;
@property (assign, nonatomic, readwrite) NSInteger productCount;
@end

@interface JCHCreateManifestFooterView : UIView

@property (assign, nonatomic, readwrite) id<JCHCreateManifestFooterViewDelegate> eventDelegate;

- (id)initWithFrame:(CGRect)frame;
- (void)setData:(JCHCreateManifestFooterViewData *)data;
- (void)setSaveButtonTitle:(NSString *)title;

@end
