//
//  JCHFiltDataSectionView.h
//  jinchuhuo
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHSearchBar.h"

//! @brief filt view 隐藏完成处理事件
typedef void(^DataSectionViewHideBlock)(void);

enum JCHPullDownViewType {
    kJCHFiltDataPullDownButtonListViewType = 0,        /*! button 列表 */
    kJCHFiltDataPullDownSKUViewType,                   /*! sku 多选 */
    kJCHFiltDataPullDownTableViewType,                 /*! table view */
};

@protocol JCHFiltDataSectionViewDelegate <NSObject>

@optional

- (void)skuSelect:(NSInteger)menuIndex UUIDArray:(NSArray *)filteredSKUValueUUIDArray;
- (void)buttonClick:(NSInteger)menuIndex buttonSelected:(NSInteger)selectedButtonIndex;
- (void)tableViewSelectRow:(NSInteger)menuIndex tableRow:(NSInteger)row;
- (void)clickSearchButton;
- (void)searchBarCancelButtonClicked:(JCHSearchBar *)searchBar;
- (void)searchBarTextChanged:(JCHSearchBar *)searchBar;
- (void)searchBarDidBeginEditing:(JCHSearchBar *)searchBar;

@end

@interface JCHFiltDataSectionView : UIView

@property (assign, nonatomic, readonly) BOOL isShow;
@property (assign, nonatomic, readwrite) id<JCHFiltDataSectionViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
      containerView:(UIView *)containerView
             titles:(NSArray<NSString *> *)titles
  pullDownViewClass:(NSArray<NSNumber *> *)typeList;

- (void)setData:(NSArray<NSArray *> *)dataArray;

- (void)hide:(DataSectionViewHideBlock)hideBlock;

- (void)clearOption:(NSInteger)menuIndex;

- (void)selectCell:(NSInteger)menuIndex cellIndex:(NSInteger)cellIndex;

- (void)selectButton:(NSInteger)menuIndex buttonIndex:(NSInteger)buttonIndex;

- (NSString *)getSelectedButtonTitle:(NSUInteger)menuIndex;

- (void)setSearchBarText:(NSString *)text;

- (void)setSelectedButtonStatus:(BOOL)selected;

- (void)showSearchBar:(BOOL)showFlag;

- (void)clickMaskView;

@end
