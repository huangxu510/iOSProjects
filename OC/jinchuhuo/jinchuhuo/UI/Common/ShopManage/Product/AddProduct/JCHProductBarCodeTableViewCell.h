//
//  JCHProductBarCodeTableViewCell.h
//  jinchuhuo
//
//  Created by apple on 16/8/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHProductBarCodeTableViewCellData : NSObject

@property (retain, nonatomic, readwrite) NSString *cellTitle;
@property (retain, nonatomic, readwrite) NSString *barCode;
@property (assign, nonatomic, readwrite) id cellTag;
@property (assign, nonatomic, readwrite) UIViewController *hostController;

@end

@interface JCHProductBarCodeTableViewCell : UITableViewCell

- (void)setCellData:(JCHProductBarCodeTableViewCellData *)cellData
  textfieldDelegate:(id<UITextFieldDelegate>)textfieldDelegate
     showBottomView:(BOOL)showBottomView
        isFirstCell:(BOOL)isFirstCell
         isLastCell:(BOOL)isLastCell;


@end
