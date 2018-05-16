//
//  ManifestTableFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/2.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManifestTableFooterViewData : NSObject
@property (retain, nonatomic, readwrite) NSString *totalPrice;
@end


@interface ManifestTableFooterView : UIView

- (void)setViewData:(ManifestTableFooterViewData *)viewData;

@end
