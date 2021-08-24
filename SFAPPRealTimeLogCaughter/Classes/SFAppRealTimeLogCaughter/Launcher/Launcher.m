//
//  OCSwizzle.m
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import "Launcher.h"
#import <SFAPPRealTimeLogCaughter/SFAPPRealTimeLogCaughter-Swift.h>

@implementation Launcher

+ (BOOL)isWithXCode {
    return false;
}
+ (BOOL)isSimulator {
    //判断是否是Simulator
    UIDevice *device = [UIDevice currentDevice];
    return [[device model] hasSuffix:@"Simlator"];
}
+ (void)enable {
    [SFAppRealTimeLogCaughter enable];
}
+ (void)load {
    [self enable];
}

@end
