//
//  JCHAddSpecificationFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCHAddSKUValueFooterView;
@protocol JCHAddSKUValueFooterViewDelegate <NSObject>

- (void)addItem;

@end

@interface JCHAddSKUValueFooterView : UIView

@property (nonatomic, assign) id <JCHAddSKUValueFooterViewDelegate> delegate;
- (void)setTitleName:(NSString *)name;
@end
