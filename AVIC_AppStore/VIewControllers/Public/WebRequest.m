//
//  WebRequest.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-29.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "WebRequest.h"
#import "AFNetworking.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"

@implementation WebRequest

-(id)initWithSoap:(NSString *)soapMsg namespace:(NSString *)space urlstr:(NSString *)urlstr methodname:(NSString *)methodname Block:(void (^)(BOOL, WebRequest *))block{
    if(self=[super init]){
        //保存匿名函数指针
        self.webRequest=block;
        if (soapMsg==nil||space==nil||urlstr==nil||methodname==nil) {
            return self;
        }
        [self requestWithSoap:soapMsg namespace:space urlstr:urlstr methodname:methodname];
    }
    return self;
}
-(void)requestWithSoap:(NSString *)soapMsg namespace:(NSString *)space urlstr:(NSString *)urlstr methodname:(NSString *)methodname{
    [SVProgressHUD show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    NSURL *url=[NSURL URLWithString:urlstr];
    AFHTTPRequestOperationManager*manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"application/xml"];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    NSString *soapAction=[NSString stringWithFormat:@"%@/%@",space,methodname];
    
    //头部设置
    NSDictionary *headField=[NSDictionary dictionaryWithObjectsAndKeys:[url host],@"Host",
                             @"text/xml; charset=utf-8",@"Content-Type",
                             msgLength,@"Content-Length",
                             soapAction,@"SOAPAction",nil];
    [request setAllHTTPHeaderFields:headField];
    //超时设置
    [request setTimeoutInterval: 10 ];
    //访问方式
    [request setHTTPMethod:@"POST"];
    //body内容
    [request setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    //请求
    AFHTTPRequestOperation *opearaftion=[manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
        self.dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString*str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //MyLog(@"%@",str);
        [self XMLValue:str];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"请求错误%@",error);
        [SVProgressHUD dismiss];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
//        UIAlertView*alert= [[UIAlertView alloc]initWithTitle:@"提示" message:@"世界上最遥远的距离就是没有网络！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alert show];
        if(self.webRequest){
            self.webRequest(NO,self);
        }
    }];
    [manager.operationQueue addOperation:opearaftion];
}
-(void)XMLValue:(NSString*)str{
    
    GDataXMLDocument*doc=[[GDataXMLDocument alloc]initWithXMLString:str options:0 error:nil];
    GDataXMLElement*root=[doc rootElement];
    //MyLog(@"mm%@",[root stringValue]);
    //格式转换
    NSData*jsonData=[[root stringValue]dataUsingEncoding:NSUTF8StringEncoding];
    self.dic=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    //MyLog(@"++%@",self.dic);
    if(self.webRequest){
        self.webRequest(YES,self);
    }
}



@end
