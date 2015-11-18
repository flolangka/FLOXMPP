//
//  FMDBManager.h
//  AVIC_AppStore
//
//  Created by @HUI on 15-1-3.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface FMDBManager : NSObject
{
    FMDatabase*database;
    NSString*_tableName;
}
//初始化
-(id)initWithTableName:(NSString*)tableName;
//单例的方法
+(id)shareManager;
//记录数据
-(BOOL)saveModel:(NSDictionary*)dic;
//读取数据
-(NSMutableArray*)loadModel;
//更新数据
-(void)loadUpdata:(NSArray*)array;
//判断版本
-(BOOL)isNewVersion:(NSDictionary*)dic;
//删除应用
-(void)deleteApp:(NSDictionary*)dic;

@end
