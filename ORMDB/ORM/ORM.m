//
//  ORM.m
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import "ORM.h"
#import "ORMDB.h"
#import "ORMDBAttributes.h"

#import <objc/runtime.h>
#import <objc/message.h>


typedef NS_OPTIONS (NSUInteger ,ORMDBDataType){
   ORMDBDataTypeUnknown,
    ORMDBDataTypeBool,
    ORMDBDataTypeInt,
    ORMDBDataTypeFloat,
    ORMDBDataTypeDouble,
    ORMDBDataTypeClass,
    ORMDBDataTypeString,
    ORMDBDataTypeNumber,
    ORMDBDataTypeArray,
    ORMDBDataTypeDictionary
   
};

ORMDBDataType ORMDBGetDataType(const char *typeEncoding){

    char *type = (char *)typeEncoding;
    if (!type) return ORMDBDataTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return ORMDBDataTypeUnknown;
    switch (*type) {
        case 'B': return ORMDBDataTypeBool;
        case 'c': return ORMDBDataTypeInt;
        case 'C': return ORMDBDataTypeInt;
        case 's': return ORMDBDataTypeInt;
        case 'S': return ORMDBDataTypeInt;
        case 'i': return ORMDBDataTypeInt;
        case 'I': return ORMDBDataTypeInt;
        case 'l': return ORMDBDataTypeInt;
        case 'L': return ORMDBDataTypeInt;
        case 'q': return ORMDBDataTypeInt;
        case 'Q': return ORMDBDataTypeInt;
        case 'f': return ORMDBDataTypeFloat;
        case 'd': return ORMDBDataTypeDouble;
        case 'D': return ORMDBDataTypeDouble;
        default:return  ORMDBDataTypeUnknown;
          
    }
    return ORMDBDataTypeUnknown;
}

@interface ORMDBClassPropertyInfo : NSObject
@property (nonatomic,assign, readonly)objc_property_t property;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) ORMDBDataType type;
@property (nullable, nonatomic, assign, readonly) Class cls;
@property (nullable, nonatomic, strong, readonly) NSString *protocol;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;
@end

@implementation ORMDBClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property{
     if (!property) return nil;
    self = [super init];
    _property=property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
   _type=ORMDBDataTypeUnknown;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
         switch (attrs[i].name[0]) {
            case 'T':{
                _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                if (attrs[i].value) {
                    _type=ORMDBGetDataType(attrs[i].value);
                   
                    if(_type==ORMDBDataTypeUnknown){
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) {
                                _cls = objc_getClass(clsName.UTF8String);
                                if ([clsName compare:@"NSString"]==NSOrderedSame) {
                                    _type=ORMDBDataTypeString;
                                }else if([clsName compare:@"NSNumber"]==NSOrderedSame){
                                    _type=ORMDBDataTypeNumber;
                                }else if([clsName compare:@"NSArray"]==NSOrderedSame||[clsName compare:@"NSMutableArray"]==NSOrderedSame){
                                    _type=ORMDBDataTypeArray;
                                }
//                                else if([clsName compare:@"NSDictionary"]==NSOrderedSame||[clsName compare:@"NSMutableDictionary"]==NSOrderedSame){
//                                    _type=ORMDBDataTypeDictionary;
//                                }
                            };
                        }
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                _protocol=protocol;
                                break;
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }

                    }
                        
                }
            }
            break;
                
             
                
        }
    
    }
    
    return self;
}

@end

@interface ORMDBClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, strong, readonly) NSString *name;
@property (nullable, nonatomic, strong, readonly) NSMutableDictionary<NSString *, ORMDBClassPropertyInfo *> *propertyInfos;
@end
@implementation ORMDBClassInfo
- (instancetype)initWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        if (properties) {
            NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
            _propertyInfos = propertyInfos;
            
            for (unsigned int i = 0; i < propertyCount; i++) {
                ORMDBClassPropertyInfo *property=[[ORMDBClassPropertyInfo alloc] initWithProperty:properties[i]];
                if(property.name) _propertyInfos[property.name]=property;
            }
            free(properties);
          
        }
    }
    return self;
}
+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    ORMDBClassInfo *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!meta) {
        meta = [[ORMDBClassInfo alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}


@end
@implementation ORM
- (void)test:(Class )cls{
   ORMDBClassInfo *obj= [ORMDBClassInfo metaWithClass:cls];
    [ORMDBClassInfo metaWithClass:cls];
    NSLog(@"obj.name:%@",obj.name);
    for (NSString *key in obj.propertyInfos) {
        ORMDBClassPropertyInfo *info=obj.propertyInfos[key];
        NSLog(@" name: %@ cls: %@ dbtype:%li,protocol:%@", info.name,info.cls,info.type,info.protocol);
    }
}
+ (void)createTableFromClass:(Class) cls{
    
    NSMutableArray *arr=[ORM parseClass:cls];
    NSString *sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",cls];
    for (int i=0; i<arr.count; i++) {
        ORMDBAttributes *att=arr[i];
        if (att.propertyDataType==DBDataTypeNumber||att.propertyDataType==DBDataTypeInt) {
            sql=[NSString stringWithFormat:@"%@ %@ integer ,",sql,att.propertyName];
        }else if (att.propertyDataType==DBDataTypeFloat) {
            sql=[NSString stringWithFormat:@"%@ %@ float ,",sql,att.propertyName];
        }else if (att.propertyDataType==DBDataTypeDouble) {
            sql=[NSString stringWithFormat:@"%@ %@ double ,",sql,att.propertyName];
        }else if (att.propertyDataType==DBDataTypeString) {
            sql=[NSString stringWithFormat:@"%@ %@ TEXT  DEFAULT NULL ,",sql,att.propertyName];
        }
    }
    if ([sql hasSuffix:@","]) {
        if (sql.length-1>0) {
            sql=[sql substringToIndex:sql.length-1];
        }
    }
    sql=[NSString stringWithFormat:@"%@ %@",sql,@" );"];
    
    for (int i=0; i<arr.count; i++) {
        ORMDBAttributes *att=arr[i];
        if (att.propertyDataType==DBDataTypeClass||att.propertyDataType==DBDataTypeArray) {
            
             [ORM createTableFromClass:NSClassFromString(att.classProperty)];
            
        }
    }
    [ORMDB beginTransaction];
    [ORMDB  execsql:sql];
    [ORMDB commitTransaction];
   
}
+ (void)saveEntity:(id)entity with:(NSArray *)keys{
    if (!entity) {
        return;
    }
   
    if (keys&&keys.count>0) {
        NSString *deletesql=[NSString stringWithFormat:@"DELETE FROM %@ %@",
                             [entity class],
                             [ORM createWhereStatement:entity andKeys:keys]];
        [ORMDB execsql:deletesql];
    }
    
    NSMutableArray *arr=[ORM parseClass:[entity class]];
    NSMutableString *sql=[[NSMutableString alloc] initWithFormat:@"INSERT INTO  %@   (",[entity class]];
    for (int i=0; i<arr.count; i++) {
        ORMDBAttributes *att=arr[i];
        if (att.propertyDataType!=DBDataTypeClass&&att.propertyDataType!=DBDataTypeArray) {
             [sql appendFormat:@"%@ ,",att.propertyName];
         }
    }
    
        if (sql.length-1>0) {
            [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
            [sql appendString:@")"];
        }
    
    [sql appendString:@" VALUES ("];
    for (int i=0; i<arr.count; i++) {
        ORMDBAttributes *att=arr[i];
        if (att.propertyDataType!=DBDataTypeClass&&att.propertyDataType!=DBDataTypeArray) {
            [sql appendString:@"?,"];
        }
     }
   
    if (sql.length-1>0) {
        [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
        [sql appendString:@")"];
    }
    [sql appendString:@" ;"];
    [ORMDB saveObject:entity withSql:sql];
 
    for (int i=0; i<arr.count; i++) {
        ORMDBAttributes *att=arr[i];
        if (att.propertyDataType==DBDataTypeClass||att.propertyDataType==DBDataTypeArray) {
            NSMethodSignature  *signature = [entity methodSignatureForSelector:NSSelectorFromString(att.propertyName)];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:entity];
            [invocation setSelector:NSSelectorFromString(att.propertyName)];
            [invocation invoke];
            void *vres=nil;
            [invocation getReturnValue:&vres];
           id res=(__bridge id )vres;
            if(res){
                if ([res isKindOfClass:[NSArray class]]||[res isKindOfClass:[NSMutableArray class]]) {
                    NSArray *arr=(NSArray *)res;
                    for (int i=0; i<arr.count; i++) {
                        id obj=arr[i];
                        [ORM saveClassPropertyValue:obj andPropertyName:att.classProperty andParentEntity:entity delete:i==0];
                    }
                }else{
                       [ORM saveClassPropertyValue:res andPropertyName:att.classProperty andParentEntity:entity delete:YES];
                }
            }
        }
    }
}
+ (void)saveClassPropertyValue:(id)res andPropertyName:(NSString *)classProperty andParentEntity:(id)entity delete:(BOOL)delete{
    SEL foreignSelector=NSSelectorFromString(@"foreignKey");
    Class fcls= NSClassFromString(classProperty);
    NSMethodSignature  *foreignSignature = [[fcls class] methodSignatureForSelector:foreignSelector];
    if (foreignSignature) {
        NSInvocation *foreignInvocation = [NSInvocation invocationWithMethodSignature:foreignSignature];
        [foreignInvocation setTarget:[fcls class]];
        [foreignInvocation setSelector:foreignSelector];
        [foreignInvocation invoke];
        id  forRes=nil;
        [foreignInvocation getReturnValue:&forRes];
        
        NSMethodSignature  *signature = [[entity class] methodSignatureForSelector:NSSelectorFromString(@"primarilyKey")];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:[entity class]];
        [invocation setSelector:NSSelectorFromString(@"primarilyKey")];
        [invocation invoke];
        id pres=nil;
        [invocation getReturnValue:&pres];
        
        NSMethodSignature  *pvsignature = [entity  methodSignatureForSelector:NSSelectorFromString(pres)];
        NSInvocation *pinvocation = [NSInvocation invocationWithMethodSignature:pvsignature];
        [pinvocation setTarget:entity];
        [pinvocation setSelector:NSSelectorFromString(pres)];
        [pinvocation invoke];
        id pv=nil;
        [pinvocation getReturnValue:&pv];
        NSString* ucfirstName = [forRes stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                withString:[[forRes substringToIndex:1] uppercaseString]];
        NSString* selectorName = [NSString stringWithFormat:@"set%@:", ucfirstName];
        SEL fvSelector = NSSelectorFromString(selectorName);
        
        NSMethodSignature  *fSignaturevalue = [res methodSignatureForSelector:fvSelector];
        NSInvocation *fInvocation = [NSInvocation invocationWithMethodSignature:fSignaturevalue];
        [fInvocation setTarget:res];
        [fInvocation setSelector:fvSelector];
        [fInvocation setArgument:&pv atIndex:2];
        [fInvocation invoke];
        if (delete) {
            [ORM saveEntity:res with:@[forRes]];
        }else{
          [ORM saveEntity:res with:nil];
        }
    }else{
        NSLog(@"===class :%@ +(NSString *)foreignKey ",res);
    }
}
+ (id)get:(Class)cls withKeys:(NSArray *)keys andValues:(NSArray *)values{
    if (keys||values) {
        if (keys.count!=values.count) {
            return nil;
        }
    }
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM  %@ %@",cls,[ORM createWherStateWith:keys andValues:values]];
   
    NSMutableArray *arr=[ORMDB queryDB:cls andSql:sql];
    if (arr.count>0) {
        return arr[0];
    }
    
    return  nil;
}
+ (void)deleteObject:(Class)cls withKeys:(NSArray *)keys andValues:(NSArray *)values{
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM  %@ %@",cls,[ORM createWherStateWith:keys andValues:values]];
    [ORMDB beginTransaction];
    [ORMDB execsql:sql];
    [ORMDB commitTransaction];
}
+ (NSMutableArray *)list:(Class)cls withKeys:(NSArray *)keys andValues:(NSArray *)values{
    if (keys||values) {
        if (keys.count!=values.count) {
            return nil;
        }
    }
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM  %@ %@",cls,[ORM createWherStateWith:keys andValues:values]];
    
    NSMutableArray *arr=[ORMDB queryDB:cls andSql:sql];
   
    return  arr;
}
+(NSString *)createWherStateWith:(NSArray *)key andValues:(NSArray *)value{
    NSString *whereSql=@"";
    for (int i=0; i<key.count; i++) {
        NSString *type=[NSString stringWithFormat:@"%@",[value[i] class]];
        
        if (i==0) {
            if ([type hasSuffix:@"NSCFNumber"]||[type hasSuffix:@"NSCFBoolean"]) {
                if ([type hasSuffix:@"NSCFNumber"]) {
                    NSNumber *number=value[i];
                    if(CFNumberIsFloatType((CFNumberRef)number))
                    {
                        whereSql=[NSString stringWithFormat:@"WHERE %@ = %@ ",key[i],value[i]];
                    }else{
                        whereSql=[NSString stringWithFormat:@"WHERE %@ = %i ",key[i],[value[i] intValue]];
                    }
                }else{
                    whereSql=[NSString stringWithFormat:@"WHERE %@ = %i ",key[i],[value[i] intValue]];
                }
            }else{
                whereSql=[NSString stringWithFormat:@"WHERE %@ = '%@' ",key[i],value[i]];
            }
        }else{
            if ([type hasSuffix:@"NSCFNumber"]||[type hasSuffix:@"NSCFBoolean"]) {
                if ([type hasSuffix:@"NSCFNumber"]) {
                    NSNumber *number=value[i];
                    if(CFNumberIsFloatType((CFNumberRef)number)){
                        whereSql=[NSString stringWithFormat:@"%@ AND  %@ = %@  ",whereSql,key[i],value[i]];
                    }else{
                        whereSql=[NSString stringWithFormat:@"%@ AND  %@ = %i  ",whereSql,key[i],[value[i] intValue]];
                    }
                    
                }else{
                    whereSql=[NSString stringWithFormat:@"%@ AND  %@ = %i  ",whereSql,key[i],[value[i] intValue]];
                }
            }else{
                whereSql=[NSString stringWithFormat:@"%@ AND  %@ = '%@'  ",whereSql,key[i],value[i]];
            }
            
        }
    }
    return whereSql;
    
}
+(NSString *)createWhereStatement:(id)entity andKeys:(NSArray *)keys{
    if (!keys||keys.count==0) {
        return @"";
    }
    NSString *whereSql=@"";
    for (int i=0; i<keys.count; i++) {
        NSString *method=keys[i];
        NSMethodSignature  *signature = [entity methodSignatureForSelector:NSSelectorFromString(method)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:entity];
        [invocation setSelector:NSSelectorFromString(keys[i])];
        [invocation invoke];
        id objvalue=nil;
        [invocation getReturnValue:&objvalue];
        NSString *type=[NSString stringWithFormat:@"%@",[objvalue class]];
        
        if (i==0) {
            if ([type hasSuffix:@"NSCFNumber"]||[type hasSuffix:@"NSCFBoolean"]||[type compare:@"(null)"]==NSOrderedSame) {
                whereSql=[NSString stringWithFormat:@"WHERE %@ = %i ",keys[i],[[entity valueForKey:keys[i]] intValue]];
            }else{
                whereSql=[NSString stringWithFormat:@"WHERE %@ = '%@' ",keys[i],[entity valueForKey:keys[i]]];
            }
        }else{
            if ([type hasSuffix:@"NSCFNumber"]||[type hasSuffix:@"NSCFBoolean"]||[type compare:@"(null)"]==NSOrderedSame) {
                whereSql=[NSString stringWithFormat:@"%@ AND  %@ = %i  ",whereSql,keys[i],[[entity valueForKey:keys[i]] intValue]];
            }else{
                whereSql=[NSString stringWithFormat:@"%@ AND  %@ = '%@'  ",whereSql,keys[i],[entity valueForKey:keys[i]]];
            }
        }
    }
    whereSql=[NSString stringWithFormat:@"%@ ;",whereSql];
    return whereSql;
}
+ (NSMutableArray *)parseClass:(Class)cls{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(cls,&propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        const char *attrs = property_getAttributes(property);
        ORMDBAttributes *att=[[ORMDBAttributes alloc] init];
        att.propertyName=@(propertyName);
        att.propertyAttributes=@(attrs);
        if ([att.propertyAttributes rangeOfString:@"NSNumber"].location!=NSNotFound) {
            att.propertyDataType=DBDataTypeNumber;
        }else if ([att.propertyAttributes rangeOfString:@"NSString"].location!=NSNotFound) {
            att.propertyDataType=DBDataTypeString;
        }else if ([att.propertyAttributes hasPrefix:@"Ti,"]||[att.propertyAttributes hasPrefix:@"TB,"]||[att.propertyAttributes hasPrefix:@"Tq,"]){
           att.propertyDataType=DBDataTypeInt;
        }else if ([att.propertyAttributes hasPrefix:@"Tf,"]){
            att.propertyDataType=DBDataTypeFloat;
        }else if ([att.propertyAttributes hasPrefix:@"Td,"]){
            att.propertyDataType=DBDataTypeDouble;
        }else if([att.propertyAttributes rangeOfString:@"NSArray"].location!=NSNotFound){
            att.propertyDataType=DBDataTypeArray;
            NSString *a=@(attrs);
            NSRange range=[a rangeOfString:@">\","];
            att.classProperty=[a substringWithRange:NSMakeRange(11, range.location-11)];
        }else{
           att.propertyDataType=DBDataTypeClass;
            NSString *a=@(attrs);
            NSRange range=[a rangeOfString:@"\","];
            att.classProperty=[a substringWithRange:NSMakeRange(3, range.location-3)];
           
        }
        [arr addObject:att];
    }
    return arr;
}
@end
