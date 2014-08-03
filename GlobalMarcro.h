//
//  GlobalMarcro.h
//  YuyiPatient
//
//  Created by jhj on 13-9-10.
//  Copyright (c) 2013年 lzh. All rights reserved.
//

#ifndef YuyiPatient_GlobalMarcro_h
#define YuyiPatient_GlobalMarcro_h
//判断空字符串
#define ISNULLARRAY(arr) (arr == nil || (NSObject *)arr == [NSNull null] || arr.count == 0)
#define ISNULL(obj) (obj == nil || (NSObject *)obj == [NSNull null])
#define ISNULLSTR(str) (str == nil || (NSObject *)str == [NSNull null] || str.length == 0)
#define iPhoneDelegate    ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define STATEBAR_HEIGHT 20           // 状态栏高度
#define TABBAR_HEIGHT 49             // 自定义UITabBar的高度
#define TABBAR_TAP_BUTTON_WIDTH 64   // TabBar按钮的宽度
#define IPHONE_WIDTH 320             // 设备像素宽度
#define IPHONE_HEIGHT 480            // 设备高度
#define IPHONE5_HEIGHT 568           // iPhone5设备的高度
#define NAVIGATIONBAR_HEIGHT 44      // 导航栏的高度

// 安全释放对象
#define RELEASE_SAFELY(__POINTER) { if(__POINTER){[__POINTER release]; __POINTER = nil; }}
//////////////////////////////////
//登录通知
#define kCheckwaterUrl         @"http://m.rrs.com/jssc/"
#define kReservationserviceUrl @"http://m.rrs.com/rrsm/appoint/appoint.html"
#define kFirstLogin            @"first"
#define kLocation              @"location"
#define kPlaceHolderImg        [UIImage imageNamed:@"日日顺默认图"]
#define kLoginNotification     @"isLogin"
#define kIsLogin               [[UIApplication sharedApplication].delegate].isLogin
#define kJugeRequset(dic)      [[dic objectForKey:@"code"]integerValue]== 200
#define kRequestError(dic)     [self showToast:[dic objectForKey:@"message"]];
#define kRequestFail           [self showToast:@"网络连接失败,请检查网络状态"];
#define kBalance               ((AppDelegate *)[UIApplication sharedApplication].delegate).balance
#define kUserModel             ((AppDelegate *)[UIApplication sharedApplication].delegate).userModel
#define kAccount               ((AppDelegate *)[UIApplication sharedApplication].delegate).account
#define NavigatiaoBar_BackgroudImag   @"导航条"
//用户登录成功后返回的用户ID
#define kUserID            @"userID"
#define kUserAccount       @"userAccount"
#define kUserPwd           @"userPwd"
// 得到屏幕大小
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kBaseURL      @"http://118.186.246.156:9090/member/mi.do"
#define kNetWorkNone  @"网络连接失败"
//IOS版本号
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define kSQLPath  [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/diseases.archiver"]
#define kMedicinePath   [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/medicines.archiver"]
///////////////////////////////////
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height-20-44-48)   // 得到屏幕高
#define SCREEN_HEIGHT_ROOT ([UIScreen mainScreen].bounds.size.height-20-44)   // 得到屏幕高

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)     // 得到屏幕宽

//得到appDelegate
#define APP_DELEGATE [[UIApplication sharedApplication] delegate]

//是否是iphone5
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
//UIBarButtonItem fram
//UIBarButtonItem fram
#define Item_FRAME (CGRectMake(0, 0, 80, 44))


//判断iOS版本与某版本比较
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//颜色
#define CALAYET_BACKGROUND_COLOR  ([UIColor colorWithRed:205/255.0 green:209/255.0 blue:198/255.0 alpha:1.0])
#define FONT_COLOR ([UIColor colorWithRed:63/255.0 green:181/255.0 blue:247/255.0 alpha:1.0])


//网络请求的UserInfo中的Key
#define REQUEST_RESULT @"REQUEST_RESULT"    //自定义Parser解析出的对象

//定位成功的Notification Name
#define NOTIFICATION_AUTO_POSITION_SUCCESS          @"NOTIFICATION_AUTO_POSITION_SUCCESS"           //关注城市发生变更后发出的通知
//定位失败的Notification Name
#define NOTIFICATION_AUTO_POSITION_FAILED           @"NOTIFICATION_AUTO_POSITION_FAILED"             //关注城市发生变更后发出的通知

//获取数据多少
#define PAGESIZE @"10"

#define SHOPINFOR [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/shopInfor.plist"]
#define MSGPLIST [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/msg.plist"]

//网络返回信息
#define OK 1
#define ERROR_CODE @"rs"
#define MSG @"msg"
#define STRING_NETWORK_BAD_STATE @"网络状态不好,请重试"

typedef enum{
	TextStyle = 0,
	ImageStyle,
    VoiceStyle,
} ConsulteCellStyle;


#endif
