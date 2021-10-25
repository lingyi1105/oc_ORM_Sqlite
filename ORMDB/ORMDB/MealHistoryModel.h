//
//  MealHistoryModel.h
//  Elink
//
//  Created by LarryZhang on 2021/10/11.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import "FoodNutritionModel.h"
#import "ORM.h"

NS_ASSUME_NONNULL_BEGIN

@class ELBNFSFoodModel;
@interface MealHistoryModel : FoodNutritionModel

@property (nonatomic, strong) NSNumber *autoIncrementId; //主键 自增 //ORMDB保留字段


@property (nonatomic, assign) NSUInteger subUserId;  //当前子用户id

@property (nonatomic, assign) NSUInteger year; //时间
@property (nonatomic, assign) NSUInteger month; //时间
@property (nonatomic, assign) NSUInteger day; //时间
@property (nonatomic, assign) NSUInteger weekOfYear; //时间

@property (nonatomic, copy) NSString *dateString; //日期 yyyy/MM/dd

@property (nonatomic, strong) NSNumber *mealType;  //0:早餐 1:午餐 2:晚餐 3:其他


@property (nonatomic, assign) long long massValueMilligram; //    食物重量质量(毫克单位)

@property (nonatomic, copy) NSString *name; //    "name": "Cheese, cheshire",//食品名称




@end


@interface MealHistoryModel (sqlite)

- (instancetype)save;

- (void)remove;

- (instancetype)update;

+ (NSArray *)queryListByDateString:(NSString *)dateString andMmealType:(NSNumber *)mealType;

+ (BOOL)rowExistByDateString:(NSString *)dateString;

+ (BOOL)isEmpty;

+ (NSNumber *)sumDaily:(NSString *)key byDate:(NSDate *)date;
+ (NSNumber *)sumWeekly:(NSString *)key byDate:(NSDate *)date;
+ (NSNumber *)sumMonthly:(NSString *)key byDate:(NSDate *)date;

+ (NSArray *)queryListAll;

+ (instancetype)firstOne;

@end

NS_ASSUME_NONNULL_END
