//
//  JCHProductSalePriceTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 16/8/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductSalePriceTableViewCellData : NSObject

@property (retain, nonatomic, readwrite) NSString *cellTitle;
@property (retain, nonatomic, readwrite) NSString *priceText;
@property (assign, nonatomic, readwrite) id cellTag;

@end

@interface JCHProductSalePriceTableViewCell : UITableViewCell

- (void)setCellData:(JCHProductSalePriceTableViewCellData *)cellData
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
     showBottomView:(BOOL)showBottomView
        isFirstCell:(BOOL)isFirstCell
         isLastCell:(BOOL)isLastCell;

- (void)setCellText:(NSString *)cellText;


@end
