//
//  JCHSKUSelectTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSKUSelectTableViewCell.h"
#import "CommonHeader.h"

@interface JCHSKUSelectTableViewCell ()

@property (nonatomic, retain) NSArray *allSKUValurRecords;

@end

@implementation JCHSKUSelectTableViewCell
{
    UILabel *_skuTypeLabel;
    UIButton *_selectButton;
    UIView *_bottomContainerView;
    UIView *_buttonContainerView;
    UIView *_middleLine;
    UIView *_bottomSeperateLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)dealloc
{
    self.selectedSKUValueRecordArray = nil;
    self.buttonSelectBlock = nil;
    self.buttonDeslectBlock = nil;
    self.addSKUValueBlock = nil;
    [super dealloc];
}


- (void)createUI
{
    _selectButton = [JCHUIFactory createButton:CGRectZero
                                        target:self
                                        action:@selector(handleSelectSKU:)
                                         title:nil
                                    titleColor:nil
                               backgroundColor:nil];
    //[_selectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"] forState:UIControlStateSelected];
    [self.contentView addSubview:_selectButton];
    
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _skuTypeLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:JCHFont(15.0)
                                    textColor:JCHColorMainBody
                                       aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_skuTypeLabel];
    
    [_skuTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(_selectButton);
        make.right.equalTo(_selectButton.mas_left).with.offset(-kStandardLeftMargin);
    }];
    
    self -> _bottomLine.hidden = YES;
    _middleLine = [[[UIView alloc] init] autorelease];
    _middleLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:_middleLine];
    
    [_middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.bottom.equalTo(_skuTypeLabel.mas_centerY);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    _bottomContainerView = [[[UIView alloc] init] autorelease];
    _bottomContainerView.clipsToBounds = YES;
    _bottomContainerView.backgroundColor = JCHColorGlobalBackground;
    [self.contentView addSubview:_bottomContainerView];
    
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(_skuTypeLabel.mas_bottom);
        make.height.mas_equalTo(20).priorityLow();
    }];
    
    UIImage *originalImage = [UIImage imageNamed:@"addgoods_bg_01"];
    UIImage *stretchImage = [originalImage stretchableImageWithLeftCapWidth:5 topCapHeight:1];
    UIImageView *skuDetailBackgroundImageView = [[[UIImageView alloc] initWithImage:stretchImage] autorelease];
    skuDetailBackgroundImageView.userInteractionEnabled = YES;
    skuDetailBackgroundImageView.clipsToBounds = YES;

    [_bottomContainerView addSubview:skuDetailBackgroundImageView];
    
    [skuDetailBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomContainerView);
        make.left.equalTo(_bottomContainerView).with.offset(kStandardLeftMargin);
        make.right.equalTo(_bottomContainerView).with.offset(-kStandardLeftMargin);
        //make.bottom.equalTo(_bottomContainerView).with.offset(-kStandardLeftMargin);
    }];
   
    
    UIButton *addSKUValueButton = [JCHUIFactory createButton:CGRectZero
                                                      target:self
                                                      action:@selector(handleAddSKUValue)
                                                       title:nil
                                                  titleColor:nil
                                             backgroundColor:nil];
    [addSKUValueButton setImage:[UIImage imageNamed:@"btn_setting_goods_add"] forState:UIControlStateNormal];
    [skuDetailBackgroundImageView addSubview:addSKUValueButton];
    
    [addSKUValueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_selectButton);
        make.width.height.mas_equalTo(40);
        make.top.equalTo(skuDetailBackgroundImageView);
    }];

    
    UILabel *selectInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@"选择属性"
                                                    font:JCHFont(15.0)
                                               textColor:JCHColorMainBody
                                                  aligin:NSTextAlignmentLeft];
    [skuDetailBackgroundImageView addSubview:selectInfoLabel];
    
    [selectInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(skuDetailBackgroundImageView).with.offset(kStandardLeftMargin);
        make.right.equalTo(addSKUValueButton.mas_left).with.offset(-kStandardLeftMargin);
        make.top.height.equalTo(addSKUValueButton);
    }];
    
    _buttonContainerView = [[[UIView alloc] init] autorelease];
    [skuDetailBackgroundImageView addSubview:_buttonContainerView];
    [_buttonContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(selectInfoLabel.mas_bottom);
        make.height.mas_equalTo(20);
        make.left.right.equalTo(skuDetailBackgroundImageView);
    }];
    
    [skuDetailBackgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_buttonContainerView.mas_bottom).with.offset(kStandardLeftMargin);
    }];
    
    [_bottomContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(skuDetailBackgroundImageView).with.offset(kStandardLeftMargin / 2);
    }];
    
    UIView *backgroundView = [[[UIView alloc] init] autorelease];
    backgroundView.backgroundColor = [UIColor whiteColor];
    //self.selectedBackgroundView = backgroundView;
    
    _bottomSeperateLine = [JCHUIFactory createSeperatorLine:0];
    [self.contentView addSubview:_bottomSeperateLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_right).offset(self.selected ? -kStandardLeftMargin : 0);
        make.bottom.equalTo(_skuTypeLabel);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [_bottomSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}


- (void)setCellData:(NSDictionary *)skuDict
{
    _skuTypeLabel.text = [[skuDict allKeys] firstObject];
    self.allSKUValurRecords = [[skuDict allValues] firstObject];
    [self createButtons:[[skuDict allValues] firstObject] calculate:NO];
}


- (CGFloat)createButtons:(NSArray *)skuValueRecordArray calculate:(BOOL)calculate
{
    if (!calculate) {
        [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    UIFont *titleFont = [UIFont systemFontOfSize:15.0f];
    CGRect previousFrame = CGRectZero;
    
    CGFloat buttonHeight = 24;
    CGSize size = CGSizeMake(1000, buttonHeight);
    NSDictionary *attr = @{NSFontAttributeName : titleFont};
    const CGFloat widthOffset = 10;
    const CGFloat heightOffset = 10;
    CGFloat buttonContainerViewWidth = kScreenWidth - 4 * kStandardLeftMargin;
    
    CGFloat buttonContainerViewHeight = 0;
    
    
    for (NSInteger i = 0; i < skuValueRecordArray.count; i++)
    {
        NSString *buttonTitle = [skuValueRecordArray[i] skuValue];
        
        UIButton *button = [JCHUIFactory createButton:CGRectZero
                                               target:self
                                               action:@selector(handleSelectSKUValue:)
                                                title:@""
                                           titleColor:JCHColorAuxiliary
                                      backgroundColor:[UIColor whiteColor]];
        
        button.layer.cornerRadius = buttonHeight / 2;
        button.clipsToBounds = YES;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x69a4f1)] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf3f3f3)] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.adjustsImageWhenHighlighted = NO;
        button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        button.tag = i;
        if (!calculate) {
            [_buttonContainerView addSubview:button];
            
            if (self.selectedSKUValueRecordArray) {
                for (SKUValueRecord4Cocoa *skuValueRecord in self.selectedSKUValueRecordArray) {
                    if ([skuValueRecord.skuValueUUID isEqualToString:[skuValueRecordArray[i] skuValueUUID]]) {
                        button.selected = YES;
                    }
                }
            }
            _selectButton.selected = self.selectedSKUValueRecordArray;
        }
        
        
        
        
        CGRect resultFrame = [buttonTitle boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        if (resultFrame.size.width < 30) {
            resultFrame.size.width = 30;
        }
        CGFloat currentButtonWidth = resultFrame.size.width + 2 * widthOffset;
        CGFloat currentButtonHeight = buttonHeight;
        
        
        if (i == 0) {
            buttonContainerViewHeight = 3.0 / 2 * heightOffset + buttonHeight;
            button.frame = CGRectMake(widthOffset, heightOffset / 2, currentButtonWidth, currentButtonHeight);
        }
        else
        {
            if ((previousFrame.origin.x + previousFrame.size.width + currentButtonWidth + 2 * widthOffset) > buttonContainerViewWidth) {
                previousFrame.origin.x = widthOffset;
                previousFrame.origin.y += heightOffset + currentButtonHeight;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
                buttonContainerViewHeight += heightOffset + currentButtonHeight;
            }
            else
            {
                previousFrame.origin.x += widthOffset + previousFrame.size.width;
                previousFrame.size.width = currentButtonWidth;
                button.frame = previousFrame;
            }
        }
        previousFrame = button.frame;
    }
    self.selectedSKUValueRecordArray = nil;
    if (!calculate) {
        [_buttonContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(buttonContainerViewHeight);
        }];
    }
    
    return kStandardItemHeight + 40 + buttonContainerViewHeight + 3.0 / 2 * kStandardLeftMargin;
}

- (CGFloat)calculateHeightWithData:(NSDictionary *)skuDict
{
    NSArray *skuValueRecordArray = [[skuDict allValues] firstObject];
    CGFloat viewHeight = [self createButtons:skuValueRecordArray calculate:YES];
    
    return viewHeight;
}

- (void)handleSelectSKUValue:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected && self.buttonSelectBlock) {
        self.buttonSelectBlock(self.allSKUValurRecords[sender.tag]);
        _selectButton.selected = YES;
    }
    
    if (!sender.selected && self.buttonDeslectBlock) {
        BOOL canDeslect = self.buttonDeslectBlock(self.allSKUValurRecords[sender.tag], _selectButton);
        if (!canDeslect) {
            sender.selected = YES;
        }
    }
}

- (void)handleAddSKUValue
{
    if (self.addSKUValueBlock) {
        self.addSKUValueBlock(_skuTypeLabel.text);
    }
}

- (void)handleSelectSKU:(UIButton *)sender
{
    //sender.selected = !sender.selected;
}
@end
