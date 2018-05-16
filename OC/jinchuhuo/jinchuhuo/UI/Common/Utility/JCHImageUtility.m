//
//  JCHImageUtility.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/15.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHImageUtility.h"
#import "CommonHeader.h"
#import "ImageFileSynchronizer.h"
#import <IDMPhotoBrowser.h>

@implementation JCHImageUtility

+ (NSString *)getImagePath:(NSString *)imageName
{
    if ([imageName isEqualToString:@""]) {
        return nil;
    }
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *productLogoName = [[[NSString alloc] initWithFormat:@"%@/images/%@", document, imageName] autorelease];
    return productLogoName;
}

+ (NSString *)getAvatarImageNameFromAvatarUrl:(NSString *)avatarUrl
{
    if (avatarUrl.length > 7) {
        return [avatarUrl substringFromIndex:7];
    }
    return nil;
}

+ (void)showPhotoBrowser:(ProductRecord4Cocoa *)productRecord viewController:(UIViewController *)viewController
{
    UIImage *defaultProductImage = [UIImage getDefaultProductImage];
//    UIImage *defaultProductDetailImage = [UIImage getDefaultProductDetailImage];
    
    UIImage *image = [UIImage jchProductImageNamed:productRecord.goods_image_name];
    UIImage *image2 = [UIImage jchProductImageNamed:productRecord.goods_image_name2];
    UIImage *image3 = [UIImage jchProductImageNamed:productRecord.goods_image_name3];
    UIImage *image4 = [UIImage jchProductImageNamed:productRecord.goods_image_name4];
    UIImage *image5 = [UIImage jchProductImageNamed:productRecord.goods_image_name5];
    
    NSArray *images = @[image, image2, image3, image4, image5];
    
    NSMutableArray *mwPhotos = [NSMutableArray array];
    for (NSInteger i = 0; i < images.count; i++) {
        UIImage *image = images[i];
        if (![UIImagePNGRepresentation(image) isEqual:UIImagePNGRepresentation(defaultProductImage)]) {
            IDMPhoto *photo = [IDMPhoto photoWithImage:image];
            [mwPhotos addObject:photo];
        }
    }
    if (mwPhotos.count == 0) {
//        [mwPhotos addObject:[IDMPhoto photoWithImage:defaultProductDetailImage]];
        [MBProgressHUD showHUDWithTitle:@"温馨提示"
                                 detail:@"此商品暂无图片信息"
                               duration:kJCHDefaultShowHudTime
                                   mode:MBProgressHUDModeText
                             completion:nil];
    } else {
        IDMPhotoBrowser *browser = [[[IDMPhotoBrowser alloc] initWithPhotos:mwPhotos] autorelease];
        browser.displayDoneButton = YES;
        browser.navigationController.navigationBar.hidden = YES;
        browser.displayToolbar = YES;
        browser.displayCounterLabel = YES;
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.useWhiteBackgroundColor = NO;
        browser.usePopAnimation = NO;
        [viewController presentViewController:browser animated:YES completion:nil];
    }
}

+ (NSData *)compressImage:(UIImage *)originalImage maxLength:(NSUInteger)maxKB
{
    NSData *imageData = UIImageJPEGRepresentation(originalImage, 1);
    
    NSUInteger imageKB = imageData.length / 1024;
    CGFloat compressionQuality = 1.0f;
    while (imageKB > 400) {
        compressionQuality -= 0.05;
        imageData = UIImageJPEGRepresentation(originalImage, compressionQuality);
        imageKB = imageData.length / 1024;
    }
    
    return imageData;
}


+ (void)uploadProductImages:(NSArray *)productImages completionCallBack:(void(^)())completion
{
    NSMutableArray *productImageList = [NSMutableArray array];
    for (NSString *productImage in productImages) {
        if (![productImage isEqualToString:kDefaultCameraButtonImageName]) {
            [productImageList addObject:productImage];
        }
    }
    // 上传图片
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[ImageFileSynchronizer sharedInstance] uploadImageFile:statusManager.userID
                                                     deviceUUID:statusManager.deviceUUID
                                                          token:statusManager.syncToken
                                                  accountBookID:statusManager.accountBookID
                                                     serviceURL:[NSString stringWithFormat:@"%@/service/qiniu", statusManager.imageInterHostIP]
                                                     appVersion:appVersion
                                                    syncVersion:[NSString stringWithFormat:@"%d", (int)databaseVersion]
                                                       syncNode:[dataSync getSyncNodeID]
                                             imageFileNameArray:productImageList
                                              completionHandler:^{
                                                  
                                                  NSLog(@"uploadImageCompletion---------------");
                                                  if (completion) {
                                                      completion();
                                                  }
                                             }];
    });
}

+ (void)uploadProductImages:(NSArray *)productImages
{
    [self uploadProductImages:productImages completionCallBack:nil];
}


+ (void)getImageURL:(NSArray *)imageNameArray
     successHandler:(void(^)(NSDictionary *))successHandler
     failureHandler:(void(^)(NSError *))failureHandler
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    id<DatabaseUpgradeService> upgradeService = [[ServiceFactory sharedInstance] databaseUpgradeService];
    id<DataSyncService> dataSync = [[ServiceFactory sharedInstance] dataSyncService];
    NSInteger databaseVersion = [upgradeService getCurrentDatabaseVersion];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    
    [[ImageFileSynchronizer sharedInstance] getImageURL:statusManager.userID
                                             deviceUUID:statusManager.deviceUUID
                                                  token:statusManager.syncToken
                                          accountBookID:statusManager.accountBookID
                                             serviceURL:[NSString stringWithFormat:@"%@/service/qiniu", statusManager.imageInterHostIP]
                                             appVersion:appVersion
                                            syncVersion:[NSString stringWithFormat:@"%d", (int)databaseVersion]
                                               syncNode:[dataSync getSyncNodeID]
                                     imageFileNameArray:imageNameArray
                                         successHandler:^(NSDictionary *dict) {
                                             if (successHandler) {
                                                 successHandler(dict);
                                             }
                                         } failureHandler:^(NSError *error) {
                                             if (failureHandler) {
                                                 failureHandler(error);
                                             }
                                         }];
}

@end
