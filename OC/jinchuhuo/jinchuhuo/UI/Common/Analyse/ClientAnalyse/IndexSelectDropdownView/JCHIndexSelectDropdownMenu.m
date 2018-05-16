//
//  JCHIndexSelectDropdownMenu.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHIndexSelectDropdownMenu.h"
#import "JCHSettingSectionView.h"
#import "JCHIndexSelectCollectionViewCell.h"
#import "CommonHeader.h"

@implementation JCHArrowButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat height = contentRect.size.height;
    CGFloat width = contentRect.size.width - 17;

    return CGRectMake(x, y, width, height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat y = 0;
    CGFloat height = contentRect.size.height;
    CGFloat width = 17;
    CGFloat x = contentRect.size.width - width;

    return CGRectMake(x, y, width, height);
}

@end

@interface JCHIndexSelectDropdownMenu () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) UIView *fatherView;
@property (nonatomic, retain) UICollectionView *contentCollectionView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *maskView;
@property (nonatomic, retain) UIButton *selectedButton;

@end

@implementation JCHIndexSelectDropdownMenu
{
    UILabel *_manifestCountLabel;
    JCHArrowButton *_middleButton;
    JCHArrowButton *_indexSelectButton;
    
    CGFloat _collectionViewCellHeight;
    CGFloat _collectionViewSectionViewHeight;
}

- (void)dealloc
{
    self.backgroundView = nil;
    self.maskView = nil;
    self.dataSource = nil;
    self.selectedButton = nil;
    
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.fatherView = superView;
        
        if (iPhone4) {
            _collectionViewCellHeight = 35;
            _collectionViewSectionViewHeight = 25;
        } else {
            _collectionViewCellHeight = 44;
            _collectionViewSectionViewHeight = 30;
        }
        
        
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat leftLabelWidth = 100.0f;
    CGFloat middelButtonWidth = 50.0f;
    CGFloat rightButtonWidth = 100.0f;
    
    _manifestCountLabel = [JCHUIFactory createLabel:CGRectMake(kStandardLeftMargin, 0, leftLabelWidth, kJCHIndexSelectDropdownMenuHeight)
                                              title:@"客户数:18"
                                               font:JCHFont(13)
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    _manifestCountLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_manifestCountLabel];
    
    
    _middleButton = [[[JCHArrowButton alloc] initWithFrame:CGRectMake((kScreenWidth - rightButtonWidth - 2 * kStandardLeftMargin - middelButtonWidth), 0, middelButtonWidth, kJCHIndexSelectDropdownMenuHeight)] autorelease];
    [_middleButton addTarget:self action:@selector(sortData:) forControlEvents:UIControlEventTouchUpInside];
    [_middleButton setTitle:@"降序" forState:UIControlStateNormal];
    [_middleButton setTitle:@"升序" forState:UIControlStateSelected];
    [_middleButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    _middleButton.titleLabel.font = JCHFont(13);
    _middleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    //[_middleButton setTitleColor:UIColorFromRGB(0xdd4041) forState:UIControlStateSelected];
    [_middleButton setImage:[UIImage imageNamed:@"inventory_multiselect_inventorysort_hightolow_icon"] forState:UIControlStateNormal];
    [_middleButton setImage:[UIImage imageNamed:@"inventory_multiselect_inventorysort_lowtohigh_icon"] forState:UIControlStateSelected];
    [self addSubview:_middleButton];
    
    _indexSelectButton = [[[JCHArrowButton alloc] initWithFrame:CGRectMake((kScreenWidth - rightButtonWidth - kStandardLeftMargin), 0, rightButtonWidth, kJCHIndexSelectDropdownMenuHeight)] autorelease];
    [_indexSelectButton addTarget:self action:@selector(pullDownView:) forControlEvents:UIControlEventTouchUpInside];
    [_indexSelectButton setTitle:@"销售金额" forState:UIControlStateNormal];
    [_indexSelectButton setTitleColor:JCHColorMainBody forState:UIControlStateNormal];
    _indexSelectButton.titleLabel.font = JCHFont(13);
    _indexSelectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_indexSelectButton setTitleColor:UIColorFromRGB(0xdd4041) forState:UIControlStateSelected];
    [_indexSelectButton setImage:[UIImage imageNamed:@"inventory_multiselect_open_icon"] forState:UIControlStateNormal];
    [_indexSelectButton setImage:[UIImage imageNamed:@"inventory_multiselect_close_icon"] forState:UIControlStateSelected];
    [self addSubview:_indexSelectButton];
    
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    //flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, kJCHIndexSelectDropdownMenuHeight);
    flowLayout.itemSize = CGSizeMake(kScreenWidth / 3, kStandardItemHeight);
    flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, _collectionViewSectionViewHeight);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    self.contentCollectionView = [[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] autorelease];
    self.contentCollectionView.dataSource = self;
    self.contentCollectionView.delegate = self;
    self.contentCollectionView.alwaysBounceVertical = YES;
    self.contentCollectionView.clipsToBounds = NO;
    self.contentCollectionView.backgroundColor = [UIColor whiteColor];
    [self.contentCollectionView registerClass:[JCHIndexSelectCollectionViewCell class] forCellWithReuseIdentifier:@"JCHIndexSelectCollectionViewCell"];
    [self.contentCollectionView registerClass:[JCHSettingSectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    self.backgroundView = [[[UIView alloc] init] autorelease];
    self.backgroundView.clipsToBounds = YES;
    [self.backgroundView addSubview:self.contentCollectionView];
    
    self.maskView = [[[UIView alloc] init] autorelease];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    [self.fatherView addSubview:self.maskView];

    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)] autorelease];
    [self.maskView addGestureRecognizer:tap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offset = 0;
    if (self.frame.origin.y > self.defaultOrignY) {
        offset = self.frame.origin.y;
    }
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).with.offset(-offset);
        make.left.right.bottom.equalTo(self.fatherView);
    }];
}

- (void)setOffsetY:(CGFloat)offsetY
{
    if (_offsetY != offsetY) {
        _offsetY = offsetY;
        [self.maskView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).with.offset(-self.offsetY);
        }];
    }
}

- (void)pullDownView:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.selectedButton != sender) {
        self.selectedButton.selected = NO;
        self.selectedButton = sender;
    }
    
    
    if (self.selectedButton.selected) {
        
        NSInteger cellRow = 0;
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            cellRow += ceil([self.dataSource[i] count] / 3.0);
        }
        
        
        CGFloat contentCollectionViewHeight = cellRow * _collectionViewCellHeight + self.dataSource.count * _collectionViewSectionViewHeight;
        
        //collectionView的最大值
        CGFloat contentCollectionViewHeightMax = CGRectGetHeight(self.fatherView.frame) - self.defaultOrignY - CGRectGetHeight(self.frame);
        
        contentCollectionViewHeight = MIN(contentCollectionViewHeight, contentCollectionViewHeightMax);
        
        CGFloat offset = self.offsetY;
        if (self.frame.origin.y > self.defaultOrignY) {
            offset = self.frame.origin.y;
        }
        NSLog(@"frame = %@", NSStringFromCGRect(self.frame));
        
        [self.fatherView bringSubviewToFront:self.maskView];
        [self.fatherView addSubview:self.backgroundView];
        [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).with.offset(-offset);
            make.left.right.equalTo(self.fatherView);
            make.height.mas_equalTo(0);
        }];
        
        [self.contentCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.backgroundView);
            make.height.mas_equalTo(contentCollectionViewHeight);
        }];
        
        [self.backgroundView layoutIfNeeded];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(contentCollectionViewHeight);
                }];
                [self.backgroundView.superview layoutIfNeeded];
                self.maskView.alpha = 0.3;
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(indexSelectDropdownMenuDidShow)]) {
                    [self.delegate indexSelectDropdownMenuDidShow];
                }
            }];
            self.show = YES;
        });
    } else {
        [self hideView];
    }
}

- (void)sortData:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.selectedButton != sender) {
        [self hideView];
    }
    _ascending = sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(indexSelectDropdownMenuSortData:)]) {
        [self.delegate indexSelectDropdownMenuSortData:sender.selected];
    }
}

- (void)hideViewCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.backgroundView.superview layoutIfNeeded];
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(indexSelectDropdownMenuDidHide)]) {
            [self.delegate indexSelectDropdownMenuDidHide];
        }
        
        if (completion) {
            completion();
        }
    }];
    self.show = NO;
    self.selectedButton.selected = NO;
}

- (void)hideView
{
    [self hideViewCompletion:nil];
}

- (void)setManifestCount:(NSInteger)manifestCount
{
    _manifestCountLabel.text = [NSString stringWithFormat:@"客户数:%ld", manifestCount];
}

#pragma mark - UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
    //return CGSizeMake(kScreenWidth / 4, kStandardItemHeight);
//}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCHIndexSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JCHIndexSelectCollectionViewCell" forIndexPath:indexPath];

    cell.contentString = self.dataSource[indexPath.section][indexPath.row];
    if ([self.selectedButton.currentTitle isEqualToString:cell.contentString]) {
        cell.selected = YES;
        [self.contentCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        cell.selected = NO;
    }
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.dataSource[indexPath.section][indexPath.row];
    if ([text isEmptyString]) {
        return;
    }
    JCHIndexSelectCollectionViewCell *cell = (JCHIndexSelectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self.selectedButton setTitle:cell.contentString forState:UIControlStateNormal];
    [self hideViewCompletion:^{
        if ([self.delegate respondsToSelector:@selector(indexSelectDropdownMenuDidHideSelectIndexPath:)]) {
            [self.delegate indexSelectDropdownMenuDidHideSelectIndexPath:indexPath];
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JCHSettingSectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.bottomLine.hidden = YES;
        if (indexPath.section == 0) {
            headerView.titleLabel.text = @"销售指标";
        } else if (indexPath.section == 1){
            headerView.titleLabel.text = @"毛利指标";
        } else {
            headerView.titleLabel.text = @"退货指标";
        }
        return headerView;
    }
    return nil;
}


@end
