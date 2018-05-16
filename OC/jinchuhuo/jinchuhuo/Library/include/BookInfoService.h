//
//  BookInfoService.h
//  iOSInterface
//
//  Created by apple on 15/12/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfoRecord4Cocoa.h"

@protocol BookInfoService <NSObject>

- (BookInfoRecord4Cocoa *)queryBookInfo:(NSString *)userID;
- (void)updateBookInfo:(BookInfoRecord4Cocoa *)record;
- (NSString *)queryLocalServerHost;

@end
