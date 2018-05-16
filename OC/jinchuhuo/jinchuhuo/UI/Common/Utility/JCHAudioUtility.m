//
//  JCHAudioUtility.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAudioUtility.h"
#import <AVFoundation/AVFoundation.h>

@implementation JCHAudioUtility


+ (void)playAudio:(NSString *)resource shake:(BOOL)shake
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:resource withExtension:nil];
    
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((CFURLRef)(url), &soundID);
    
    AudioServicesPlaySystemSound(soundID);
    
    if (shake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
    }
    
}


@end
