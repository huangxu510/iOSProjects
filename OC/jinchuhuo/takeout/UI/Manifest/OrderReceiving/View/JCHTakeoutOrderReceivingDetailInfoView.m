//
//  JCHTakeoutOrderReceivingDetailInfoView.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderReceivingDetailInfoView.h"
#import "CommonHeader.h"

#define kDishItemHeight 28
#define kDishHeaderHeight 30
#define kBoxPriceLabelHeight 28
#define kDishFooterHeight 56


@implementation JCHTakeoutOrderReceivingDetailInfoView
{
    UIView *_remarkContainerView;
    UILabel *_remarkLabel;
    UIView *_dishContainerView;
    JCHTitleDetailLabel *_dishTotalAmountLabel;
    JCHTitleDetailLabel *_deliveryAmountLabel;
    JCHTitleDetailLabel *_boxPriceLabel;
    UIButton *_expandedButton;
    
    CGFloat _dishContainerViewHeight;
    CGFloat _remarkLabelWidth;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.expandBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    UILabel *nameLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"商品"
                                              font:[UIFont jchBoldSystemFontOfSize:14]
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.mas_equalTo(kDishHeaderHeight);
    }];
    
    _expandedButton = [JCHUIFactory createButton:CGRectZero
                                      target:self
                                      action:@selector(handleExpand)
                                       title:@""
                                  titleColor:JCHColorMainBody
                             backgroundColor:[UIColor whiteColor]];
    [_expandedButton setImage:[UIImage imageNamed:@"icon_takeout_order_close"] forState:UIControlStateNormal];
    [_expandedButton setImage:[UIImage imageNamed:@"icon_takeout_order_open"] forState:UIControlStateSelected];
    [self addSubview:_expandedButton];
    
    [_expandedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(nameLabel);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.width.mas_equalTo(30);
    }];
    
    _remarkContainerView = [[[UIView alloc] init] autorelease];
    _remarkContainerView.clipsToBounds = YES;
    [self addSubview:_remarkContainerView];
    
    [_remarkContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kStandardLeftMargin);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
        make.top.equalTo(nameLabel.mas_bottom);
        make.height.mas_equalTo(kDishItemHeight);
    }];
    
    UILabel *remarkTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"备注:"
                                                     font:JCHFont(12.0)
                                                textColor:JCHColorMainBody
                                                   aligin:NSTextAlignmentLeft];
    [_remarkContainerView addSubview:remarkTitleLabel];
    
    CGSize fitSize = [remarkTitleLabel sizeThatFits:CGSizeZero];
    [remarkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(_remarkContainerView);
        make.height.mas_equalTo(kDishItemHeight);
        make.width.mas_equalTo(fitSize.width + 5);
    }];
    _remarkLabelWidth = kScreenWidth - 3 *kStandardLeftMargin - fitSize.width - 5;
    _remarkLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:JCHFont(12.0)
                                   textColor:JCHColorAuxiliary
                                      aligin:NSTextAlignmentLeft];
    _remarkLabel.numberOfLines = 0;
    [_remarkContainerView addSubview:_remarkLabel];
    
    [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(remarkTitleLabel.mas_right);
        make.right.equalTo(_remarkContainerView);
        make.top.height.equalTo(_remarkContainerView);
    }];
    
    _dishContainerView = [[[UIView alloc] init] autorelease];
    _dishContainerView.clipsToBounds = YES;
    [self addSubview:_dishContainerView];
    
    [_dishContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_remarkLabel.mas_bottom);
        make.left.right.equalTo(self);
    }];

    
    _boxPriceLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"餐盒费"
                                                            font:JCHFont(12)
                                                       textColor:JCHColorAuxiliary
                                                          detail:@""
                                                bottomLineHidden:YES] autorelease];
    _boxPriceLabel.clipsToBounds = YES;
    [self addSubview:_boxPriceLabel];
    
    [_boxPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_dishContainerView);
        make.top.equalTo(_dishContainerView.mas_bottom);
        make.height.mas_equalTo(kBoxPriceLabelHeight);
    }];
    
    _dishTotalAmountLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"小计"
                                                                   font:JCHFont(12)
                                                              textColor:JCHColorMainBody
                                                                 detail:@""
                                                       bottomLineHidden:YES] autorelease];
    [self addSubview:_dishTotalAmountLabel];
    
    [_dishTotalAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_dishContainerView);
        make.top.equalTo(_boxPriceLabel.mas_bottom);
        make.height.mas_equalTo(kDishFooterHeight / 2);
    }];
    
    _deliveryAmountLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"用户支付配送费"
                                                                      font:JCHFont(12)
                                                                 textColor:JCHColorAuxiliary
                                                                    detail:@""
                                                          bottomLineHidden:YES] autorelease];
    [self addSubview:_deliveryAmountLabel];
    
    [_deliveryAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(_dishTotalAmountLabel);
        make.top.equalTo(_dishTotalAmountLabel.mas_bottom);
    }];
    
    [self addBrokeLineToView:self Top:YES offset:kStandardLeftMargin];
    [self addBrokeLineToView:_remarkContainerView Top:NO offset:0];
    [self addBrokeLineToView:_dishContainerView Top:NO offset:kStandardLeftMargin];
    [self addBrokeLineToView:_boxPriceLabel Top:NO offset:kStandardLeftMargin];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExpand)] autorelease];
    [self addGestureRecognizer:tap];
}

- (void)addBrokeLineToView:(UIView *)view Top:(BOOL)top offset:(CGFloat)offset
{
    UIImageView *brokeLineView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [view addSubview:brokeLineView];
    
    [brokeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(offset);
        make.right.equalTo(view).offset(-offset);
        make.height.mas_equalTo(1);
        if (top) {
            make.top.equalTo(view);
        } else {
            make.bottom.equalTo(view);
        }
    }];
}


- (void)handleExpand
{
    _expandedButton.selected = !_expandedButton.selected;
    if (self.expandBlock) {
        self.expandBlock(_expandedButton.selected);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
}

- (void)setViewData:(JCHTakeoutOrderInfoModel *)model
{
    _dishTotalAmountLabel.detailLabel.text = [NSString stringWithFormat:@"%.2f", model.orderTotalAmount];
    _deliveryAmountLabel.detailLabel.text = [NSString stringWithFormat:@"%.2f", model.shippingFee];
    
    // 备注
    CGFloat remarkLabelHeight = kDishItemHeight;
    if (!model.caution || [model.caution isEmptyString]) {
        remarkLabelHeight = 0;
        [_remarkContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        _remarkLabel.text = model.caution;
        
        CGRect frame = [_remarkLabel.text boundingRectWithSize:CGSizeMake(_remarkLabelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _remarkLabel.font} context:nil];
        
        if (frame.size.height > remarkLabelHeight) {
            remarkLabelHeight = frame.size.height + 10;
        }
        [_remarkContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(remarkLabelHeight);
        }];
    }
    
        CGFloat boxTotalPrice = 0;
        CGFloat dishTotalAmount = 0;
        for (NSInteger i = 0; i < model.detail.count; i++) {
            JCHTakeoutOrderInfoDishModel *dishModel = model.detail[i];

            CGFloat boxPrice = dishModel.boxNum * dishModel.boxPrice;
            boxTotalPrice += boxPrice;
            CGFloat dishAmount = dishModel.quantity * dishModel.price;
            dishTotalAmount += dishAmount;
        }
        dishTotalAmount += boxTotalPrice;
    
    // 餐盒费
    if (boxTotalPrice == 0) {
        [_boxPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        _boxPriceLabel.detailLabel.text = [NSString stringWithFormat:@"%.2f", boxTotalPrice];
    }
    
    _dishContainerViewHeight = model.detail.count * kDishItemHeight;
    [_dishContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_dishContainerViewHeight * model.dishInfoExpanded);
    }];

    for (UIView *subView in _dishContainerView.subviews) {
        if ([subView isKindOfClass:[JCHTakeoutOrderReceivingDetailItemView class]]) {
            [subView removeFromSuperview];
        }
    }
    for (NSInteger i = 0; i < model.detail.count; i++) {
        CGRect frame = CGRectMake(0, kDishItemHeight * i, kScreenWidth - kStandardLeftMargin, kDishItemHeight);
        JCHTakeoutOrderInfoDishModel *dishModel = model.detail[i];
        JCHTakeoutOrderReceivingDetailItemView *itemView = [[[JCHTakeoutOrderReceivingDetailItemView alloc] initWithFrame:frame] autorelease];
        [_dishContainerView addSubview:itemView];
        [itemView setViewData:dishModel];
    }
    
    _expandedButton.selected = model.dishInfoExpanded;

    self.viewHeight = (_dishContainerViewHeight + remarkLabelHeight + kDishFooterHeight + kBoxPriceLabelHeight * !(boxTotalPrice == 0)) * model.dishInfoExpanded + kDishHeaderHeight ;
}

@end
