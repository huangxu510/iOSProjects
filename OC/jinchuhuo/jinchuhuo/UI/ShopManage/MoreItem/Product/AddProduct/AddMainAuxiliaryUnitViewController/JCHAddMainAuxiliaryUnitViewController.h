//
//  JCHAddMainAuxiliaryUnitViewController.h
//  jinchuhuo
//
//  Created by apple on 16/8/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "UnitRecord4Cocoa.h"

@interface ProductUnitRecord : NSObject
@property (retain, nonatomic, readwrite) id recordUUID;
@property (retain, nonatomic, readwrite) UnitRecord4Cocoa *unitRecord;
@property (assign, nonatomic, readwrite) CGFloat convertRatio;
@property (assign, nonatomic, readwrite) CGFloat copyConvertRatio;
@end



@interface JCHAddMainAuxiliaryUnitViewController : JCHBaseViewController

- (id)initWithMainUnit:(NSString *)productUUID
              mainUnit:(UnitRecord4Cocoa *)mainUnit
             unitArray:(NSMutableArray<ProductUnitRecord *> *)unitArray;

@end
