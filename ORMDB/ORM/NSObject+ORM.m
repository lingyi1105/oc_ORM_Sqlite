//
//  NSObject+ORM.m
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import "NSObject+ORM.h"
#import "ORM.h"
#import "ORMDB.h"

@implementation NSObject (Extensions)
static dispatch_queue_t _queue;
static dispatch_once_t onceToken;

+ (void)createTable {
    [ORM createTableFromClass:[self class]];
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"ORMDB.%@", self] UTF8String], NULL);
    });
}

- (void)save:(NSArray *)keyes {
    dispatch_sync(_queue, ^() {
        [ORMDB beginTransaction];
        [ORM saveEntity:self with:keyes];
        [ORMDB commitTransaction];
    });
}

+ (void)saveListData:(NSArray *)keys andBlock:(void (^)(NSMutableArray *datas))block {
    dispatch_sync(_queue, ^() {
        [ORMDB beginTransaction];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        block(arr);
        for (id obj in arr) {
            [ORM saveEntity:obj with:keys];
        }
        [ORMDB commitTransaction];
    });
}

+ (id)getObject:(NSArray *)keys withValue:(NSArray *)values {
    return [ORM get:[self class] withKeys:keys andValues:values];
}

+ (id)list:(NSArray *)keys withValue:(NSArray *)values {
    return [ORM list:[self class] withKeys:keys andValues:values];
}

+ (void)clearTable {
    dispatch_sync(_queue, ^() {
        [ORM deleteObject:[self class] withKeys:nil andValues:nil];
    });
}

+ (void)clearTable:(NSArray *)keys withValue:(NSArray *)value {
    dispatch_sync(_queue, ^() {
        [ORM deleteObject:[self class] withKeys:keys andValues:value];
    });
}

+ (void)deleteObject:(NSArray *)keys withValue:(NSArray *)value {
    dispatch_sync(_queue, ^() {
        [ORM deleteObject:[self class] withKeys:keys andValues:value];
    });
}

+ (void)execSql:(void (^)(SqlOperationQueueObject *db))block {
    dispatch_sync(_queue, ^() {
        [ORMDB beginTransaction];
        SqlOperationQueueObject *sqlObj = [[SqlOperationQueueObject alloc] init];
        block(sqlObj);
        [ORMDB commitTransaction];
    });

}

+ (BOOL)rowExist:(NSString *)requirement {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIMIT 1", [self class], requirement];
    return [ORMDB rowExistPro:sql];
}

+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement {
    if (requirement == nil || requirement.length == 0) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", [self class]];
        return [ORMDB queryDB:[self class] andSql:sql];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [self class], requirement];
    return [ORMDB queryDB:[self class] andSql:sql];
}

+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement limit:(NSString *)limit {
    if (requirement == nil || requirement.length == 0) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT %@", [self class], limit];
        return [ORMDB queryDB:[self class] andSql:sql];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIMIT %@", [self class], requirement, limit];
    return [ORMDB queryDB:[self class] andSql:sql];
}

+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement orderBy:(NSString *)description {
    if (requirement == nil || requirement.length == 0) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@", [self class], description];
        return [ORMDB queryDB:[self class] andSql:sql];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ORDER BY %@", [self class], requirement, description];
    return [ORMDB queryDB:[self class] andSql:sql];
}
+ (NSMutableArray *)queryForObjectArrayWhere:(NSString *)requirement orderBy:(NSString *)description limit:(NSString *)limit {
    if (requirement == nil || requirement.length == 0) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ LIMIT %@", [self class], description, limit];
        return [ORMDB queryDB:[self class] andSql:sql];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ORDER BY %@ LIMIT %@", [self class], requirement, description, limit];
    return [ORMDB queryDB:[self class] andSql:sql];
}

+ (NSMutableDictionary *)queryForDictionaryWhere:(NSString *)requirement {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [self class], requirement];
    return [ORMDB queryWithSql:sql];
}

+ (NSMutableArray *)queryForObjectArray:(NSString *)sql {
    return [ORMDB queryDB:[self class] andSql:sql];
}

+ (NSMutableArray *)queryForObjectArrayWithRawSQL:(NSString *)sql {
    return [ORMDB queryDB:[self class] andSql:sql];
}

+ (NSMutableDictionary *)queryForDictionary:(NSString *)sql {
    return [ORMDB queryWithSql:sql];
}

+ (NSMutableDictionary *)queryForDictionaryWithRawSQL:(NSString *)sql {
    return [ORMDB queryWithSql:sql];
}

+ (NSMutableArray<NSMutableDictionary *> *)queryForArrayDicWithRawSQL:(NSString *)sql {
    return [ORMDB queryArrayDicWithSql:sql];
}

+ (NSUInteger)count:(NSString *)key where:(NSString *)requirement {
    if (key == nil || requirement.length == 0) {
        key = @"autoIncrementId";
    }
    if (requirement == nil || requirement.length == 0) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(%@) FROM %@", key, [self class]];
        return [ORMDB countDBWithSql:sql];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(%@) FROM %@ WHERE %@", key, [self class], requirement];
    return [ORMDB countDBWithSql:sql];
}

+ (NSNumber *)sum:(NSString *)key where:(NSString *)requirement {
    if (requirement == nil || requirement.length == 0) {
        NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@", key, [self class]];
        return [ORMDB sumDB:[self class] andKey:key andSql:sql];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@", key, [self class], requirement];
    return [ORMDB sumDB:[self class] andKey:key andSql:sql];
}

@end

@implementation NSArray (ORM)

- (void)saveListDataWithKeys:(NSArray *)keys {
    dispatch_sync(_queue, ^() {
        [ORMDB beginTransaction];
        for (id obj in self) {
            [ORM saveEntity:obj with:keys];
        }
        [ORMDB commitTransaction];
    });
}

@end

@implementation SqlOperationQueueObject

/**
 执行update sql
 **/
- (void)execUpdate:(NSString *)sql {
    [ORMDB execsql:sql];
}

/**
 执行select sql
 **/
- (void)execDelete:(NSString *)sql {
    [ORMDB execsql:sql];
}

/**
 根据 select sql 返回是否 存在结果集
 
 select * from XXX where uid=1 ;
 return false 标识 不存在uid=1的数据
 **/
- (BOOL)rowExist:(NSString *)sql {
    return [ORMDB rowExist:sql];
}

@end
