//
//  JCHAddProductSKUListTableVIew.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHAddProductSKUListTableViewCell.h"
#import "JCHAddProductMainViewController.h"

enum
{
    kSKUListRowHeight = 60,
    kSKUListSectionHeight = 80,
};

@class JCHAddProductSKUListView;
@protocol JCHAddProductSKUListViewDelegate <NSObject>

- (void)handleHideView:(JCHAddProductSKUListView *)view;

- (void)skuListView:(JCHAddProductSKUListView *)view labelTaped:(UILabel *)editLabel;

@end

@interface JCHAddProductSKUListView : UIView

@property (nonatomic, assign) id <JCHAddProductSKUListViewDelegate> delegate;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, assign) JCHAddProductSKUListTableViewCellLableTag currentEditLabelTag;
@property (nonatomic, assign) JCHAddProductSKUListTableViewCellLableTag lastEditLabelTag;


//保存当前已选择的cell对应的数据
@property (nonatomic, retain) NSMutableArray *selectedData;

//单行操作时的数据
@property (nonatomic, retain) ManifestTransactionDetail *singleEditingData;

//目前是不是单行操作
@property (nonatomic, assign) BOOL singleEditing;

- (instancetype)initWithFrame:(CGRect)frame
                  productName:(NSString *)productName
                 manifestType:(enum JCHOrderType)manifestType
                   dataSource:(NSArray *)dataSource;
- (void)reloadData;

@end
