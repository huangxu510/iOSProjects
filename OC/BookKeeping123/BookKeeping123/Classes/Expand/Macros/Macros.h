//
//  Macros.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//


#ifndef Macros_h
#define Macros_h

//===========================================常量===========================================//

#define kAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define kApplication        [UIApplication sharedApplication]
#define kApplication        [UIApplication sharedApplication]
#define kKeyWindow          [UIApplication sharedApplication].keyWindow
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]

//#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//#define kScreenHeight [UIScreen mainScreen].bounds.size.height


/**
 * App版本号
 */
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

/**
 *  导航栏高度
 */
#define kNavBarHeight (kStatusBarHeight + 44)

/**
 *  iphone x 导航栏和底部高度 table使用 safeArea
 */
#define kNavBarHeightAndTabHeight (kScreenHeight >= 812 ? (88+34):64)
#define kTabBarHeight (kStatusBarHeight > 20 ? 83 : 49)

/**
 *  获取temp
 */
#define kTempPath NSTemporaryDirectory()

/**
 *  获取沙盒 Document
 */
#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

/**
 *  获取沙盒 Cache
 */
#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

// MainScreen Height&Width
//#define kScreenHeight      [[UIScreen mainScreen] bounds].size.height
//#define kScreenWidth       [[UIScreen mainScreen] bounds].size.width





//===========================================尺寸===========================================//

/**
 *  不同屏幕尺寸字体适配（375，667是因为效果图为IPHONE6 如果不是则根据实际情况修改）
 */
#define kScreenWidthRatio  (kScreenWidth / 375.0)
#define kScreenHeightRatio (kScreenHeight / 667.0)
#define AdaptedWidth(x)  ceilf((x) * kScreenWidthRatio)
#define AdaptedHeight(x) ceilf((x) * kScreenHeightRatio)
#define AdaptedFontSize(R)     [UIFont systemFontOfSize:AdaptedWidth(R)]







//===========================================颜色===========================================//

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
#define HexColor(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]



//=========================================表达式===========================================//

/**
 *  字符串是否为空
 */
#define kEmptyString(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )

/**
 *  是否是空对象
 */
#define IsEmptyObject(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

/**
 *  由角度转换弧度
 */
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
/**
 *  由弧度转换角度
 */
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

#ifdef DEBUG
#   define MPLog(s, ... ) NSLog(@"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#   define MPLog(...)
#endif

/**
 *  属性转字符串
 */
#define MPKeyPath(obj, key) @(((void)obj.key, #key))

/**
 *  弱引用/强引用
 */
#define WeakSelf __weak typeof(self) weakSelf = self
#define StrongSelf __strong typeof(self) strongSelf = weakSelf

#define MPUserDefault [NSUserDefaults standardUserDefaults]


#define IMG(imageName) [UIImage imageNamed:imageName]
#define URL(urlString) [NSURL URLWithString:urlString]
/**
 *  圆角
 */
#define BKCornerRadius(view, radius)  view.layer.cornerRadius = radius;\
view.layer.masksToBounds = YES;\

#endif /* Macros_h */
