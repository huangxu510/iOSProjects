//
//  ImageFileSynchronizer.h
//  iOSInterface
//
//  Created by apple on 16/1/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFileSynchronizer : NSObject

+ (id)sharedInstance;

//! @brief 更新图片文件
- (void)modifyImageFile:(NSString *)bookID
           newImageFile:(NSString *)newImageFile
           oldImageFile:(NSString *)oldImageFile;

//! @brief 同步图片文件(上传&下载)
- (void)syncImageFile:(NSString *)userID
           deviceUUID:(NSString *)deviceUUID
                token:(NSString *)token
        accountBookID:(NSString *)accountBookID
           serviceURL:(NSString *)serviceURL
           appVersion:(NSString *)appVersion
          syncVersion:(NSString *)syncVersion
             syncNode:(NSString *)syncNode;


//! @brief 上传单张图片
- (void)uploadImageFile:(NSString *)userID
             deviceUUID:(NSString *)deviceUUID
                  token:(NSString *)token
          accountBookID:(NSString *)accountBookID
             serviceURL:(NSString *)serviceURL
             appVersion:(NSString *)appVersion
            syncVersion:(NSString *)syncVersion
               syncNode:(NSString *)syncNode
     imageFileNameArray:(NSArray *)imageFileNameArray
      completionHandler:(void(^)())completionHandler;


//! @brief 获取图片地址
- (void)getImageURL:(NSString *)userID
         deviceUUID:(NSString *)deviceUUID
              token:(NSString *)token
      accountBookID:(NSString *)accountBookID
         serviceURL:(NSString *)serviceURL
         appVersion:(NSString *)appVersion
        syncVersion:(NSString *)syncVersion
           syncNode:(NSString *)syncNode
 imageFileNameArray:(NSArray *)imageFileNameArray
     successHandler:(void(^)(NSDictionary *))successHandler
     failureHandler:(void(^)(NSError *))failureHandler;

@end
