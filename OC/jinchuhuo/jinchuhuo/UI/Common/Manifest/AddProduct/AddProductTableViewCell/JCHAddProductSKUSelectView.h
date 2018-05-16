//
//  JCHAddProductSKUSelectView.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JCHAddProductSKUSelectView;
@protocol JCHAddProductSKUSelectViewDelegate <NSObject>

- (void)viewEndEditing:(JCHAddProductSKUSelectView *)view;

@end

@interface JCHAddProductSKUSelectView : UIView

@property (nonatomic, assign) id<JCHAddProductSKUSelectViewDelegate>delegate;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, retain, readwrite) NSArray *selectedData;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) BOOL autoSelectIfOneSKUValue;

- (void)setButtonData:(NSDictionary *)data;
- (void)unselectData;
- (void)setBrokenLineViewHidden:(BOOL)hidden;
- (void)selectButtons:(NSArray *)skuValueUUIDs;
- (void)deselectAllButtons;

@end
