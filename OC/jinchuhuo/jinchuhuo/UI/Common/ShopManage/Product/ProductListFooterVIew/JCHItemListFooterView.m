//
//  JCHProductListFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHItemListFooterView.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import <Masonry.h>


@implementation JCHItemListFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xf8f8f8);

        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.categoryName release];
    [self.categoryUnit release];
    
    [super dealloc];
}


- (void)createUI
{
    UIView *topLine = [[[UIView alloc] init] autorelease];
    topLine.backgroundColor = JCHColorSeparateLine;
    topLine.frame = CGRectMake(0, 0, kScreenWidth, kSeparateLineWidth);
    [self addSubview:topLine];
    
    UIFont *titleFont = [UIFont systemFontOfSize:17];
    
    _productCountLabel = [JCHUIFactory createLabel:CGRectMake(20, 0, kScreenWidth / 3, self.frame.size.height)
                                             title:@""
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:_productCountLabel];
    
    CGFloat buttonWidth = 70;
    _addProductButton = [JCHUIFactory createButton:CGRectMake(kScreenWidth - buttonWidth, 0, buttonWidth, self.frame.size.height)
                                            target:self
                                            action:@selector(handleAppProduct)
                                             title:nil
                                        titleColor:nil
                                   backgroundColor:nil];
    [_addProductButton setImage:[UIImage imageNamed:@"icon_add2"] forState:UIControlStateNormal];
    _addProductButton.titleLabel.font = titleFont;
    [self addSubview:_addProductButton];
    
    _selectAllButton = [JCHUIFactory createButton:CGRectMake((kScreenWidth - 2 * buttonWidth)/ 2, 0, 2 * buttonWidth, self.frame.size.height)
                                            target:self
                                           action:@selector(handleSelectAll:)
                                             title:@"全选"
                                        titleColor:UIColorFromRGB(0x4c8cdf)
                                   backgroundColor:nil];
    [_selectAllButton setTitle:@"取消全选" forState:UIControlStateSelected];
    _selectAllButton.titleLabel.font = titleFont;
    [self addSubview:_selectAllButton];
    _selectAllButton.hidden = YES;
    
    _deleteButton = [JCHUIFactory createButton:CGRectMake(kScreenWidth - buttonWidth, 0, buttonWidth, self.frame.size.height)
                                            target:self
                                            action:@selector(handleDeleteProducts)
                                             title:@"删除"
                                        titleColor:UIColorFromRGB(0x4c8cdf)
                                   backgroundColor:nil];
    _deleteButton.titleLabel.font = titleFont;
//    _deleteButton.backgroundColor = [UIColor redColor];
    _deleteButton.hidden = YES;
    [self addSubview:_deleteButton];
}

- (void)handleAppProduct
{
    if ([self.delegate respondsToSelector:@selector(addItem)])
    {
        [self.delegate addItem];
    }
}

- (void)handleDeleteProducts
{
    if ([self.delegate respondsToSelector:@selector(deleteItems)]) {
        [self.delegate deleteItems];
    }
}

- (void)handleSelectAll:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(selectAll:)]) {
        [self.delegate selectAll:button];
        button.selected = !button.selected;
    }
}

- (void)setData:(NSInteger)count
{
    //NSString *item = nil;
    //NSString *unit = nil;
    //if (_currentType == kJCHProductListFooterViewType) {
        //item = @"商品";
        //unit = @"件";
    //}
    //else if (_currentType == kJCHCategoryListFooterViewType)
    //{
        //item = @"类型";
        //unit = @"种";
    //}
    //else
    //{
        //item = @"规格";
        //unit = @"种";
    //}
    
    if (_selectAllButton.hidden)
    {
        _productCountLabel.text = [NSString stringWithFormat:@"%ld%@%@", (long)count, self.categoryUnit, self.categoryName];
    }
    else
    {
        _productCountLabel.text = [NSString stringWithFormat:@"已选中%ld%@", (long)count, self.categoryUnit];
    }
}
- (void)changeUI:(BOOL)editMode
{
    if (editMode) {
        _selectAllButton.hidden = YES;
        
        _deleteButton.hidden = YES;
        _addProductButton.hidden = NO;
    }
    else
    {
        _selectAllButton.hidden = NO;
        _deleteButton.hidden = NO;
        _addProductButton.hidden = YES;
        _selectAllButton.selected = NO;
    }
}

- (void)setButtonSelected:(BOOL)selected
{
    _selectAllButton.selected = selected;
}

- (void)hideAddButton
{
    _addProductButton.hidden = YES;
}

@end
