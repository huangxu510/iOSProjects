//
//  JCHImageUtility.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHeader.h"
#import "ProductRecord4Cocoa.h"

@interface JCHImageUtility : NSObject

+ (NSString *)getImagePath:(NSString *)imageName;
+ (NSString *)getAvatarImageNameFromAvatarUrl:(NSString *)avatarUrl;
+ (void)showPhotoBrowser:(ProductRecord4Cocoa *)productRecord viewController:(UIViewController *)viewController;

// 压缩图片
+ (NSData *)compressImage:(UIImage *)originalImage maxLength:(NSUInteger)maxKB;

// 异步上传商品图片
+ (void)uploadProductImages:(NSArray *)productImages;

+ (void)uploadProductImages:(NSArray *)productImages completionCallBack:(void(^)())completion;

// 获取根据图片名获取图片url
+ (void)getImageURL:(NSArray *)imageNameArray
     successHandler:(void(^)(NSDictionary *))successHandler
     failureHandler:(void(^)(NSError *))failureHandler;

@end
