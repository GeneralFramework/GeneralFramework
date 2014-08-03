//
//  InterfaceHelper.h
//  testNetInterface
//
//  Created by levelroad on 13-7-11.
//  Copyright (c) 2013年 lzh. All rights reserved.
//

#import "JSONKit.h"
#import "XMLReader.h"
#import "ASIFormDataRequest.h"
#import <Foundation/Foundation.h>


#define REQUEST_URL @"http://101.231.146.246:32007/"
#define RequestUserId @"android_001"
#define RequestFrom @"ios"
#define RequestPassword @"Aafd#/l1%rIn"


@interface RequestCenter : NSObject<ASIHTTPRequestDelegate>
{
       NSString *authString; 
}

+ (RequestCenter *)shareRequestCenter;


// 普通的Info请求。
- (void)sendRequest:(NSDictionary *)info_dict
             setOpt:(NSString *)opt
       setOptNumber:(NSString *)optNumber
    setSuccessBlock:(void (^)(id))success_block
       setFailBlock:(void (^)(id))fail_block;



// 带参数的请求。
- (void)sendRequest:(NSDictionary *)info_dict
             params:(NSDictionary *)param
             setOpt:(NSString *)opt
    setSuccessBlock:(void (^)(id))success_block
       setFailBlock:(void (^)(id))fail_block;

@end

@interface ResponseParse : NSObject

@end
