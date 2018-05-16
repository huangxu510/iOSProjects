//
//  main.m
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    
#if BUILD_FOR_CODE_COVERAGE
    
#if !TARGET_OS_SIMULATOR
    const char *prefix = "GCOV_PREFIX";
    const char *prefixValue = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] cStringUsingEncoding:NSASCIIStringEncoding];
    setenv(prefix, prefixValue, 1);
#endif
    
    // This gets the filepath to the app's Documents directory
    const char *prefixStrip = "GCOV_PREFIX_STRIP";
    const char *prefixStripValue = "1";
    // This sets an environment variable which tells gcov where to put the .gcda files.
    setenv(prefixStrip, prefixStripValue, 1);
    // This tells gcov to strip the default prefix, and use the filepath that we just declared.
#endif

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
 
