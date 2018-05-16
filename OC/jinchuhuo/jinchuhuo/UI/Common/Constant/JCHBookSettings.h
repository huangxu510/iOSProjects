//
//  JCHBookSettings.h
//  jinchuhuo
//
//  Created by apple on 2016/12/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef JCHBookSettings_h
#define JCHBookSettings_h

#import "ServiceFactory.h"


#if MMR_RESTAURANT_VERSION
    // 餐饮版
    #ifndef JCH_BOOK_TYPE
    #define JCH_BOOK_TYPE 1
    #endif

#elif MMR_TAKEOUT_VERSION
    // 外卖版
    #ifndef JCH_BOOK_TYPE
    #define JCH_BOOK_TYPE 2
    #endif

#else
    // 通用版
    #ifndef JCH_BOOK_TYPE
    #define JCH_BOOK_TYPE 0
    #endif

#endif





#if MMR_RESTAURANT_VERSION
    // 餐饮版
    #ifndef JCH_DATA_TYPE
    #define JCH_DATA_TYPE 1
    #endif

#elif MMR_TAKEOUT_VERSION
    // 外卖版
    #ifndef JCH_DATA_TYPE
    #define JCH_DATA_TYPE 1
    #endif

#else
    // 通用版
    #ifndef JCH_DATA_TYPE
    #define JCH_DATA_TYPE 0
    #endif

#endif




#endif /* JCHBookSettings_h */
