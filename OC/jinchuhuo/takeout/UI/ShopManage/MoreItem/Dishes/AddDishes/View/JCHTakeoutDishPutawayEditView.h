//
//  JCHTakeoutDishPutawayEditView.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBottomArrowButton.h"

typedef NS_ENUM(NSInteger, JCHTakeoutPutawayButtonTag) {
    kJCHTakeoutPutawayButtonTagInventory,
    kJCHTakeoutPutawayButtonTagPrice,
};

@interface JCHTakeoutDishPutawayEditViewData : NSObject

@property (retain, nonatomic) NSString *skuName;
@property (retain, nonatomic) NSString *inventory;
@property (retain, nonatomic) NSString *price;

@end

@interface JCHTakeoutDishPutawayEditView : UIView

@property (copy, nonatomic) dispatch_block_t closeViewBlock;
@property (copy, nonatomic) void(^editLabelChangeBlock)(JCHBottomArrowButton *button);
@property (assign, nonatomic) CGFloat viewHeight;
@property (retain, nonatomic) JCHBottomArrowButton *selectedButton;
@property (retain, nonatomic, readonly) NSString *inventory;
@property (retain, nonatomic, readonly) NSString *price;

- (void)setViewData:(JCHTakeoutDishPutawayEditViewData *)data;

@end
