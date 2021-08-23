//
//  main.m
//  ORM
//
//  Created by PengLinmao on 16/11/22.
//  Copyright © 2016年 PengLinmao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClassInfo.h"
#import "NewOjb.h"
#import "NewOjbSubInfo.h"

#import "NSObject+ORM.h"
#import "Test.h"
#import "StudentTest2.h"
#import "ORMDB.h"

double t(double last, char *key) {
    clock_t now = clock();
    printf("time:%fs \t key:%s \n", (last != 0) ? (double) (now - last) / CLOCKS_PER_SEC : 0, key);
    return now;
}


void testClossInof() {
    ClassInfo *classInfo = [[ClassInfo alloc] init];
    classInfo.className = @"三班";
    classInfo.roomId = 120;
    classInfo.classNumber = @(5);
    classInfo.id = 9;
    classInfo.classAddress = @"北京市海淀区";
    classInfo.dataInfo = @{@"a": @"aa", @"b": @"bb", @"c": @"cc", @"d": @"dd"};
    classInfo.addOne = 11;
    classInfo.addTwo = 22;
    classInfo.add5 = 0x44;


    Student *one = [[Student alloc] init];
    one.name = @"小红";
    one.age = 15;
    one.sid = 100;

    Student *two = [[Student alloc] init];
    two.name = @"小民";
    two.age = 18;
    two.sid = 102;

    Teacher *teacher = [[Teacher alloc] init];
    teacher.name = @"班主任";

    classInfo.student = @[one, two].copy;
    classInfo.teacher = teacher;
//        classInfo.version = 111;

    [classInfo save:@[NSStringFromSelector(@selector(classNumber))]];
}

void createNewOjbDB() {
#if 0 //异步 每个对象保存
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_queue_create("abc", DISPATCH_QUEUE_SERIAL), ^{
            
            NewOjb *n1=[[NewOjb alloc] init];
            n1.id = @(i + 100);
            n1.nid = i + 100;
            n1.num=@(i+100);
            n1.str=[@"n1.str" stringByAppendingFormat:@"%04x", i];
            n1.name=[@"n1.name" stringByAppendingFormat:@"%04x", i];
            n1.age=@(i+1);
            n1.address=[@"n1.address" stringByAppendingFormat:@"%08x", i];
            n1.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
            n1.timestampios = [[NSDate date] timeIntervalSince1970];
            
            NewOjbSubInfo * subInfo1 = [NewOjbSubInfo new];
            subInfo1.id = n1.id;
            subInfo1.nid = n1.nid;
            subInfo1.sid = n1.id.intValue;
            subInfo1.title = [@"subInfo1.title" stringByAppendingFormat:@"%08x", i];
            subInfo1.content=[@"subInfo1.content" stringByAppendingFormat:@"%08x", i];
            NewOjbSubInfo * subInfo2 = [NewOjbSubInfo new];
            subInfo2.id = n1.id;
            subInfo2.nid = n1.nid;
            subInfo2.sid = n1.id.intValue + 100;
            subInfo2.title = [@"subInfo2.title" stringByAppendingFormat:@"%08x", i];
            subInfo2.content=[@"subInfo2.content" stringByAppendingFormat:@"%08x", i];
            n1.subInfo = @[subInfo1, subInfo2].copy;
            [n1 save:@[NSStringFromSelector(@selector(num))]];
            
            NewOjb *n2=[[NewOjb alloc] init];
            n2.id = @(i);
            n2.nid = i;
            n2.num=@(i);
            n2.str=[@"n2.str" stringByAppendingFormat:@"%04x", i];
            n2.name=[@"n2.name" stringByAppendingFormat:@"%04x", i];
            n2.age=@(i+2);
            n2.address=[@"n2.address" stringByAppendingFormat:@"%08x", i];
            n2.remark = @"n2 remark";
            n2.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
            n2.timestampios = [[NSDate date] timeIntervalSince1970];
            [n2 save:@[NSStringFromSelector(@selector(num))]];

        });
    }
    sleep(10);
#else //数组保存
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<10; i++) {
        NewOjb *n1=[[NewOjb alloc] init];
        n1.id = @(i + 100);
        n1.nid = i + 100;
        n1.num=@(i+100);
        n1.str=[@"n1.str" stringByAppendingFormat:@"%04x", i];
        n1.name=[@"n1.name" stringByAppendingFormat:@"%04x", i];
        n1.age=@(i+1);
        n1.address=[@"n1.address" stringByAppendingFormat:@"%08x", i];
        n1.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
        n1.timestampios = [[NSDate date] timeIntervalSince1970];
        
        NewOjbSubInfo * subInfo1 = [NewOjbSubInfo new];
        subInfo1.id = n1.id;
        subInfo1.nid = n1.nid;
        subInfo1.sid = n1.id.intValue;
        subInfo1.title = [@"subInfo1.title" stringByAppendingFormat:@"%08x", i];
        subInfo1.content=[@"subInfo1.content" stringByAppendingFormat:@"%08x", i];
        NewOjbSubInfo * subInfo2 = [NewOjbSubInfo new];
        subInfo2.id = n1.id;
        subInfo2.nid = n1.nid;
        subInfo2.sid = n1.id.intValue + 100;
        subInfo2.title = [@"subInfo2.title" stringByAppendingFormat:@"%08x", i];
        subInfo2.content=[@"subInfo2.content" stringByAppendingFormat:@"%08x", i];
        n1.subInfo = @[subInfo1, subInfo2].copy;
        [arr addObject:n1];

        NewOjb *n2=[[NewOjb alloc] init];
        n2.id = @(i);
        n2.nid = i;
        n2.num=@(i);
        n2.str=[@"n2.str" stringByAppendingFormat:@"%04x", i];
        n2.name=[@"n2.name" stringByAppendingFormat:@"%04x", i];
        n2.age=@(i+2);
        n2.address=[@"n2.address" stringByAppendingFormat:@"%08x", i];
        n2.remark = @"n2 remark";
        n2.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
        n2.timestampios = [[NSDate date] timeIntervalSince1970];
        [arr addObject:n2];
    
        [arr saveListDataWithKeys:@[NSStringFromSelector(@selector(num))]];
    }
#endif
}

void testNewOjbDB() {
    NSArray * arr = [ORMDB queryDB:[NewOjb class] andSql:@"select * from NewOjb"];
    NSLog(@"arr: %@", arr);
    
    NewOjb *newobj = [NewOjb getObject:@[NSStringFromSelector(@selector(num))] withValue:@[@(103)]];
    NSLog(@"newobj: %@", newobj);
    
    NewOjb *newobj1 = [NewOjb getObject:@[NSStringFromSelector(@selector(num)), NSStringFromSelector(@selector(remark))] withValue:@[@(103), @"n2 remark"]];
    NSLog(@"newobj1: %@", newobj1);
    
    NewOjb *newobj2 = [NewOjb getObject:@[NSStringFromSelector(@selector(num)), NSStringFromSelector(@selector(remark))] withValue:@[@(3), @"n2 remark"]];
    NSLog(@"newobj2: %@", newobj2);
    
    NSArray *arr2 = [NewOjb list:@[NSStringFromSelector(@selector(remark))] withValue:@[@"n2 remark"]];
    NSLog(@"arr2: %@", arr2);
    
    NSArray *arr3 = [NewOjb list:@[NSStringFromSelector(@selector(num)), NSStringFromSelector(@selector(remark))] withValue:@[@(103), @"n2 remark"]];
    NSLog(@"arr3: %@", arr3);
    
//        [NewOjb clearTable:@[NSStringFromSelector(@selector(remark))] withValue:@[@"n2 remark"]];
//        [NewOjb deleteObject:@[NSStringFromSelector(@selector(num))] withValue:@[@(103)]];
    
    //@"SELECT num,str,age,name,address,remark,timestamp,timestampios FROM  NewOjb WHERE num = 103 "
    //@"SELECT * FROM NewOjb WHERE remark != NULL"
    NSString *sql = [@"SELECT * FROM " stringByAppendingFormat:@"%@ WHERE remark != ''", NSStringFromClass([NewOjb class])];
    NSArray *array = [NewOjb queryForObjectArray:sql];
    NSLog(@"array: %@", array);
    
    NSString *sql1 = @"remark != ''";
    NSArray *array1 = [NewOjb queryForObjectArrayWhere:sql1];
    NSLog(@"array1: %@", array1);
    
    NSString *sql2 = @"id != ''";
    NSArray *array2 = [NewOjb queryForObjectArrayWhere:sql2 orderBy:@"age asc, id desc"];
    NSLog(@"array2: %@", array2);
    
    NSDictionary *dic = [NewOjb queryForDictionary:sql];
    NSLog(@"dic: %@", dic);
    
    NSDictionary *dic1 = [NewOjb queryForDictionaryWhere:sql1];
    NSLog(@"dic1: %@", dic1);
    
    BOOL result = [NewOjb rowExist:@"id = 100"];
    NSLog(@"result: %@", @(result));
    
    NSLog(@"");
}

int main(int argc, const char *argv[]) {
@autoreleasepool {

    [ORMDB configDBPath:@"/Users/Shared/test.db"];

    dispatch_queue_t dispatchQueue = dispatch_queue_create("com.queue.test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t dispatchGroup = dispatch_group_create();

    //成员变量自动创建table
//    testClossInof();


#if 0 //创建
    createNewOjbDB();
#else //查询
    testNewOjbDB();
#endif

//        [Test createTable];
//    for(int i=0;i<20;i++){
//        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
//            ClassInfo *classInfo=[[ClassInfo alloc] init];
//            classInfo.className=@"三班";
//            classInfo.roomId=120;
//            classInfo.classNumber=@(1);
//            //classInfo.classAddress=@"北京市海淀区";
//            classInfo.dataInfo=@{@"a":@"b",@"c":@"d"};
//
//
//            Student *one=[[Student alloc] init];
//            one.name=@"小红";
//            one.age=15;
//            one.sid=100;
//
//            Student *two=[[Student alloc] init];
//            two.name=@"小民";
//            two.age=18;
//            two.sid=102;
//
//            Teacher *teacher=[[Teacher alloc] init];
//            teacher.name=@"班主任";
//
//            classInfo.student=@[one,two].copy;
//            classInfo.teacher=teacher;
//
//            [classInfo save:@[@"classNumber"]];
//
//
//            Test *test=[[Test alloc] init];
//            test.one=295;
//
//
//            StudentTest2 *t2=[[StudentTest2 alloc] init];
//            t2.age=10;
//            t2.sid=210;
//            t2.name=@"明2";
//            test.test=t2;
//
//            [test save:@[@"one"]];
//
//            [Test getObject:nil withValue:nil];
//
//
//          NSMutableDictionary *resultDic = [Test queryForDictionary:@"Select * from Test"];
//
//            NSMutableArray *resultArray = [Test queryForObjectArray:@"Select * from Test"];
//
//            [Test execSql:^(SqlOperationQueueObject *db) {
//                [db execDelete:@"delte from Test"];//删除sql语句
//                [db execUpdate:@"update Test set xxx=x where xxx=x "];//upate sql语句
//               BOOL result = [db rowExist:@"select * from Test where xxx=x"];
//            }];
//
//            [ORMDB queryWithSql:@"Select * from Test"];
//          NSArray *arr= [ORMDB queryDB:[NewOjb class] andSql:@"select * from NewOjb"];
//
//            [Test clearTable:@[@"key1",@[@"key2"]] withValue:@[@"value1",@"value2"]];
//        });
//    }
//
//        NSArray *arr= [ORMDB queryDB:[NewOjb class] andSql:@"SELECT * FROM NewOjb"];
//        NSLog(@"arr.count:%@",arr);

//        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
//            NSLog(@"=3333===");
//            NewOjb *n1=[[NewOjb alloc] init];
//            n1.aaa=@(1);
//            n1.bbb=@"ccc";
//            [n1 save:@[@"aaa"]];
//            
//            NewOjb *n2=[[NewOjb alloc] init];
//            n2.aaa=@(1);
//            n2.bbb=@"ddd";
//            [n2 save:@[@"aaa"]];
//        });


//          sleep(10);
    }
    return 0;
}
