//
//  JCHMenuView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHMenuView.h"
#import "CommonHeader.h"

#define TopToView 10.0f
#define LeftToView 10.0f

@implementation JCHMenuViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconImageView = [[[UIImageView alloc] init] autorelease];
        self.iconImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:JCHFont(14.0)
                                          textColor:[UIColor whiteColor]
                                             aligin:NSTextAlignmentCenter];
        self.titleLabel.numberOfLines = 1;
        [self.contentView addSubview:self.titleLabel];
        
        self -> _bottomLine.backgroundColor = [UIColor whiteColor];
        self -> _bottomLine.alpha = 0.5;
    }
    return self;
}

- (void)dealloc
{
    self.titleLabel = nil;
    self.iconImageView = nil;
    
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.iconImageView.image) {
        [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10).priorityHigh();
            make.width.height.mas_equalTo(30);
            make.centerY.equalTo(self.contentView);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(5).priorityHigh();
            make.right.equalTo(self.contentView).offset(-10).priorityHigh();
            make.top.bottom.equalTo(self.contentView);
        }];
    } else {
        self.iconImageView.hidden = YES;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10).priorityHigh();
            make.right.equalTo(self.contentView).offset(-10).priorityHigh();
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    
    [self -> _bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10).priorityHigh();
        make.right.equalTo(self.contentView).offset(-10).priorityHigh();
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

@end

@implementation JCHMenuView
{
    NSArray *_titleArray;
    NSArray *_imageArray;
    CGPoint _origin;
    CGFloat _width;
    CGFloat _arrowHeight;
    TriangleDirection _direct;
    
    UITableView *_tableView;
    UIView *_backgroundView;
}


- (id)initWithTitleArray:(NSArray*)titleArray
              imageArray:(NSArray*)imageArray
                  origin:(CGPoint)origin
                   width:(CGFloat)width
               rowHeight:(CGFloat)rowHeight
               maxHeight:(CGFloat)maxHeight
                  Direct:(TriangleDirection)triDirect
{
    if (self = [super init]) {
        self.titleLabelTextAlignment = NSTextAlignmentCenter;
        _titleArray = [titleArray copy];
        _imageArray = [imageArray copy];
        _origin = origin;
        _width = width;
        _direct = triDirect;
        _arrowHeight = 8;
        
        CGFloat height = rowHeight < 44 ? 44 : rowHeight;
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [[UIApplication sharedApplication].windows[0] addSubview:_backgroundView];
        
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)] autorelease];
        [_backgroundView addGestureRecognizer:tap];
        
        CGFloat tableViewHeight = titleArray.count * height;
        tableViewHeight = MIN(tableViewHeight, maxHeight);
        
        self.frame = CGRectMake(LeftToView + origin.x, TopToView + origin.y - _arrowHeight, width, tableViewHeight + _arrowHeight);
        self.backgroundColor = [UIColor clearColor];
        
       
        
        _tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, _arrowHeight, width, tableViewHeight) style:UITableViewStylePlain] autorelease];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.alpha = 0.8;
        _tableView.layer.cornerRadius = 5;
        _tableView.bounces = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
//        _tableView.separatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[JCHMenuViewCell class] forCellReuseIdentifier:@"JCHMenuViewCell"];
        
        //设置cell举例table的距离
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 5, 0, 5);
        
        //分割线位置
        _tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        [self addSubview:_tableView];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCHMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JCHMenuViewCell"];
    cell.backgroundColor = [UIColor clearColor];
    
    [cell hideLastBottomLine:tableView indexPath:indexPath];
    //设置cell的选中状态
    cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    
    cell.titleLabel.text = _titleArray[indexPath.row];
    cell.titleLabel.textAlignment = self.titleLabelTextAlignment;
    cell.iconImageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(menuItemDidSelected:indexPath:)]) {
        [self.delegate menuItemDidSelected:self indexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissMenuView:self.hideAnimation completion:nil];
}

- (void)dismissMenuView:(BOOL)animation completion:(dismissCompletion)completion
{
    CGFloat animationTime = 0;
    if (animation) {
        animationTime = 0.2;
    }
    [UIView animateWithDuration:animationTime animations:^{
        self.alpha = 0;
        if (_direct == kLeftTriangle) {
            _tableView.frame = CGRectMake(LeftToView + _origin.x, _arrowHeight, 0, 0);
        } else if (_direct == kRightTriangle) {
            _tableView.frame = CGRectMake(CGRectGetMaxX(_tableView.frame), _arrowHeight, 0, 0);
        } else {
            _tableView.frame = CGRectMake(CGRectGetMinX(_tableView.frame), _arrowHeight, CGRectGetWidth(_tableView.frame), 0);
        }
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [_backgroundView removeFromSuperview];
        if (completion) {
            completion();
        }
        
        if ([self.delegate respondsToSelector:@selector(menuViewDidHide)]) {
            [self.delegate menuViewDidHide];
        }
    }];
}

- (void)drawRect:(CGRect)rect
{
    CGPoint topPoint = CGPointZero;
    CGPoint leftPoint = CGPointZero;
    CGPoint rightPoint = CGPointZero;
    if (_direct == kLeftTriangle){
        
        topPoint = CGPointMake(20, 0);
        leftPoint = CGPointMake(15, _arrowHeight);
        rightPoint = CGPointMake(25, _arrowHeight);
    } else if(_direct == kRightTriangle) {
        
        topPoint = CGPointMake(CGRectGetMaxX(_tableView.frame) - 20, 0);
        leftPoint = CGPointMake(CGRectGetMaxX(_tableView.frame) - 25, _arrowHeight);
        rightPoint = CGPointMake(CGRectGetMaxX(_tableView.frame) - 15, _arrowHeight);
    } else {
        
        topPoint = CGPointMake(CGRectGetMaxX(_tableView.frame) / 2, 0);
        leftPoint = CGPointMake(CGRectGetMaxX(_tableView.frame) / 2 - 5, _arrowHeight);
        rightPoint = CGPointMake(CGRectGetMaxX(_tableView.frame) / 2 + 5, _arrowHeight);
    }
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:topPoint];
    [arrowPath addLineToPoint:leftPoint];
    [arrowPath addLineToPoint:rightPoint];
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] set];
    [arrowPath fill];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
    //[self dismissMenuView:^{
        
    //}];
//}

- (void)hide
{
    [self dismissMenuView:YES completion:nil];
}

@end
