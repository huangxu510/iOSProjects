//
//  JCHProductListFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHItemListFooterViewDelegate <NSObject>

@optional
- (void)addItem;
- (void)deleteItems;
- (void)selectAll:(UIButton *)button;

@end

@interface JCHItemListFooterView : UIView
{
    UILabel *_productCountLabel;
    UIButton *_addProductButton;
    UIButton *_selectAllButton;
    UIButton *_deleteButton;
}
@property (nonatomic, assign) id <JCHItemListFooterViewDelegate>delegate;
@property (nonatomic, retain) NSString *categoryName;
@property (nonatomic, retain) NSString *categoryUnit;
- (void)setData:(NSInteger)count;
- (void)changeUI:(BOOL)editMode;
- (void)setButtonSelected:(BOOL)selected;
- (void)hideAddButton;
@end
