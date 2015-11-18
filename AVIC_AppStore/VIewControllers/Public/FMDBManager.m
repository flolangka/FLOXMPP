//
//  FMDBManager.m
//  AVIC_AppStore
//
//  Created by @HUI on 15-1-3.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "FMDBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@implementation FMDBManager

static FMDBManager*manager=nil;
+(id)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[FMDBManager alloc]init];
    });
    
    return manager;
}
-(id)initWithTableName:(NSString *)tableName{
    
    if (self=[super init]) {
        _tableName=tableName;
        //创建数据库，打开或创建表格
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //创建数据库
        database=[[FMDatabase alloc]initWithPath:dbPath];
        if([database open]){
            if(![database tableExists:tableName]){
                //创建表 User
                [database executeUpdate:[NSString stringWithFormat:@"create table '%@' (appId,appName,appDetail,appIcon,version,liftId,pluginUrl)",tableName]];
            }else{
                
            }
        }else{
            MyLog(@"数据库打开失败");
        }

    }
    
    return self;
    
}
-(void)deleteApp:(NSDictionary*)dic{
    FMResultSet*result=[database executeQuery:[NSString stringWithFormat:@"select * from '%@' where appId='%@'",_tableName,dic[@"appid"]]];
    if(result.columnCount!=0){
        BOOL delete=[database executeUpdate:[NSString stringWithFormat:@"delete from '%@' where appId='%@'",_tableName,dic[@"appid"]]];
        if(delete){
            MyLog(@"删除成功");
        }else{
            MyLog(@"删除失败");
        }
    }
}
-(BOOL)saveModel:(NSDictionary *)dic
{
    FMResultSet*result=[database executeQuery:[NSString stringWithFormat:@"select * from '%@' where appId='%@'",_tableName,dic[@"appid"]]];
    if(result.columnCount==0){
        //插入数据
        NSString*icon=[dic[@"logo"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        BOOL isFinish=[database executeUpdate:[NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@')",_tableName,dic[@"appid"],dic[@"name"],dic[@"remark"],icon,dic[@"version_no"],dic[@"lift_id"],dic[@"plugin_url"]]];
        
        if (isFinish) {
            MyLog(@"插入成功");
            
        }else{
            MyLog(@"插入失败,%@",_tableName);
            return NO;
        }
    }else{
        MyLog(@"已存在");
        BOOL delete=[database executeUpdate:[NSString stringWithFormat:@"delete from '%@' where appId='%@'",_tableName,dic[@"appid"]]];
        if(delete){
            NSString*icon=[dic[@"logo"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            BOOL isFinish=[database executeUpdate:[NSString stringWithFormat:@"insert into '%@' values('%@','%@','%@','%@','%@','%@','%@')",_tableName,dic[@"appid"],dic[@"name"],dic[@"remark"],icon,dic[@"version_no"],dic[@"lift_id"],dic[@"plugin_url"]]];
            //MyLog(@"%@",dic[@"lift_id"]);
            if (isFinish) {
                MyLog(@"更新成功");
                
            }else{
                MyLog(@"更新失败,%@",_tableName);
                return NO;
            }
        }
    }
    
    //[database close];
    return YES;
}
-(NSMutableArray*)loadModel
{
    //读取数据
    FMResultSet *result=[database executeQuery:[NSString stringWithFormat:@"select *from '%@'",_tableName]];
    
    //初始化数据
    NSMutableArray*dataArray=[[NSMutableArray alloc]init];
    while ([result next]) {
        NSString*appName=[result stringForColumn:@"appName"];
        NSString*appDetail=[result stringForColumn:@"appDetail"];
        NSString*iconUrl=[result stringForColumn:@"appIcon"];
        NSString*appId=[result stringForColumn:@"appId"];
        NSString*version=[result stringForColumn:@"version"];
        NSString*liftId=[result stringForColumn:@"liftId"];
        NSString*pluginUrl=[result stringForColumn:@"pluginUrl"];
        NSDictionary*tempdic=@{@"name":appName,@"remark":appDetail,@"logo":iconUrl,@"appid":appId,@"version_no":version,@"lift_id":liftId,@"plugin_url":pluginUrl};
        [dataArray addObject:tempdic];
    }
    //[database close];
    
    return dataArray;
    
    
    
}
-(void)loadUpdata:(NSArray*)array{
    BOOL delete=[database executeUpdate:[NSString stringWithFormat:@"delete from '%@'",_tableName]];
    if(delete){
        for(NSDictionary* dic in array){
            [self saveModel:dic];
        }
    }
    //[database close];
}
-(BOOL)isNewVersion:(NSDictionary *)dic{
    NSString*oldVersion=[database stringForQuery:[NSString stringWithFormat:@"select version from '%@' where appId='%@'",_tableName,dic[@"appid"]]];
    if(oldVersion.length!=0&&(![oldVersion isEqualToString:dic[@"version_no"]])){
        return NO;
    }
    //[database close];
    return YES;
}

@end
