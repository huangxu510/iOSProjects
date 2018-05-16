//
//  ManifestDetailTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHManifestType.h"


@interface JCHManifestDetailTableViewCellData : NSObject
@property (retain, nonatomic, readwrite) NSString *productName;
@property (retain, nonatomic, readwrite) NSString *productCount;
@property (retain, nonatomic, readwrite) NSString *productDiscount;
@property (retain, nonatomic, readwrite) NSString *productPrice;
@property (retain, nonatomic, readwrite) NSString *productImageName;
@end

@interface JCHManifestDetailTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isLastCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier manifestType:(enum JCHOrderType)manifestType;
- (void)setData:(JCHManifestDetailTableViewCellData *)cellData;


@end
