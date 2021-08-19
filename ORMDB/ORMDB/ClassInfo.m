//
//  ClassInfo.m
//  ORMDB
//
//  Created by mao PengLin on 2017/6/2.
//  Copyright © 2017年 PengLinmao. All rights reserved.
//

#import "ClassInfo.h"
#import "NSObject+ORM.h"

@implementation ClassInfo

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self createTable];
    });
}

+ (NSArray

<NSString *> *_Nonnull)sqlIgnoreColumn {
    return @[NSStringFromSelector(@selector(id)), NSStringFromSelector(@selector(cid))];
}

+ (NSString *)primarilyKey {
    return NSStringFromSelector(@selector(classNumber));
}

@end
