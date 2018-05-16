//
//  JCHAddMainAuxilaryUnitCell.h
//  jinchuhuo
//
//  Created by apple on 16/9/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHAddMainAuxiliaryUnitViewController.h"

@interface JCHAddMainAuxilaryUnitCell : UITableViewCell

@property (retain, nonatomic, readwrite) ProductUnitRecord *productUnitRecord;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCellData:(NSInteger)cellIndex
       mainUnitName:(NSString *)mainUnitName
   auxilaryUnitName:(NSString *)auxilaryUnitName
       convertRatio:(NSString *)convertRatio
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate;

@end
