//
//  JCHAnalyseComponentView.h
//  jinchuhuo
//
//  Created by huangxu on 15/10/27.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JCHAnalyseComponentViewTag)
{
    kJCHAnalyseComponentViewPurchaseTag = 0,
    kJCHAnalyseComponentViewShipmentTag,
    kJCHAnalyseComponentViewProfitTag,
    kJCHAnalyseComponentViewInventoryTag,
};
@interface JCHAnalyseComponentView : UIView

- (void)setImage:(NSString *)imageName
           title:(NSString *)title
          detail:(NSString *)detail
      titleColor:(UIColor *)color;

@end
