//
//  NewOjbSubInfo.h
//  ORMDB
//
//  Created by LarryZhang on 2021/8/20.
//  Copyright © 2021 PengLinmao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NewOjbSubInfo
@end

@interface NewOjbSubInfo : NSObject

@property(nonatomic, assign) NSUInteger nid;
@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, assign) NSUInteger sid;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *content;

@end

NS_ASSUME_NONNULL_END
