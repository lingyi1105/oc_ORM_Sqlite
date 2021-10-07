//
//  NewOjbSubInfo.m
//  ORMDB
//
//  Created by LarryZhang on 2021/8/20.
//  Copyright © 2021 PengLinmao. All rights reserved.
//

#import "NewOjbSubInfo.h"
#import "ORM.h"

@implementation NewOjbSubInfo

//**** 外键需要是 object，否则 报错 //id primarilyKeyValue = ((id (*)(id, SEL)) (void *) objc_msgSend)((id) entity, NSSelectorFromString(primarilyKey));
+ (NSString *)foreignKey {
    return NSStringFromSelector(@selector(id));
//    return NSStringFromSelector(@selector(nid));
}

+ (NSString *)primarilyKey {
    return NSStringFromSelector(@selector(sid));
}

@end
