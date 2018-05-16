//
//  JCHProductDetailFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/17.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductDetailFooterViewData : NSObject

@property (nonatomic, retain) NSString *traderCode;
@property (nonatomic, retain) NSString *barCode;
@property (nonatomic, retain) NSString *remark;

@end

@interface JCHProductDetailFooterView : UIView

@property (nonatomic, assign) CGFloat viewHeight;
- (void)setViewData:(JCHProductDetailFooterViewData *)data;

@end
