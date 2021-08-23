//
//  NSObject+ORM.h
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORM.h"

@interface SqlOperationQueueObject : NSObject
/**
 执行update sql
 **/
- (void)execUpdate:(NSString *)sql;

/**
 执行select sql
 **/
- (void)execDelete:(NSString *)sql;

/**
 根据 select sql 返回是否 存在结果集
 
 select * from XXX where uid=1 ;
 
 return false 标识 不存在uid=1的数据
 **/
- (BOOL)rowExist:(NSString *)sql;
@end

@interface NSObject (Extensions)
/**
 创建表
 
 **/
+ (void)createTable;

/**
 保存数据
 @param keyes 数据保存参数条件
 **/
- (void)save:(NSArray *)keyes;

/**
 查询单个对象
 @param keys 参数条件
 @param values 值
 **/
+ (id)getObject:(NSArray *)keys withValue:(NSArray *)values;

/**
 查询列表
 **/
+ (id)list:(NSArray *)keys withValue:(NSArray *)values;

/**
 清空表数据
 **/
+ (void)clearTable;

/**
 删除数据
 **/
+ (void)deleteObject:(NSArray *)keys withValue:(NSArray *)value;
+ (void)clearTable:(NSArray *)keys withValue:(NSArray *)value DEPRECATED_MSG_ATTRIBUTE("use deleteObject:withValue instead");


/**
 保存列表集合数据
 @param keys 参数条件
 @param block 回调参数
 **/
+ (void)saveListData:(NSArray *)keys andBlock:(void (^)(NSMutableArray *datas))block;

/**
 自定义sql requirement查询 数据是否村子
 例：[CLS rowExist:@"gender = 'man' and age = '20'"]
 **/
+ (BOOL)rowExist:(NSString *)requirement;

/**
 自定义sql requirement查询，并返回封装对象的结果 集合
 例：[CLS queryForObjectArrayWhere:@"gender = 'man' and age = '20'"]
 **/
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement;

/**
 自定义sql requirement查询 description排序，并返回封装对象的结果 集合
 例：[CLS queryForObjectArrayWhere:@"gender = 'man' and age = '20'" orderBy:@"id desc, birthday asc"]
 **/
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement orderBy:(NSString *)description;

/**
    只返回 一行查询结果，通过字段名字取值
 
    NSMutableDictionary *result= [XXX queryForDictionaryWhere:@"id = 1"];
 
    result[@"columnName"];
 */
+ (NSMutableDictionary *)queryForDictionaryWhere:(NSString *)requirement;

/**
 自定义sql查询，并返回封装对象的结果 集合
 **/
+ (NSMutableArray *)queryForObjectArray:(NSString *)sql DEPRECATED_MSG_ATTRIBUTE("use queryForObjectArrayWhere instead");

/**
	只返回 一行查询结果，通过字段名字取值
 
	NSMutableDictionary *result= [XXX queryForDictionary:@"select * from User"];
 
	result[@"columnName"];
 */
+ (NSMutableDictionary *)queryForDictionary:(NSString *)sql DEPRECATED_MSG_ATTRIBUTE("use queryForDictionaryWhere instead");

/**
 执行自定义 sql  update/insert
 **/

+ (void)execSql:(void (^)(SqlOperationQueueObject *db))block;

@end

@interface NSArray (ORM)

- (void)saveListDataWithKeys:(NSArray *)keys;

@end


