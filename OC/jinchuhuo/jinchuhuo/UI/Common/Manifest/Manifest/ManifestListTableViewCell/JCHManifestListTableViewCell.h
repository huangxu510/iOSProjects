//
//  JCHManifestListTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "JCHBaseTableViewCell.h"
#import "JCHManifestType.h"

@interface ManifestInfo : NSObject
@property (retain, nonatomic, readwrite) NSString *manifestLogoName;
@property (retain, nonatomic, readwrite) NSString *manifestOrderID;
@property (retain, nonatomic, readwrite) NSString *manifestDate;
@property (retain, nonatomic, readwrite) NSString *manifestAmount;
@property (retain, nonatomic, readwrite) NSString *manifestRemark;
@property (assign, nonatomic, readwrite) NSInteger manifestType;
@property (assign, nonatomic, readwrite) BOOL isManifestReturned;
@property (assign, nonatomic, readwrite) BOOL hasPayed;
@property (assign, nonatomic, readwrite) NSInteger manifestProductCount;
@property (assign, nonatomic, readwrite) NSInteger operatorID;
@property (retain, nonatomic, readwrite) NSString *usedTime;
@property (assign, nonatomic, readwrite) BOOL hasFinished;
@end

@interface JCHManifestListTableViewCell : SWTableViewCell

@property (nonatomic, assign) NSInteger manifestType;

- (void)setCellData:(ManifestInfo *)cellData;
- (void)setButtonStateSelected:(BOOL)selected;
- (void)hideShowMenuButton:(BOOL)hidden;

@end
