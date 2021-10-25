//
//  FoodNutritionModel.m
//  Elink
//
//  Created by LarryZhang on 2021/10/18.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import "FoodNutritionModel.h"
#import <objc/runtime.h>

@implementation FoodNutritionModel


//获取单位
+ (NSString *)getUnit:(NSString *)item {
    NSDictionary *dic = @{
        NSStringFromSelector(@selector(energy)):        @"kcal",//卡路里(Kcal)
        
        NSStringFromSelector(@selector(protein)):       @"g",//蛋白(克)

        NSStringFromSelector(@selector(fat)):           @"g",//脂肪(克)
        NSStringFromSelector(@selector(cholesterol)):   @"mg",//胆固醇

        NSStringFromSelector(@selector(carbohydrate)):  @"g",//碳水(克)
        NSStringFromSelector(@selector(fiber)):         @"g",//纤维(克)

        NSStringFromSelector(@selector(k)):             @"mg",//钾(毫克)
        NSStringFromSelector(@selector(na)):            @"mg",//钠(毫克)
        NSStringFromSelector(@selector(ca)):            @"mg",//钙(毫克)
        NSStringFromSelector(@selector(mg)):            @"mg",//镁(毫克)
        NSStringFromSelector(@selector(fe)):            @"mg",//铁(毫克)
        NSStringFromSelector(@selector(mn)):            @"mg",//锰(毫克)
        NSStringFromSelector(@selector(zn)):            @"mg",//锌(毫克)
        NSStringFromSelector(@selector(cu)):            @"mg",//铜(毫克)
        NSStringFromSelector(@selector(p)):             @"mg",//磷(毫克)
        NSStringFromSelector(@selector(se)):            @"μg",//硒(微克)

        NSStringFromSelector(@selector(va)):            @"μg",//维生素A(微克)
        NSStringFromSelector(@selector(vb2)):           @"mg",//维生素B2(毫克)
        NSStringFromSelector(@selector(vc)):            @"mg",//维生素c(毫克)
        NSStringFromSelector(@selector(ve)):            @"mg",//维生素E(毫克)
        NSStringFromSelector(@selector(niacin)):        @"mg",//烟酸(毫克)
        
        NSStringFromSelector(@selector(carotene)):      @"μg",//胡萝卜素(微克)
        NSStringFromSelector(@selector(re)):            @"μg",//视黄醇(微克)
        NSStringFromSelector(@selector(vb1)):           @"mg",//维生素B1(毫克)
    };
    
    return dic[item];
}

#pragma mark ---- copyWithZone
- (id)copyWithZone:(NSZone *)zone {
    FoodNutritionModel *model = [FoodNutritionModel allocWithZone:zone];
    
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i= 0 ;i < count ; i++) {
        Ivar var = ivar[i];
        const char *keyName = ivar_getName(var);
        NSString *key = [NSString stringWithUTF8String:keyName];
        id value = [self valueForKey:key];
        [model setValue:value forKey:key];
    }
    free(ivar);
    
    return model;
}

#pragma mark ---- encodeWithCoder
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i = 0 ; i < count ; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivar);
}

#pragma mark ---- initWithCoder
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        unsigned int count = 0;
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i= 0 ;i < count ; i++) {
            Ivar var = ivar[i];
            const char *keyName = ivar_getName(var);
            NSString *key = [NSString stringWithUTF8String:keyName];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivar);
    }
    return self;
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
    
    [desc appendString:@"}"];
    return desc;
}

- (NSString *)debugDescription {
    return [self description];
}

@end
