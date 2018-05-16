//
//  ManifestHeaderView.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/2.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManifestHeaderViewDelegate <NSObject>

- (void)handleRecentOrder;
- (void)handleAllOrder;

@end

#if 0
@interface JCHManifestHeaderViewData : NSObject

@property (retain, nonatomic, readwrite) NSString *sectionTitle;
@property (retain, nonatomic, readwrite) NSString *purchasesCount;
@property (retain, nonatomic, readwrite) NSString *shipmentCount;

@end
#endif

@interface ManifestHeaderView : UIView

@property (assign, nonatomic, readwrite) id<ManifestHeaderViewDelegate> delegate;

//- (void)setViewData:(JCHManifestHeaderViewData *)viewData;
@end
