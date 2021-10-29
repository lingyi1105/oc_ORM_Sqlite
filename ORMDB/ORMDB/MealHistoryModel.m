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
    return @[];
//    return @[NSStringFromSelector(@selector(year)), NSStringFromSelector(@selector(month)), NSStringFromSelector(@selector(day)), NSStringFromSelector(@selector(weekOfYear)), NSStringFromSelector(@selector(dateString))];
}

//+ (NSString *)primarilyKey {
//    return NSStringFromSelector(@selector(autoIncrementId));
//}

#pragma mark ---- sqlite 保存
- (instancetype)save {
    if (self.autoIncrementId != nil) {
        return nil;
    }
    [self save:@[]];
    return self;
}

- (void)remove {
    [[self class] deleteObject:@[NSStringFromSelector(@selector(autoIncrementId))] withValue:@[self.autoIncrementId]];
}

- (instancetype)update {
    if (self.autoIncrementId == nil) {
        return nil;
    }
    [self save:@[NSStringFromSelector(@selector(autoIncrementId))]];
    return self;
}

+ (instancetype)getOneByAiid:(NSUInteger)aiid {
    NSString *where = [NSStringFromSelector(@selector(autoIncrementId)) stringByAppendingFormat:@" = %@", @(aiid)];
    NSArray *array = [self queryForObjectArrayWhere:where limit:@"1"];
    if (array == nil || array.count == 0) {
        return nil;
    }
    return array.firstObject;
}

#pragma mark ---- sqlite 保存列表
+ (void)saveList:(NSArray *)list {
    [list saveListDataWithKeys:@[]];
}

#pragma mark ---- sqlite 查询列表
+ (NSArray *)queryListByDateString:(NSString *)dateString andMmealType:(NSNumber *)mealType {
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(dateString)), dateString];
    where  = [where stringByAppendingFormat:@" AND %@ = %@", NSStringFromSelector(@selector(mealType)), mealType];
    NSString *order = [NSStringFromSelector(@selector(autoIncrementId)) stringByAppendingString:@" ASC"];
    
    NSArray *array = [self queryForObjectArrayWhere:where orderBy:order limit:@"0,100"];
    return array;
}

+ (BOOL)rowExistByDateString:(NSString *)dateString {
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(dateString)), dateString];
    return [self rowExist:where];
}

+ (BOOL)isEmpty {
    return ![self rowExist:@"1"];
}

+ (instancetype)firstOne {
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
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
    NSDateComponents *comp = [self getDateComponents:date];
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(year)), @(comp.year)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(month)), @(comp.month)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(day)), @(comp.day)];
    
    return [self sum:key where:where];
}

+ (NSNumber *)sumWeekly:(NSString *)key byDate:(NSDate *)date {
    NSDateComponents *comp = [self getDateComponents:date];
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(year)), @(comp.year)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(month)), @(comp.month)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(weekOfYear)), @(comp.weekOfYear)];
    
    return [self sum:key where:where];
}

+ (NSNumber *)sumMonthly:(NSString *)key byDate:(NSDate *)date {
    NSDateComponents *comp = [self getDateComponents:date];
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(year)), @(comp.year)];
    where  = [where stringByAppendingFormat:@" AND %@ = '%@'", NSStringFromSelector(@selector(month)), @(comp.month)];
    
    return [self sum:key where:where];
}

+ (NSArray *)queryListAll {
    NSUInteger userId = 9527;
    NSString *where = [NSStringFromSelector(@selector(userId)) stringByAppendingFormat:@" = %@", @(userId)];
    NSString *order = [NSString stringWithFormat:@"%@ DESC", NSStringFromSelector(@selector(year))];
    order = [order stringByAppendingFormat:@", %@ DESC", NSStringFromSelector(@selector(month))];
    order = [order stringByAppendingFormat:@", %@ DESC", NSStringFromSelector(@selector(day))];
    
    NSArray *array = [self queryForObjectArrayWhere:where orderBy:order limit:@"0,1000"];
    return array;
}

#pragma mark ---- getter
- (NSUInteger)year {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp/1000];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    return [components year];
}

- (NSUInteger)month {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp/1000];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    return [components month];
}

- (NSUInteger)day {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp/1000];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    return [components day];
}

- (NSUInteger)weekOfYear {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp/1000];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear fromDate:date];

    return [components weekOfYear];
}

- (NSString *)dateString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp/1000];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    NSString *format = @"yyyy-MM-dd";
    [dateFormat setDateFormat:format];
    NSString* string=[dateFormat stringFromDate:date];
    return string;
}

- (NSString *)timeString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timestamp/1000];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    NSString *format = @"HH:mm:ss";
    [dateFormat setDateFormat:format];
    NSString* string=[dateFormat stringFromDate:date];
    return string;
}

#pragma mark ---- description
- (NSString *)description {
    NSMutableString *desc = [NSStringFromClass([self class]) stringByAppendingString:@": {\n"].mutableCopy;
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i = 0 ; i < count ; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [desc appendString:[NSString stringWithFormat:@"    %@: %@,\n", strName, value]];
    }
    free(ivar);
    
    ivar = class_copyIvarList(class_getSuperclass([self class]), &count);
    for (int i = 0 ; i < count ; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [desc appendString:[NSString stringWithFormat:@"    %@: %@,\n", strName, value]];
    }
    free(ivar);
    
    [desc appendString:@"}"];
    return desc;
}

+ (NSDateComponents *)getDateComponents:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitQuarter | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear | NSCalendarUnitNanosecond | NSCalendarUnitCalendar | NSCalendarUnitTimeZone;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    return comps;
}

@end
