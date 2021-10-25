//
//  FoodNutritionModel.h
//  Elink
//
//  Created by LarryZhang on 2021/10/18.
//  Copyright © 2021 iot_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodNutritionModel : NSObject

@property (nonatomic, strong) NSNumber *energy; //    "energy": "387.0",//卡路里(Kcal)

@property (nonatomic, strong) NSNumber *protein; //    "protein": "23.37",//蛋白(毫克)

@property (nonatomic, strong) NSNumber *fat; //    "fat": "30.6",//脂肪(毫克)
@property (nonatomic, strong) NSNumber *cholesterol; //    "cholesterol": "103.0",//胆固醇

@property (nonatomic, strong) NSNumber *carbohydrate; //    "carbohydrate": "4.78",//碳水(毫克)
@property (nonatomic, strong) NSNumber *fiber; //    "fiber": "0.0",//纤维(毫克)

@property (nonatomic, strong) NSNumber *k; //    "k": "95.0",//钾(毫克)
@property (nonatomic, strong) NSNumber *na; //    "na": "700.0",//钠(毫克)
@property (nonatomic, strong) NSNumber *ca; //    "ca": "643.0",//钙(毫克)
@property (nonatomic, strong) NSNumber *mg; //    "mg": "21.0",//镁(毫克)
@property (nonatomic, strong) NSNumber *fe; //    "fe": "0.21",//铁(毫克)
@property (nonatomic, strong) NSNumber *mn; //    "mn": "0.012",//锰(毫克)
@property (nonatomic, strong) NSNumber *zn; //    "zn": "2.79",//锌(毫克)
@property (nonatomic, strong) NSNumber *cu; //    "cu": "0.042",//铜(毫克)
@property (nonatomic, strong) NSNumber *p; //    "p": "464.0",//磷(微克)
@property (nonatomic, strong) NSNumber *se; //    "se": "14.5",//硒(毫克)

@property (nonatomic, strong) NSNumber *va; //    "va": "233",//维生素A(毫克)
@property (nonatomic, strong) NSNumber *vb2; //    "vb2": "0.074",//维生素B2(毫克)
@property (nonatomic, strong) NSNumber *vc; //    "vc": "0.0",//维生素c(毫克)
@property (nonatomic, strong) NSNumber *ve; //    "ve": "0.0",//维生素E(毫克)
@property (nonatomic, strong) NSNumber *niacin; //    "niacin": "0.08",//烟酸(毫克)

//****下面3项，设计图未体现 参考好营养补全
@property (nonatomic, strong) NSNumber *carotene; //    "carotene": "0.0",//胡萝卜素(微克)
@property (nonatomic, strong) NSNumber *re; //    "re": "220.0",视黄醇当量(微克)
@property (nonatomic, strong) NSNumber *vb1; //    "vb1": "0.83",//维生素B1(毫克)

@end


@interface FoodNutritionModel (util)

//获取单位
+ (NSString *)getUnit:(NSString *)item;

@end

NS_ASSUME_NONNULL_END
