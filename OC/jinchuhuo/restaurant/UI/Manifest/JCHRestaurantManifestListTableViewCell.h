//
//  JCHRestaurantManifestListTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 2016/12/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "JCHBaseTableViewCell.h"
#import "JCHManifestType.h"
#import "JCHManifestListTableViewCell.h"

@interface JCHRestaurantManifestListTableViewCell : SWTableViewCell

@property (nonatomic, assign) NSInteger manifestType;

- (void)setCellData:(ManifestInfo *)cellData;
- (void)setButtonStateSelected:(BOOL)selected;
- (void)hideShowMenuButton:(BOOL)hidden;

@end
