//
//  InterfaceHelper.m
//  testNetInterface
//
//  Created by levelroad on 13-7-11.
//  Copyright (c) 2013年 lzh. All rights reserved.
//

#import "RequestCenter.h"

@implementation RequestCenter

- (id)initWithAuthString:(NSString *)auth;
{
    self = [super init];
    if (self) {
        authString = [auth copy];
    }
    return self;
}

static NSMutableArray *request_queue;
+ (RequestCenter *)shareRequestCenter
{
    @synchronized(self){
        static RequestCenter *_self;
        if(!_self)
        {
            request_queue = [[NSMutableArray alloc] init];
            NSMutableDictionary *auth_dict = [[NSMutableDictionary alloc] init];
            // todo
            [auth_dict setObject:@"123" forKey:@"app_key"];
            [auth_dict setObject:@"123" forKey:@"imei"];
            [auth_dict setObject:@"Iphone os" forKey:@"os"];
            [auth_dict setObject:@"5.0" forKey:@"os_version"];
            [auth_dict setObject:@"1.0.0" forKey:@"app_version"];
            [auth_dict setObject:@"0.9" forKey:@"ver"];
            
            
            NSString *str_temp = [auth_dict JSONString];
            _self = [[RequestCenter alloc] initWithAuthString:str_temp];
        }
        return _self;
    }
}








// 普通的Info请求。
- (void)sendRequest:(NSDictionary *)info_dict setOpt:(NSString *)opt setOptNumber:(NSString *)optNumber setSuccessBlock:(void (^)(id))success_block setFailBlock:(void (^)(id))fail_block{

    
    void (^successBlock)(id);
    void (^failBlock)(id);
    
    
    successBlock = [success_block copy];
    failBlock = [fail_block copy];
    
    
    NSURL *_url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",REQUEST_URL,opt]];
    NSLog(@"url = %@", _url);
    
    
    ASIFormDataRequest *form_request = [[ASIFormDataRequest alloc] initWithURL:_url];
    [request_queue addObject:form_request];
    [form_request addPostValue:[authString JSONString] forKey:@"auth"];
    [form_request addPostValue:[info_dict JSONString] forKey:@"info"];
    [form_request addPostValue:optNumber forKey:@"opt"];
    
    [form_request startAsynchronous];
    [form_request setCompletionBlock:^
     {
         if ([[form_request responseString]hasPrefix:@"<"]&&[[form_request responseString]hasSuffix:@">"]) {
             NSError *parseError = nil;
             NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:[form_request responseString] error:&parseError];
             successBlock(xmlDictionary);
         }else{
             
             successBlock([[form_request responseString] objectFromJSONString]);
         }
     }];

//    void (^successBlock)(id);
//    void (^failBlock)(id);
//    successBlock = [success_block copy];
//    failBlock = [fail_block copy];
//    
//    NSURL *_url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",REQUEST_URL,opt]];
//    ASIFormDataRequest *form_request = [[ASIFormDataRequest alloc] initWithURL:_url];
//    //[_url release];
//    [request_queue addObject:form_request];
//    //[form_request release];
//    
//    [form_request addPostValue:[authString JSONString] forKey:@"auth"];
//    [form_request addPostValue:[info_dict JSONString] forKey:@"info"];
//    
//    [form_request startAsynchronous];
//    [form_request setCompletionBlock:^
//     {
//         if ([[form_request responseString]hasPrefix:@"<"]&&[[form_request responseString]hasSuffix:@">"]) {
//             NSError *parseError = nil;
//             NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:[form_request responseString] error:&parseError];
//             successBlock(xmlDictionary);
//         }else{
//             NSString *ReString = [[form_request responseString] stringByReplacingOccurrencesOfString:@"null" withString:@"\"\"" ];
//             successBlock([ReString objectFromJSONString]);
//         }
//     }];
//    [form_request setFailedBlock:^{
//        failBlock([[form_request responseString] objectFromJSONString]);
//    }];

}








// 带参数的请求。
-(void)sendRequest:(NSDictionary *)info_dict params:(NSDictionary *)param setOpt:(NSString *)opt setSuccessBlock:(void (^)(id))success_block setFailBlock:(void (^)(id))fail_block{

    
    void (^successBlock)(id);
    void (^failBlock)(id);
    successBlock = [success_block copy];
    failBlock = [fail_block copy];
    
    NSURL *_url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",REQUEST_URL,opt]];
    ASIFormDataRequest *form_request = [[ASIFormDataRequest alloc] initWithURL:_url];
    [request_queue addObject:form_request];
    [form_request addPostValue:[authString JSONString] forKey:@"auth"];
    [form_request addPostValue:[info_dict JSONString] forKey:@"info"];
    NSArray *keys = [param allKeys];
    for (NSString *key in keys) {
        if ([[param objectForKey:key]isKindOfClass:[NSArray class]]) {
            [form_request addPostValue:[[param objectForKey:key]JSONString] forKey:key];
        }else{
            [form_request addPostValue:[param objectForKey:key] forKey:key];
        }
    }
    
    [form_request startAsynchronous];
    [form_request setCompletionBlock:^
     {
         if ([[form_request responseString]hasPrefix:@"<"]&&[[form_request responseString]hasSuffix:@">"]) {
             NSError *parseError = nil;
             NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:[form_request responseString] error:&parseError];
             successBlock(xmlDictionary);
         }else{
             
             successBlock([[form_request responseString] objectFromJSONString]);
         }
     }];
    
    [form_request setFailedBlock:^{
        failBlock([[form_request responseString] objectFromJSONString]);
    }];
}



















+ (void)cancelAllOperations
{

    [[ASIFormDataRequest sharedQueue] cancelAllOperations];
    
}


- (void)requestStarted:(ASIHTTPRequest *)request {
    NSLog(@"请求已发送");
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    NSLog(@"服务器已接收到请求");
}
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    NSLog(@"请求等待中");
}
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"请求完成");
}
- (void)requestFailed:(ASIHTTPRequest *)request {

}

+(NSString *)Today
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *times =[dateFormatter stringFromDate:today];
    return times;
}
+(NSString *)DateToStr:(NSDate *)mydate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *times =[dateFormatter stringFromDate:mydate];
    return times;
}
+(NSString *)IsNull:(id)str
{
    if (![str isEqual:[NSNull null]]) {
        return str  ;
    }else
        return @"";
}
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0125-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(BOOL) isIdentificationCard:(NSString *)indentification{
    if([indentification length]==0){
        return NO;
    }
    NSString *indentificationRegex = @"^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}((19\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|(19\\d{2}(0[13578]|1[02])31)|(19\\d{2}02(0[1-9]|1\\d|2[0-8]))|(19([13579][26]|[2468][048]|0[48])0229))\\d{3}(\\d|X|x)?$";
    NSPredicate * indentificationText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",indentificationRegex];
    
    return ( [indentificationText evaluateWithObject:indentification] == YES);
}
//+ (NSString *)isoDate:(NSString *)str
//{
//    for (int i = 0; i < [str length]; i++) {
//        if ([str characterAtIndex:i]=='1') {
//            NSString *subStr = [str substringWithRange:{i,11}];
//            if ([RequestCenter isMobileNumber:subStr]) {
//            }
//        }
//
//    }
//    return str;
//}

@end

@implementation ResponseParse

- (NSDictionary *)parseResponse:(NSString *)reseponseString
{
    return nil;
}

@end
