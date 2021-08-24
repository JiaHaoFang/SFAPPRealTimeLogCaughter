//
//  OCSwizzle.h
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/23.
//

#ifndef OCSwizzle_h
#define OCSwizzle_h

@interface Launcher: NSObject

+ (void)enable;
+ (BOOL)isWithXCode;
+ (BOOL)isSimulator;
+ (void)load;

@end

#endif /* OCSwizzle_h */
