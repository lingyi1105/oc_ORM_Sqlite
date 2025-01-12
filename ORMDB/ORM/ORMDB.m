//
//  ORMDB.m
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import "ORMDB.h"
#import "ORM.h"
#import <sqlite3.h>

static const void *const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;


@implementation ORMDB
static NSString *DBPath = @"";
sqlite3 *database;
static dispatch_queue_t _queue;
static dispatch_once_t onceToken;

+ (void)configDBPath:(NSString *)path {

    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"ORMDB.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *) self, NULL);
    });

    DBPath = path;
    NSLog(@"dbpath:%@", path);
}

+ (void)beginTransaction {

    ORMDB *currentSyncQueue = (__bridge id) dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue.class != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");

    if (sqlite3_open([DBPath UTF8String], &database) == SQLITE_OK) {
        char *zErrorMsg = nil;
        if (showsql) {
            NSLog(@"begin transaction ;");
        }
        sqlite3_exec(database, "begin transaction ;", 0, 0, &zErrorMsg);
    }
}

+ (void)commitTransaction {
    ORMDB *currentSyncQueue = (__bridge id) dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue.class != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");

    char *zErrorMsg = nil;
    if (showsql) {
        NSLog(@"%@", @"commit transaction ;");
    }
    sqlite3_exec(database, "commit transaction ;", 0, 0, &zErrorMsg);
    sqlite3_close(database);
}

+ (void)execsql:(NSString *)sql {
    ORMDB *currentSyncQueue = (__bridge id) dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue.class != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");

    if (showsql) {
        NSLog(@"%@", sql);
    }

    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    int result = sqlite3_step(statement);
    if (result == SQLITE_DONE) {

    } else {
        NSLog(@"数据库 访问错误...error code:%i %@", result, sql);
    }
    sqlite3_finalize(statement);
}

/**快速查询判断是否存在结果**/
+ (BOOL)rowExist:(NSString *)sql {
    BOOL result = FALSE;
    if (showsql) {
        NSLog(@"%@", sql);
    }
    sqlite3_stmt *statement;
    if ((sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            result = TRUE;
        }
        sqlite3_finalize(statement);
    }
    return result;
}

+ (BOOL)rowExistPro:(NSString *)sql {
    BOOL result = FALSE;
    if (showsql) {
        NSLog(@"%@", sql);
    }
    sqlite3_stmt *statement;
    sqlite3 *queryDB;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            result = TRUE;
        }
        sqlite3_finalize(statement);
    }
    return result;
}

/**查询判断是否存在字段**/
+ (BOOL)columnExist:(NSString *)column table:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"pragma table_info('%@')", table];
    BOOL result = FALSE;
    if (showsql) {
        NSLog(@"%@", sql);
    }
    sqlite3_stmt *statement;
    sqlite3 *queryDB;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *nameData = (char *) sqlite3_column_text(statement, 1);
            NSString *columnName = [NSString stringWithUTF8String:nameData];
            NSLog(@"columnName: %@", columnName);
            if ([column isEqualToString:columnName]) {
                result = TRUE;
                break;
            }
        }
        sqlite3_finalize(statement);
    }
    return result;
}

+ (NSArray *)columns:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"pragma table_info('%@')", table];
    NSMutableArray *arr = [NSMutableArray array];
    if (showsql) {
        NSLog(@"%@", sql);
    }
    sqlite3_stmt *statement;
    sqlite3 *queryDB;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *nameData = (char *) sqlite3_column_text(statement, 1);
            NSString *columnName = [NSString stringWithUTF8String:nameData];
            NSLog(@"columnName: %@", columnName);
            [arr addObject:columnName];
        }
        sqlite3_finalize(statement);
    }
    return [arr copy];
}

+ (NSMutableDictionary *)queryWithSql:(NSString *)sql {
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] init];
    sqlite3 *queryDB;
    sqlite3_stmt *statement;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        int columnCount = sqlite3_column_count(statement);
        if (sqlite3_step(statement) == SQLITE_ROW) {
            for (int i = 0; i < columnCount; i++) {
                id returnValue = nil;
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
                int columnType = sqlite3_column_type(statement, i);
                if (columnType == SQLITE_INTEGER) {
                    returnValue = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, i)];
                } else if (columnType == SQLITE_FLOAT) {
                    returnValue = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
                } else {
                    const char *c = (char *) sqlite3_column_text(statement, i);
                    if (!c) {
                        c = "";
                    }
                    returnValue = [[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding];
                }

                if (returnValue) {
                    [returnDic setObject:returnValue forKey:columnName];
                }
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(queryDB);
    }

    return returnDic;
}

+ (NSMutableArray *)queryDB:(Class)cls andSql:(NSString *)sql {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    sqlite3 *queryDB;
    sqlite3_stmt *statement = nil;
    ORMDBClassInfo *obj = [ORMDBClassInfo metaWithClass:cls];
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        if (showsql) {
            NSLog(@"%@", sql);
        }
        int columnCount = sqlite3_column_count(statement);
        NSMutableDictionary *tmpColumn =
                [[NSMutableDictionary alloc] initWithCapacity:columnCount];
        for (int y = 0; y < columnCount; y++) {
            NSString *columnName =
                    [NSString stringWithUTF8String:sqlite3_column_name(statement, y)];
            [tmpColumn setObject:@(y) forKey:columnName];
        }
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSObject *object = [[cls alloc] init];
            for (ORMDBClassPropertyInfo *info in obj.propertyInfos) {
                if (info.type != ORMDBDataTypeClass && info.type != ORMDBDataTypeArray && info.type != ORMDBDataTypeMutableArray && info.type != ORMDBDataTypeUnknown) {
                    NSNumber *num = [tmpColumn valueForKey:info.name];
                    if (!num) {
                        continue;
                    }
                    int index = [num intValue];

                    const char *c = (char *) sqlite3_column_text(statement, index);
                    if (!c) {
                        c = "";
                    }

                    NSString *value = [[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding];
                    NSString *ucfirstName = [info.name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[info.name substringToIndex:1] uppercaseString]];
                    NSString *selectorName = [NSString stringWithFormat:@"set%@:", ucfirstName];

                    SEL setterMethod = NSSelectorFromString(selectorName);

                    switch (info.type) {
                        case ORMDBDataTypeString: {
                            ((void (*)(id, SEL, id)) (void *) objc_msgSend)((id) object, setterMethod, value);
                        }
                            break;
                        case ORMDBDataTypeInt: {
                            ((void (*)(id, SEL, long long)) (void *) objc_msgSend)((id) object, setterMethod, [value longLongValue]);
                        }
                            break;
                        case ORMDBDataTypeBool: {
                            ((void (*)(id, SEL, int)) (void *) objc_msgSend)((id) object, setterMethod, [value boolValue]);
                        }
                            break;
                        case ORMDBDataTypeFloat: {
                            ((void (*)(id, SEL, float)) (void *) objc_msgSend)((id) object, setterMethod, [value floatValue]);
                        }
                            break;
                        case ORMDBDataTypeNSDate: {
                            ((void (*)(id, SEL, NSDate *)) (void *) objc_msgSend)((id) object, setterMethod, [NSDate dateWithTimeIntervalSince1970:[value doubleValue]]);
                        }
                            break;
                        case ORMDBDataTypeDouble: {
                            ((void (*)(id, SEL, double)) (void *) objc_msgSend)((id) object, setterMethod, [value doubleValue]);
                        }
                            break;
                        case ORMDBDataTypeNumber: {
                            ((void (*)(id, SEL, NSNumber *)) (void *) objc_msgSend)((id) object, setterMethod, (NSNumber *) ORMDBNumberCreateFromID(value));
                        }
                            break;
                        case ORMDBDataTypeDictionary:
                        case ORMDBDataTypeMutableDictionary: {
                            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *json =
                            (NSDictionary * )
                            [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if (info.type == ORMDBDataTypeMutableDictionary) {
                                ((void (*)(id, SEL, NSMutableDictionary *)) (void *) objc_msgSend)((id) object, setterMethod, json.mutableCopy);
                            } else {
                                ((void (*)(id, SEL, NSDictionary *)) (void *) objc_msgSend)((id) object, setterMethod, json);
                            }
                        }
                            break;
                        default: {
                            ((void (*)(id, SEL, id)) (void *) objc_msgSend)((id) object, setterMethod, value);
                        }
                            break;
                    }

                } else {
                    SEL foreignSelector = NSSelectorFromString(@"foreignKey");
                    Class fcls = info.cls;
                    if (info.protocol) {
                        fcls = NSClassFromString(info.protocol);
                    }
                    NSMethodSignature *foreignSignature = [fcls methodSignatureForSelector:foreignSelector];
                    if (foreignSignature) {
                        id foreignObjectValue = ((id(*)(id, SEL)) (void *) objc_msgSend)((id) [fcls class], foreignSelector);
                        SEL primarySelector = NSSelectorFromString(@"primarilyKey");
                        id primaryKey = ((id(*)(id, SEL)) (void *) objc_msgSend)((id) [object class], primarySelector);
                        SEL sel = NSSelectorFromString(primaryKey);
                        id primaryKeyValue = ((id(*)(id, SEL)) (void *) objc_msgSend)((id) object, sel);

                        if (!primaryKeyValue) {
                            NSLog(@"ERROR :%@ primaryKeyValue empty for %@ query this error is not important and automatically skips this error query", cls, fcls);
                            continue;
                        }

                        Class tmpcls = info.protocol ? NSClassFromString(info.protocol) : info.cls;
                        NSString *sql = nil;
                        if (info.protocol) {
                            sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@", SelectColumn(tmpcls), info.protocol, createWhereStatement(@[foreignObjectValue], @[primaryKeyValue])];
                        } else {
                            sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@", SelectColumn(tmpcls), info.cls, createWhereStatement(@[foreignObjectValue], @[primaryKeyValue])];
                        }

                        NSMutableArray *a = [ORMDB queryDB:info.protocol?NSClassFromString(info.protocol):info.cls andSql:sql];
                        id obj = a;
                        if (info.type == ORMDBDataTypeUnknown && info.cls) {
                            if (a.count > 0) {
                                obj = a[0];
                            }
                        }
                        [object setValue:obj forKey:info.name];

                    } else {
                        NSLog(@"==== %@ +(NSString *)foreignKey not found", fcls);
                    }
                }
            }

            [arr addObject:object];
        }
        sqlite3_finalize(statement);
        sqlite3_close(queryDB);
    }

    return arr;
}

+ (NSMutableArray<NSMutableDictionary *> *)queryArrayDicWithSql:(NSString *)sql {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    sqlite3 *queryDB;
    sqlite3_stmt *statement;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        int columnCount = sqlite3_column_count(statement);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < columnCount; i++) {
                id returnValue = nil;
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
                int columnType = sqlite3_column_type(statement, i);
                if (columnType == SQLITE_INTEGER) {
                    returnValue = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, i)];
                } else if (columnType == SQLITE_FLOAT) {
                    returnValue = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
                } else {
                    const char *c = (char *) sqlite3_column_text(statement, i);
                    if (!c) {
                        c = "";
                    }
                    returnValue = [[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding];
                }

                if (returnValue) {
                    [returnDic setObject:returnValue forKey:columnName];
                }
            }
            
            [arr addObject:[returnDic copy]];
        }
        sqlite3_finalize(statement);
        sqlite3_close(queryDB);
    }
    return arr;
}

+ (void)saveObject:(id)entity withSql:(NSString *)sql {

    ORMDB *currentSyncQueue = (__bridge id) dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue.class != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");

    if (showsql) {
        NSLog(@"%@", sql);
    }


    ORMDBClassInfo *obj = [ORMDBClassInfo metaWithClass:[entity class]];
    int y = 1;

    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        for (ORMDBClassPropertyInfo *info in obj.propertyInfos) {
            if ([info.name isEqualToString:@"autoIncrementId"] && ![entity valueForKey:info.name]) {
                continue;
            }

            if (info.type != ORMDBDataTypeClass && info.type != ORMDBDataTypeArray && info.type != ORMDBDataTypeMutableArray && info.type != ORMDBDataTypeUnknown) {

                id objvalue = [entity valueForKey:info.name];

                switch (info.type) {
                    case ORMDBDataTypeInt:
                    case ORMDBDataTypeNumber:
                    case ORMDBDataTypeBool: {
                        if (!objvalue || [objvalue isEqual:[NSNull null]]) {
                            objvalue = @(0);
                        }

                        if (CFNumberIsFloatType((CFNumberRef)objvalue)) {
                            sqlite3_bind_double(statement, y, [objvalue doubleValue]);
                        } else {
                            sqlite3_bind_int64(statement, y, [objvalue longLongValue]);
                        }
                    }
                        break;
                    case ORMDBDataTypeNSDate: {
                        NSDate *date = (NSDate *) objvalue;
                        if (!objvalue) {
                            date = [NSDate dateWithTimeIntervalSince1970:0];
                        }
                        sqlite3_bind_double(statement, y, [date timeIntervalSince1970]);
                    }
                        break;
                    case ORMDBDataTypeFloat:
                    case ORMDBDataTypeDouble: {
                        if (!objvalue) {
                            objvalue = @0;
                        }
                        sqlite3_bind_text(statement, y, [[NSString stringWithFormat:@"%f", [objvalue doubleValue]] UTF8String], -1, NULL);
                    }
                        break;
                    case ORMDBDataTypeDictionary:
                    case ORMDBDataTypeMutableDictionary: {
                        if (!objvalue) {
                            objvalue = @{};
                        }
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objvalue options:0 error:NULL];
                        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                        sqlite3_bind_text(statement, y, [str UTF8String], -1, NULL);
                    }
                        break;
                    default: {
                        if (!objvalue || [objvalue isEqual:[NSNull null]] || [objvalue compare:@"(null)"] == NSOrderedSame || [objvalue compare:@"<null>"] == NSOrderedSame) {
                            objvalue = @"";
                        }
                        sqlite3_bind_text(statement, y, [objvalue UTF8String], -1, NULL);
                    }
                        break;
                }

                y = y + 1;
            }
        }
        int result = sqlite3_step(statement);
        if (result == SQLITE_DONE) {

        } else {

            NSLog(@"数据库保存错误:%i %@", result, sql);
        }
        sqlite3_finalize(statement);
    }

}

+ (NSInteger)countDBWithSql:(NSString *)sql {
    sqlite3 *queryDB;
    sqlite3_stmt *statement = nil;
    NSInteger result = 0;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        if (showsql) {
            NSLog(@"%@", sql);
        }

        if (sqlite3_step(statement) == SQLITE_ROW) {
            const char *c = (char *) sqlite3_column_text(statement, 0);
            if (!c) {
                c = "";
            }
            NSString *value = [[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding];

            result = value.integerValue;
        }
        sqlite3_finalize(statement);
        sqlite3_close(queryDB);
    }
    return result;
}

+ (NSNumber *)sumDB:(Class)cls andKey:(NSString *)key andSql:(NSString *)sql {
    sqlite3 *queryDB;
    sqlite3_stmt *statement = nil;
    NSNumber *num = nil;
    if (sqlite3_open([DBPath UTF8String], &queryDB) == SQLITE_OK && (sqlite3_prepare_v2(queryDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)) {
        if (showsql) {
            NSLog(@"%@", sql);
        }

        if (sqlite3_step(statement) == SQLITE_ROW) {
            const char *c = (char *) sqlite3_column_text(statement, 0);
            if (!c) {
                c = "";
            }
            NSString *value = [[NSString alloc] initWithCString:c encoding:NSUTF8StringEncoding];
            NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
            num = [numFormatter numberFromString:value];
        }
        sqlite3_finalize(statement);
        sqlite3_close(queryDB);
    }
    
    return num;
}


@end
