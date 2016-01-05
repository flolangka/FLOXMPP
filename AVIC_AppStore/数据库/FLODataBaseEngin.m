//
//  FLODataBaseEngin.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/25.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLODataBaseEngin.h"
#import "FLOChatRecordModel.h"
#import "FLOChatMessageModel.h"
#import "FMDB.h"

static FLODataBaseEngin *dataBaseEngin;
static NSString *dataBasePath;

@implementation FLODataBaseEngin

#pragma mark - 聊天用户记录
//CREATE TABLE ChatRecord(ID integer PRIMARY KEY, chatUser text, lastMessage text, lastTime text);
- (void)saveChatRecord:(FLOChatRecordModel *)chatRecord
{
    NSString *sql = [NSString stringWithFormat:@"select * from ChatRecord where chatUser = '%@'", chatRecord.chatUser];
    NSArray *oldRecords = [self selectDataWithSQLString:sql parseResult:^NSObject *(FMResultSet *rs) {
        return [[FLOChatRecordModel alloc] initWithDictionary:[rs resultDictionary]];
    }];
    if (oldRecords && oldRecords.count > 0) {
        [self executeUpdateSQLStr:[NSString stringWithFormat:@"delete from ChatRecord where chatUser = '%@'", chatRecord.chatUser]];
    }
    
    NSArray *insertArr = @[[chatRecord infoDictionary]];
    [self insert2Table:@"ChatRecord" values:insertArr];
}

- (NSArray *)selectAllChatRecords
{
    NSString *sql = @"select * from ChatRecord";
    return [self selectDataWithSQLString:sql parseResult:^NSObject *(FMResultSet *rs) {
        return [[FLOChatRecordModel alloc] initWithDictionary:[rs resultDictionary]];
    }];
}

#pragma mark - 聊天消息记录
//CREATE TABLE ChatMessage(ID integer PRIMARY KEY, messageFrom text, messageTo text, messageContent text);
- (void)insertChatMessages:(NSArray *)chatMessages
{
    NSMutableArray *muArr = [NSMutableArray array];
    for (FLOChatMessageModel *chatMsg in chatMessages) {
        [muArr addObject:[chatMsg infoDictionary]];
    }
    
    [self insert2Table:@"ChatMessage" values:muArr];
}

- (NSArray *)selectAllChatMessagesWithChatUser:(NSString *)chatUser
{
    NSString *sql = [NSString stringWithFormat:@"select * from ChatMessage where messageFrom = '%@' or messageTo = '%@'", chatUser, chatUser];
    return [self selectDataWithSQLString:sql parseResult:^NSObject *(FMResultSet *rs) {
        return [[FLOChatMessageModel alloc] initWithDictionary:[rs resultDictionary]];
    }];
}


#pragma mark - 初始化
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"沙河>>%@", NSHomeDirectory());
        
        dataBaseEngin = [[FLODataBaseEngin alloc] init];
        dataBasePath = [dataBaseEngin databasePath];
        [dataBaseEngin createEditableCopyOfDatabaseIfNeeded];
    });
    return dataBaseEngin;
}

- (void)createEditableCopyOfDatabaseIfNeeded
{
    // 判断 documents 文件夹里面有没有数据库文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL dataBaseExist = [fileManager fileExistsAtPath:dataBasePath];
    if (dataBaseExist) {
        return;
    } else {
        NSLog(@"数据库不存在,需要复制");
    }
    
    NSError *error;
    NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"floxmpp" ofType:@"db"];
    
    BOOL copySuccess = [fileManager copyItemAtPath:defaultDBPath toPath:dataBasePath error:&error];
    if (!copySuccess) {
        NSLog(@"复制数据库失败 >> '%@'.", [error localizedDescription]);
    }
    
    return;
}

- (NSString *)databasePath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"floxmpp.db"];
    return writableDBPath;
}

/**
 *  获取表字段
 *
 *  @param table 表名
 *
 *  @return 表字段集合
 */
- (NSArray *)columnOfTable:(NSString *)table
{
    NSMutableArray *columnArray = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    // 将表名转换为小写
    NSString *tableName = [table lowercaseString];
    
    // 查询表中所有字段名称
    FMResultSet *result = [db getTableSchema:tableName];
    while ([result next]) {
        [columnArray addObject:[result stringForColumn:@"name"]];
    }
    
    [db close];
    return columnArray;
}

/**
 *  组合插入的SQL语句
 *
 *  @param table    操作的表名
 *  @param valueDic 插入数据键值对
 *
 *  @return sql语句
 */
- (NSString *)createInsertSql4Table:(NSString *)table valueDict:(NSDictionary *)valueDic
{
    NSArray *allKeys = [valueDic allKeys];
    
    // 构造 column
    NSString *columnString = [allKeys componentsJoinedByString:@", "];
    // 构造key
    NSString *keyString = [allKeys componentsJoinedByString:@", :"];
    keyString = [@":" stringByAppendingString:keyString];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", table, columnString, keyString];
    
    return sql;
}

/**
 *  查询数据
 *
 *  @param sql         查询语句
 *  @param parseResult 对查询结果进行处理的block块，将每个查询结果封装成对象
 *
 *  @return 对象的集合
 */
- (NSArray *)selectDataWithSQLString:(NSString *)sql parseResult:(NSObject *(^)(FMResultSet *))parseResult
{
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *mutableArr = [NSMutableArray array];
    while ([result next]) {
        
        [mutableArr addObject:parseResult(result)];
    }
    
    [db close];
    return mutableArr;
}

/**
 *  查询数据组合成字典
 *
 *  @param sql         查询语句
 *  @param parseResult 对每一条数据进行处理
 *
 *  @return 字典
 */
- (NSDictionary *)selectInfoWithSQLString:(NSString *)sql parseResult:(NSDictionary *(^)(FMResultSet *))parseResult
{
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    FMResultSet *result = [db executeQuery:sql];
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    
    while ([result next]) {
        [muDic setValuesForKeysWithDictionary:parseResult(result)];
    }
    
    [db close];
    return muDic;
}

/**
 *  插入数据
 *
 *  @param table  表名
 *  @param values 需要插入的数据集合，每一个都是一个完整的字典
 */
- (void)insert2Table:(NSString *)table values:(NSArray *)values
{
    NSArray *tableColumn = [self columnOfTable:table];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = YES;
        for (NSDictionary *dic in values) {
            
            //过滤字典中无用字段
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            NSArray *allkey = [dic allKeys];
            for (NSString *key in allkey) {
                if (![tableColumn containsObject:key]) {
                    [muDic removeObjectForKey:key];
                }
            }
            
            NSString *sql = [self createInsertSql4Table:table valueDict:muDic];
            BOOL insertSuccess = [db executeUpdate:sql withParameterDictionary:muDic];
            if (!insertSuccess) {
                success = NO;
                NSLog(@"%@\n插入失败,参数:%@", sql, muDic);
            }
        }
        if (success) {
            NSLog(@"保存数据库成功");
        }
    }];
}

//执行sql语句
- (void)executeUpdateSQLStr:(NSString *)sqlStr
{
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    [db executeUpdate:sqlStr];
    
    [db close];
}


//清除用户的数据(将应用中的数据库替换document中的数据库)
- (void)resetDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:dataBasePath error:nil];
    
    NSError *error;
    NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"floxmpp" ofType:@"db"];
    BOOL copySuccess = [fileManager copyItemAtPath:defaultDBPath toPath:dataBasePath error:&error];
    if (!copySuccess) {
        NSLog(@"重置数据库失败 >> '%@'.", [error localizedDescription]);
    }
}


@end
