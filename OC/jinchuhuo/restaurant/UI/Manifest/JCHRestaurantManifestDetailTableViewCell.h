//
//  JCHRestaurantManifestDetailTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "JCHManifestType.h"
#import "JCHLeftSlideBaseTableViewCell.h"

@interface JCHRestaurantManifestDetailTableViewCellData : NSObject

@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productCount;
@property (retain, nonatomic, readwrite) NSString *productDiscount;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (assign, nonatomic, readwrite) NSString *totalAmount;
@property (retain, nonatomic, readwrite) NSString *productImageName;
@property (retain, nonatomic, readwrite) NSString *productSKUValueCombine;

@property (retain, nonatomic, readwrite) NSString *productUnit;

@property (retain, nonatomic, readwrite) NSString *productIncreaseCount;

// 最近被编辑过
@property (assign, nonatomic, getter=isLastEditedItem) BOOL lastEditedItem;

// 拼装时的辅单位数量信息
@property (retain, nonatomic, readwrite) NSString *mainAuxiliaryUnitCountInfo;

@end

@interface JCHRestaurantManifestDetailTableViewCell : JCHLeftSlideBaseTableViewCell

@property (nonatomic, assign) CGFloat cellHeight;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
       manifestType:(enum JCHOrderType)manifestType
   isManifestDetail:(BOOL)manifestDetail;

- (void)setData:(JCHRestaurantManifestDetailTableViewCellData *)cellData;

@end

