//
//  MealHistoryModel.m
//  Elink
//
//  Created by LarryZhang on 2021/10/11.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import "MealHistoryModel.h"

@interface MealHistoryModel ()
@end

@implementation MealHistoryModel

#pragma mark ---- ORM
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self createTable];
    });
}

+ (NSArray<NSString *> *_Nonnull)sqlIgnoreColumn {
    return @[NSStringFromSelector(@selector(massValueMilligram))];
}

//+ (NSString *)primarilyKey {
//    return NSStringFromSelector(@selector(autoIncrementId));
//}

#pragma mark ---- sqlite 保存
- (instancetype)save {
    if (self.name == nil || self.massValueMilligram == 0) {
        return nil;
    }
    [self save:@[]];
    return self;
}

- (void)remove {
    [[self class] deleteObject:@[NSStringFromSelector(@selector(autoIncrementId))] withValue:@[self.autoIncrementId]];
}

- (instancetype)update {
    if (self.name == nil) {
        return nil;
    }
    [self save:@[NSStringFromSelector(@selector(autoIncrementId))]];
    return self;
}

#pragma mark ---- sqlite 保存列表
+ (void)saveList:(NSArray *)list {
    [list saveListDataWithKeys:@[]];
}

#pragma mark ---- sqlite 查询列表
+ (NSArray *)queryListByDateString:(NSString *)dateString andMmealType:(NSNumber *)mealType {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(dateString)), dateString];
    where  = [where stringByAppendingFormat:@" AND %@ = %@", NSStringFromSelector(@selector(mealType)), mealType];
    NSString *order = [NSStringFromSelector(@selector(autoIncrementId)) stringByAppendingString:@" ASC"];
    
    NSArray *array = [self queryForObjectArrayWhere:where orderBy:order limit:@"0,100"];
    return array;
}

+ (BOOL)rowExistByDateString:(NSString *)dateString {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(dateString)), dateString];
    return [self rowExist:where];
}

+ (BOOL)isEmpty {
    return ![self rowExist:@"1"];
}

+ (instancetype)firstOne {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    NSString *order = [NSString stringWithFormat:@"%@ ASC", NSStringFromSelector(@selector(year))];
    order = [order stringByAppendingFormat:@", %@ ASC", NSStringFromSelector(@selector(month))];
    order = [order stringByAppendingFormat:@", %@ ASC", NSStringFromSelector(@selector(day))];
    NSArray *array = [self queryForObjectArrayWhere:where orderBy:order limit:@"1"];
    if (array == nil || array.count == 0) {
        return nil;
    }
    return array.firstObject;
}

+ (NSNumber *)sumDaily:(NSString *)key byDate:(NSDate *)date {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(year)), @(2021)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(month)), @(8)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(day)), @(26)];
    
    return [self sum:key where:where];
}

+ (NSNumber *)sumWeekly:(NSString *)key byDate:(NSDate *)date {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(year)), @(2021)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(month)), @(1)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(weekOfYear)), @(3)];
    
    return [self sum:key where:where];
}

+ (NSNumber *)sumMonthly:(NSString *)key byDate:(NSDate *)date {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(year)), @(2021)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(month)), @(9)];
    
    return [self sum:key where:where];
}

+ (NSArray *)queryListAll {
    NSUInteger subUserId = 9527;
    NSString *where = [NSStringFromSelector(@selector(subUserId)) stringByAppendingFormat:@" = %@", @(subUserId)];
    NSString *order = [NSString stringWithFormat:@"%@ ASC", NSStringFromSelector(@selector(year))];
    order = [order stringByAppendingFormat:@", %@ ASC", NSStringFromSelector(@selector(month))];
    order = [order stringByAppendingFormat:@", %@ ASC", NSStringFromSelector(@selector(day))];
    
    NSArray *array = [self queryForObjectArrayWhere:where orderBy:order limit:@"0,1000"];
    return array;
}

@end
