//
//  Student.m
//  ORMDB
//
//  Created by mao PengLin on 2017/6/2.
//  Copyright © 2017年 PengLinmao. All rights reserved.
//

#import "Student.h"

@implementation Student
+(NSString *)foreignKey{
    return NSStringFromSelector(@selector(classNumber));
}
+(NSString *)primarilyKey{
    return NSStringFromSelector(@selector(sid));
}
@end
