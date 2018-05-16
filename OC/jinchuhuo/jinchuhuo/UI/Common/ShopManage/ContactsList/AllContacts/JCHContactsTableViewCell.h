//
//  JCHContactsTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHMutipleSelectedTableViewCell.h"

@interface JCHContactsTableViewCellData : NSObject

@property (nonatomic, retain) NSString *headImageName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, assign) BOOL savingCardHidden;

@end

@interface JCHContactsTableViewCell : JCHMutipleSelectedTableViewCell

- (void)setData:(JCHContactsTableViewCellData *)data;

@end
