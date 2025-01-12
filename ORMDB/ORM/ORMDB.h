//
//  ORMDB.h
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define showsql true
#else
#define showsql false
#endif

@interface ORMDB : NSObject

/**
 设置数据库路径
 **/
+ (void)configDBPath:(NSString *)path;

/**
 开启事物
 **/
+ (void)beginTransaction;

/**
 关闭事物
 **/
+ (void)commitTransaction;

/**
 自定义查询
 **/
+ (NSMutableDictionary *)queryWithSql:(NSString *)sql;

/**
 自定义查询
 **/
+ (NSMutableArray *)queryDB:(Class)cls andSql:(NSString *)sql;

/**
 自定义查询
 **/
+ (NSMutableArray<NSMutableDictionary *> *)queryArrayDicWithSql:(NSString *)sql;

+ (void)execsql:(NSString *)sql;

+ (void)saveObject:(id)object withSql:(NSString *)sql;

+ (BOOL)rowExist:(NSString *)sql;

+ (BOOL)rowExistPro:(NSString *)sql;

+ (BOOL)columnExist:(NSString *)column table:(NSString *)table;

+ (NSArray *)columns:(NSString *)table;

+ (NSInteger)countDBWithSql:(NSString *)sql;

+ (NSNumber *)sumDB:(Class)cls andKey:(NSString *)key andSql:(NSString *)sql;

@end
