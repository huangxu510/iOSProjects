//
//  JCHUnitSpecificationInventoryTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum InventoryCellTextFieldType
{
    kInventoryTextFieldPrice,
    kInventoryTextFieldCount
};

@interface JCHUnitSpecificationInventoryTableViewCellData : NSObject

@property (retain, nonatomic, readwrite) NSString *cellTitle;
@property (retain, nonatomic, readwrite) NSString *countPlaceholderText;
@property (retain, nonatomic, readwrite) NSString *pricePlaceholderText;
@property (retain, nonatomic, readwrite) NSString *countText;
@property (retain, nonatomic, readwrite) NSString *priceText;
@property (assign, nonatomic, readwrite) id cellTag;

@end

@interface JCHUnitSpecificationInventoryTableViewCell : UITableViewCell

- (void)setCellData:(JCHUnitSpecificationInventoryTableViewCellData *)cellData
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
         isLastCell:(BOOL)isLastCell;

- (void)enableEditCellContent:(BOOL)enable;


@end
