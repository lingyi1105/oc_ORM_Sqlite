//
//  NSObject+ORM.h
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 自定义sql requirement查询，并返回封装对象的结果 数组
 例：[CLS queryForObjectArrayWhere:@"gender = 'man' and age = '20'"]
 **/
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement;

/**
 自定义sql requirement查询 limit限制查询结果返回的数量，并返回封装对象的结果 数组
 例：[CLS queryForObjectArrayWhere:@"gender = 'man' and age = '20'" limit:@"0,30"]
 **/
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement limit:(NSString *)limit;

/**
 自定义sql requirement查询 description排序，并返回封装对象的结果 数组
 例：[CLS queryForObjectArrayWhere:@"gender = 'man' and age = '20'" orderBy:@"id desc, birthday asc"]
 **/
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement orderBy:(NSString *)description;

/**
 自定义sql requirement查询 description排序 limit限制查询结果返回的数量，并返回封装对象的结果 数组
 例：[CLS queryForObjectArrayWhere:@"gender = 'man' and age = '20'" orderBy:@"id desc, birthday asc" limit:@"0,30"]
 **/
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement orderBy:(NSString *)description limit:(NSString *)limit;

/**
    只返回 一行查询结果，通过字段名字取值
    NSMutableDictionary *result= [CLS queryForDictionaryWhere:@"id = 1"];
    result[@"columnName"];
 */
+ (NSMutableDictionary *)queryForDictionaryWhere:(NSString *)requirement;

/**
 自定义sql查询，并返回封装对象的结果 数组
 **/
+ (NSMutableArray *)queryForObjectArray:(NSString *)sql DEPRECATED_MSG_ATTRIBUTE("use queryForObjectArrayByRawSQL instead");
+ (NSMutableArray *)queryForObjectArrayWithRawSQL:(NSString *)sql;

/**
	只返回 一行查询结果，通过字段名字取值
	NSMutableDictionary *result= [CLS queryForDictionary:@"select * from User"];
	result[@"columnName"];
 */
+ (NSMutableDictionary *)queryForDictionary:(NSString *)sql DEPRECATED_MSG_ATTRIBUTE("use queryForDictionaryWithRawSQL instead");
+ (NSMutableDictionary *)queryForDictionaryWithRawSQL:(NSString *)sql;

/**
    返回 所有结果 字典 的 数组
    NSMutableArray<NSMutableDictionary *> *result= [CLS queryForDictionary:@"select * from User"];
 */
+ (NSMutableArray<NSMutableDictionary *> *)queryForArrayDicWithRawSQL:(NSString *)sql;

/**
	返回 数量count
	NSUInteger count = [CLS count:@"*" where:@"day = 22"];
 */
+ (NSUInteger)count:(NSString *)key where:(NSString *)requirement;

/**
	返回 单个字段sum值
	NSNumber *sum = [CLS sum:@"mealType" where:@"day = 22"];
 */
+ (NSNumber *)sum:(NSString *)key where:(NSString *)requirement;

/**
 执行自定义 sql  update/insert
 **/

+ (void)execSql:(void (^)(SqlOperationQueueObject *db))block;

@end

@interface NSArray (ORM)

- (void)saveListDataWithKeys:(NSArray *)keys;

@end


