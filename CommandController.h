//
//  CommandController.h
//  MyFrame
//
//  Created by yinhan on 14-1-7.
//  Copyright (c) 2014年 yinhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Reachability.h"
#import "RTLabel.h"


/*
        =========================================       URL  define
        ===========================================================
 */

#define SERVER_URL @""












//是否为iphone5
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )


//nslog宏
#ifndef __OPTIMIZE__
# define NSLog(...) NSLog(__VA_ARGS__)
#else
# define NSLog(...) {}
#endif










/*
        =========================================     第三方平台的 Key define
        ===========================================================
 */

#define BaiduMapKey @"BRmYKznThubo72UQwKbd5QTw"





/*
 
 -fno-objc-arc  是否arc参数
 =============================================================================
 */




@interface CommandController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager   * locationManager;
    MBProgressHUD       * _baseProgRessHUD;
    NSString            * _netWorkState;
    Reachability        * _reachability;
    BOOL                _isNetWork;
    NSString            * _currCity;
    UIWindow            *_tipWindow;


    
}

@property (nonatomic, assign) BOOL  isNetWork;
-(void)hideProgressHUD;
-(MBProgressHUD *) showProgressHUD;
-(MBProgressHUD *) showProgressHUD:(NSString *)text ForCloseToSec:(int)i;
-(MBProgressHUD *) showProgressHUD:(NSString *)text ;

-(void)closeHideHUD_ToSec:(int)i; // 3秒后关闭HUD [self closeHideHUD_ToSec:3];


- (void)showStatusTip:(BOOL)show title:(NSString *)title withSec:(int)sec;
- (void)removeTipWindow;


#pragma mark - 字符串处理
//============================================= 字符串处理
// 搜索子串
-(BOOL)isSearchString:(NSString *)string subString:(NSString *)subString;
//GBK 转到 UTF-8
-(NSString *)stringGBK_TO_UTF8_FromFile:(NSString *)fileString;
//NSString中如果包括中文字符的话转换为NSURL得到的值为nil
-(NSURL *)stringContent_ZH_To_URL:(NSString *)string;
// sha1 加密
- (NSString*) sha1:(NSString *)string;
- (NSString *)md5:(NSString *)str;
//压缩图片 用法：UIImage *yourImage= [self imageWithImageSimple:image scaledToSize:CGSizeMake(210.0, 210.0)];
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
-(void)currImageSaveToPhoto;

//应用内购买请求路径
-(NSString *)getStoreKitForSandBox;
-(NSString *)getStoreKitForBuy;
-(NSString *)getStoreKitTransactionJson:(NSString *)string;

//设置字体相关
-(UIFont *)getFont;
-(UIFont *)getCustomFontForName:(NSString *)name WithFontSize:(int)i;






//时间处理。
-(NSString *)getDateForTimeIntervalSince1970;
-(NSDate *)getDateFormatForTimeIntervalSince1970:(NSTimeInterval)time;

@end

/*
 ==============================================================
 View相关
 */
@interface UIView (ViewFrameGeometry)
{
    
}
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;
@end


/*
    NSStringExt...
 */

@interface NSString (URLDecoding)

- (NSString *) urlDecodedString;
- (NSString *) urlCodedString;

@end





/*
 ==============================================================
 验证相关
 */
@interface FormValidateUtil : NSObject
//验证账号，手机，密码，邮箱
+(BOOL) isAccountVerify:(NSString*) account;
+(BOOL) isMobilePhoneVerify:(NSString*) mobileNO;
+(BOOL) isPasswordVerify:(NSString*) password;
+(BOOL) isEmailVerify:(NSString *)email;
+(BOOL) isCardNumberVerify:(NSString *)cardNumber;
@end



/*
 ==============================================================
 文件管理相关
 */
@interface CommandFileManager : NSObject
{
    
    NSFileManager * _fileManager;
}
+(CommandFileManager *) sharedFileManager;
// 获取Document下的路径
-(NSString *)getDocumentPath;
-(NSString *)getBundlePath;
-(NSString *)getDocumentPathOrBundlePath:(int)i;
-(NSString *)getLibPath;
-(NSString *)getCachePath;
-(NSString *)getTempPath;
-(NSString *)getCustomIndexBundle:(int)i;
//根据参数获取文件
-(NSMutableArray *)getCountFileOfType:(NSString *)type FromPath:(NSString *)fileP;
-(NSMutableArray *)getFilesPathCountOfType:(NSString *)type FromPath:(NSString *)fileP isType:(BOOL)isType;
-(NSFileManager *)getFileManager;
@end




