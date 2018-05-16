//
//  JCHFiltDataSectionView.m
//  jinchuhuo
//
//  Created by apple on 2016/12/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHFiltDataSectionView.h"
#import "JCHInventoryPullDownBaseView.h"
#import "JCHInventoryPullDownTableView.h"
#import "JCHInventoryPullDownCategoryView.h"
#import "JCHInventoryPullDownSKUView.h"
#import "JCHInventoryPullDownContainerView.h"
#import "JCHSearchBar.h"
#import "CommonHeader.h"

@interface JCHFiltDataSectionView ()<JCHSearchBarDelegate,
                                    JCHInventoryPullDownBaseViewDelegate,
                                    JCHInventoryPullDownContainerViewDelegate,
                                    UIAlertViewDelegate>
{
    UIView *superContainerView;
    UIView *_buttonsContentView;
    UIButton *_searchButton;
    UIView *_bottomLineView;
    JCHInventoryPullDownContainerView *pullDownContainerView;
}

// 顶部section view
@property (nonatomic, retain) NSMutableArray *arrowImageViews;
@property (nonatomic, retain) UIButton *selectedButton;
@property (nonatomic, retain) JCHSearchBar *searchBar;
@property (nonatomic, assign) BOOL selectedButtonChanged;


// 点击显示的pulldown view
@property (retain, nonatomic, readwrite) NSArray<NSString *> *buttonTitlesArray;
@property (retain, nonatomic, readwrite) NSArray<NSNumber *> *pullDownViewTypeArray;
@property (retain, nonatomic, readwrite) NSArray<JCHInventoryPullDownBaseView *> *pullDownViewArray;


@end


@implementation JCHFiltDataSectionView

- (id)initWithFrame:(CGRect)frame
      containerView:(UIView *)superView
             titles:(NSArray<NSString *> *)titles
  pullDownViewClass:(NSArray<NSNumber *> *)typeList
{
    self = [super initWithFrame:frame];
    if (self) {
        superContainerView = superView;
        self.buttonTitlesArray = titles;
        self.pullDownViewTypeArray = typeList;
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    self.pullDownViewArray = nil;
    self.buttonTitlesArray = nil;
    self.pullDownViewTypeArray = nil;
    
    [super dealloc];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (JCHInventoryPullDownBaseView *pullDownView in self.pullDownViewArray) {
        [pullDownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(pullDownContainerView);
            make.left.equalTo(pullDownContainerView);
            make.right.equalTo(pullDownContainerView);
            make.height.mas_equalTo(kScreenHeight);
        }];
    }
}

- (void)createUI
{
    // 创建button
    [self createSectionViewButtons];
 
    // 创建pulldown container view
    [self createPullDownContainerView];
    
    // 创建button点击后显示的pulldown view
    [self createPullDownView];
}

- (void)createPullDownContainerView
{
    pullDownContainerView = [[[JCHInventoryPullDownContainerView alloc] initWithFrame:CGRectZero] autorelease];
    pullDownContainerView.delegate = self;
    pullDownContainerView.backgroundColor = [UIColor redColor];
    [superContainerView addSubview:pullDownContainerView];
    
    CGFloat tableHeaderViewHeight = 0;
    CGFloat tableSectionViewHeight = 0;
    if ([superContainerView isKindOfClass:[UITableView class]]) {
        UITableView *theTableView = (UITableView *)superContainerView;
        tableHeaderViewHeight = theTableView.tableHeaderView.frame.size.height;
        tableSectionViewHeight = [theTableView.delegate tableView:theTableView heightForHeaderInSection:0];
    }
    
    [pullDownContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superContainerView.mas_top).with.offset(tableHeaderViewHeight + tableSectionViewHeight);
        make.left.equalTo(superContainerView.mas_left);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(0);
    }];
}

- (void)createPullDownView
{
    NSMutableArray<JCHInventoryPullDownBaseView *> *pullDownViewArray = [[[NSMutableArray alloc] init] autorelease];
    for (NSInteger i = 0; i < self.pullDownViewTypeArray.count; ++i) {
        NSNumber *viewType = self.pullDownViewTypeArray[i];
        JCHInventoryPullDownBaseView *pullDownView = nil;
        switch (viewType.integerValue) {
            case kJCHFiltDataPullDownButtonListViewType:
            {
                pullDownView = [[[JCHInventoryPullDownCategoryView alloc] initWithFrame:CGRectZero] autorelease];
            }
                break;
                
            case kJCHFiltDataPullDownSKUViewType:
            {
                pullDownView = [[[JCHInventoryPullDownSKUView alloc] initWithFrame:CGRectZero] autorelease];
            }
                break;
                
            case kJCHFiltDataPullDownTableViewType:
            {
                pullDownView = [[[JCHInventoryPullDownTableView alloc] initWithFrame:CGRectZero] autorelease];
            }
                break;
                
            default:
            {
                NSLog(@"\ninvalid view type: %d\n", viewType.intValue);
            }
                break;
        }
        
        if (nil != pullDownView) {
            pullDownView.delegate = self;
            pullDownView.tag = i;
            [pullDownViewArray addObject:pullDownView];
            [pullDownContainerView addSubview:pullDownView];
        }
    }
    
    self.pullDownViewArray = pullDownViewArray;
}

- (void)setData:(NSArray<NSArray *> *)dataArray
{
    if (dataArray.count != self.pullDownViewArray.count) {
        NSLog(@"\n%s\tinvalid parameters\n", __PRETTY_FUNCTION__);
        return;
    }
    
    for (NSInteger i = 0; i < dataArray.count; ++i) {
        JCHInventoryPullDownBaseView *baseView = self.pullDownViewArray[i];
        [baseView setData:dataArray[i]];
    }
    
    return;
}

- (void)setSearchBarText:(NSString *)text
{
    self.searchBar.textField.text = text;
}

- (void)setSelectedButtonStatus:(BOOL)selected
{
    self.selectedButton.selected = selected;
}

- (void)clearOption:(NSInteger)menuIndex
{
    [self.pullDownViewArray[menuIndex] clearOption];
}

- (void)selectCell:(NSInteger)menuIndex cellIndex:(NSInteger)cellIndex
{
    [(JCHInventoryPullDownTableView *)(self.pullDownViewArray[menuIndex]) selectCell:cellIndex];
}

- (void)selectButton:(NSInteger)menuIndex buttonIndex:(NSInteger)buttonIndex
{
    [(JCHInventoryPullDownCategoryView *)(self.pullDownViewArray[menuIndex]) selectButton:buttonIndex];
}

- (NSString *)getSelectedButtonTitle:(NSUInteger)menuIndex
{
    JCHInventoryPullDownCategoryView *pullDownView = (JCHInventoryPullDownCategoryView *)self.pullDownViewArray[menuIndex];
    return [pullDownView getSelectButtonTitle];
}

- (void)createSectionViewButtons
{
    
    UIFont *titleFont = [UIFont systemFontOfSize:14.0f];
    UIColor *titleColor = JCHColorMainBody;
    UIColor *selectedTitleColor = JCHColorHeaderBackground;
    CGFloat buttonHeight = 44;
    CGFloat buttonWidth = (self.frame.size.width - buttonHeight) / self.buttonTitlesArray.count;
    CGFloat edgeInsetOffset = 16.0f;
    
    _buttonsContentView = [[[UIView alloc] init] autorelease];
    _buttonsContentView.frame = CGRectMake(0, 0, 2 * kScreenWidth, buttonHeight);
    [self addSubview:_buttonsContentView];
    _buttonsContentView.clipsToBounds = NO;
    
    
    
    for (NSInteger i = 0; i < self.buttonTitlesArray.count; i++) {
        
        CGRect frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
        
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleButtonClick:)
                                                title:self.buttonTitlesArray[i]
                                           titleColor:titleColor
                                      backgroundColor:[UIColor whiteColor]];
        button.titleLabel.font = titleFont;
        button.tag = i;
        button.frame = frame;
        [button setImage:[UIImage imageNamed:@"inventory_multiselect_open_icon"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"inventory_multiselect_close_icon"] forState:UIControlStateSelected];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -edgeInsetOffset, 0, edgeInsetOffset)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 2 * edgeInsetOffset, 0, -2 * edgeInsetOffset)];
        [button setTitleColor:selectedTitleColor forState:UIControlStateSelected];
        [_buttonsContentView addSubview:button];
    }
    
    
    _searchButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleButtonClick:)
                                         title:nil
                                    titleColor:titleColor
                               backgroundColor:[UIColor whiteColor]];
    _searchButton.titleLabel.font = titleFont;
    _searchButton.tag = self.buttonTitlesArray.count;
    _searchButton.frame = CGRectMake(self.buttonTitlesArray.count * buttonWidth, 0, buttonHeight, buttonHeight);
    [_searchButton setImage:[UIImage imageNamed:@"inventory_ic_search"] forState:UIControlStateNormal];
    [_buttonsContentView addSubview:_searchButton];
    
    
    UIView *verticalSeprateLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kSeparateLineWidth, buttonHeight)] autorelease];
    verticalSeprateLine.backgroundColor = JCHColorSeparateLine;
    [_searchButton addSubview:verticalSeprateLine];
    
    _bottomLineView = [[[UIView alloc] init] autorelease];
    _bottomLineView.backgroundColor = JCHColorSeparateLine;
    _bottomLineView.frame = CGRectMake(0, 44 - kSeparateLineWidth, self.frame.size.width, kSeparateLineWidth);
    [_buttonsContentView addSubview:_bottomLineView];
    
    self.searchBar = [[[JCHSearchBar alloc] initWithFrame:CGRectZero] autorelease];
    self.searchBar.frame = CGRectMake(self.frame.size.width, 0, kScreenWidth, buttonHeight);
    NSAttributedString *placeHolder = [[[NSAttributedString alloc] initWithString:@"请输入菜品名称/拼音首字母" attributes:@{NSForegroundColorAttributeName : JCHColorAuxiliary, NSFontAttributeName : [UIFont systemFontOfSize:13.0f]}] autorelease];
    self.searchBar.textField.attributedPlaceholder = placeHolder;
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    [_buttonsContentView addSubview:self.searchBar];
    
    
    
    return;
}

#pragma mark -
#pragma mark JCHInventoryPullDownBaseViewDelegate
- (void)filteredSKUValueUUIDArray:(NSArray *)filteredSKUValueUUIDArray
{
    if ([self.delegate respondsToSelector:@selector(skuSelect:UUIDArray:)]) {
        [self.delegate skuSelect:self.selectedButton.tag UUIDArray:filteredSKUValueUUIDArray];
    }
}

- (void)pullDownView:(JCHInventoryPullDownBaseView *)view buttonSelected:(NSInteger)buttonTag
{
    if ([self.delegate respondsToSelector:@selector(buttonClick:buttonSelected:)]) {
        [self.delegate buttonClick:self.selectedButton.tag buttonSelected:buttonTag];
    }
}

- (void)selectedRow:(NSInteger)row buttonTag:(NSInteger)tag
{
    if ([self.delegate respondsToSelector:@selector(tableViewSelectRow:tableRow:)]) {
        [self.delegate tableViewSelectRow:self.selectedButton.tag tableRow:tag];
    }
}

#pragma mark -
#pragma mark section view button click
- (void)handleButtonClick:(UIButton *)sender
{
    //本次点击和上次不是同一个
    if (self.selectedButton != sender && self.selectedButton) {
        self.selectedButtonChanged = YES;
        self.selectedButton.selected = NO;
    } else {
        self.selectedButtonChanged = NO;
    }
    
    self.selectedButton = sender;
    sender.selected = !sender.selected;
    
    // 点击搜索按钮
    if (sender.tag == self.buttonTitlesArray.count) {
        [pullDownContainerView hideCompletion:^{
            [self showSearchBar:YES];
            
            if ([self.delegate respondsToSelector:@selector(clickSearchButton)]) {
                [self.delegate clickSearchButton];
            }
        }];
    } else {
        // 点击筛选按钮
        JCHInventoryPullDownBaseView *pullDownView = self.pullDownViewArray[sender.tag];
        [self showPullDownView:pullDownView];
    }
    
    BOOL isContainerTableView = [superContainerView isKindOfClass:[UITableView class]];
    if (isContainerTableView) {
        UITableView *theTableView = (UITableView *)superContainerView;
        if (pullDownContainerView.isShow) {
            theTableView.scrollEnabled = NO;
        } else {
            theTableView.scrollEnabled = YES;
        }
    }
}

- (void)showPullDownView:(JCHInventoryPullDownBaseView *)view
{
    //如果这次点击的button和上次的不一样
    if (self.selectedButtonChanged) {
        if (pullDownContainerView.isShow) {
            [pullDownContainerView hideCompletion:^{
                [pullDownContainerView show:view];
            }];
        } else {
            [pullDownContainerView show:view];
        }
    } else {
        
        if (pullDownContainerView.isShow) {
            [pullDownContainerView hideCompletion:nil];
        } else {
            [pullDownContainerView show:view];
        }
    }
}

#pragma mark -
#pragma mark 显示搜索框
- (void)showSearchBar:(BOOL)showFlag
{
    CGRect buttonsContentFrame = _buttonsContentView.frame;
    if (showFlag) {
        buttonsContentFrame.origin.x -= kScreenWidth;
    } else {
        buttonsContentFrame.origin.x += kScreenWidth;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _buttonsContentView.frame = buttonsContentFrame;
    }];
    
    return;
}

- (void)clickMaskView
{
    [self handleButtonClick:self.selectedButton];
}

#pragma mark -
#pragma mark UISearchBar delegate
- (void)searchBarCancelButtonClicked:(JCHSearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:searchBar];
    }
}

- (void)searchBarTextChanged:(JCHSearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextChanged:)]) {
        [self.delegate searchBarTextChanged:searchBar];
    }
}

- (void)searchBarDidBeginEditing:(JCHSearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:)]) {
        [self.delegate searchBarDidBeginEditing:searchBar];
    }
}

#pragma mark - 
#pragma mark JCHInventoryPullDownContainerViewDelegate
- (void)showAlertView
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:@"您当前还未添加规格"
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.selectedButton.selected = NO;
}


#pragma mark -
#pragma mark isShow
- (BOOL)isShow
{
    return pullDownContainerView.isShow;
}

- (void)show:(NSInteger)menuIndex
{
    JCHInventoryPullDownBaseView *pullDownView = self.pullDownViewArray[menuIndex];
    [pullDownContainerView show:pullDownView];
}

- (void)hide:(DataSectionViewHideBlock)hideBlock
{
    [pullDownContainerView hideCompletion:hideBlock];
}

@end
