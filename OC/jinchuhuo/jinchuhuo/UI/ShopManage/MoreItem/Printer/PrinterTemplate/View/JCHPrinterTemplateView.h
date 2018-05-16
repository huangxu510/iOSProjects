//
//  JCHPrinterTemplateView.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHPrinterTemplateViewData : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *imageName;

@end

@interface JCHPrinterTemplateView : UIView

@property (assign, nonatomic) BOOL selected;
@property (copy, nonatomic) dispatch_block_t selectBlock;

- (void)setViewData:(JCHPrinterTemplateViewData *)data;

@end
