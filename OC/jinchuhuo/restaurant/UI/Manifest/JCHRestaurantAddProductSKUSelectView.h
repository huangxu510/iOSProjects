//
//  JCHRestaurantAddProductSKUSelectView.h
//  jinchuhuo
//
//  Created by apple on 2017/2/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCHRestaurantAddProductSKUSelectView;
@protocol JCHRestaurantAddProductSKUSelectViewDelegate <NSObject>

- (void)viewEndEditing:(JCHRestaurantAddProductSKUSelectView *)view;
- (void)clickSKUItemButton:(id)sender;

@end

@interface JCHRestaurantAddProductSKUSelectView : UIView

@property (nonatomic, assign) id<JCHRestaurantAddProductSKUSelectViewDelegate>delegate;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, retain, readwrite) NSArray *selectedSKUData;
@property (nonatomic, retain, readwrite) NSString *selectedPropertyData;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) BOOL autoSelectIfOneSKUValue;

- (void)setButtonSKUData:(NSDictionary *)data;
- (void)setButtonPropertyData:(NSDictionary *)data;
- (void)unselectData;
- (void)setBrokenLineViewHidden:(BOOL)hidden;
- (void)selectButtons:(NSArray *)skuValueUUIDs;
- (void)deselectAllButtons;

@end
