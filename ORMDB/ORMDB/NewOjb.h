//
//  NewOjb.h
//  ORMDB
//
//  Created by mao PengLin on 2017/6/9.
//  Copyright © 2017年 PengLinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewOjbSubInfo.h"

@interface NewOjb : NSObject

@property(nonatomic, assign) NSUInteger nid;
@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, strong) NSNumber *num;
@property(nonatomic, strong) NSString *str;
@property(nonatomic, strong) NSNumber *age;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *remark;
@property(nonatomic, assign) NSUInteger timestamp;
@property(nonatomic, assign) NSTimeInterval timestampios;

@property(nonatomic, strong) NSArray<NewOjbSubInfo> *subInfo;

@end
