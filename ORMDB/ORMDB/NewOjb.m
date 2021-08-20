//
//  NewOjb.m
//  ORMDB
//
//  Created by mao PengLin on 2017/6/9.
//  Copyright © 2017年 PengLinmao. All rights reserved.
//

#import "NewOjb.h"
#import "NSObject+ORM.h"

@implementation NewOjb

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self createTable];
    });
}

+ (NSString *)primarilyKey {
    return NSStringFromSelector(@selector(id));
//    return NSStringFromSelector(@selector(nid));
}

@end
