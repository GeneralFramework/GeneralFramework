//
//  CommandController.m
//  MyFrame
//
//  Created by yinhan on 14-1-7.
//  Copyright (c) 2014年 yinhan. All rights reserved.
//



#import "CommandController.h"
#import "CommonCrypto/CommonDigest.h"
#import <QuartzCore/QuartzCore.h>

#define kNetWorkNone                 @"网络连接失败"
#define kRequestError                @"网咯请求失败"

@interface CommandController ()

@end

@implementation CommandController
@synthesize isNetWork = _isNetWork;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _isNetWork = NO;
    _currCity = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNetwork:) name:kReachabilityChangedNotification object:nil];
    _reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = _reachability.currentReachabilityStatus;
    [self checkNetWork:status];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1000.0f;
    [locationManager startUpdatingLocation];
    
    
}


-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init] ;
    [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 for (CLPlacemark *placeMark in placemarks)
		 {
             _currCity = [[placeMark addressDictionary] objectForKey:@"City"];
             
             if([_currCity hasSuffix:@"市"])
             {
                 //_currCity = [_currCity substringToIndex:[_currCity length] - 1];
             }
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    __block NSString *provinceOrCity = nil;
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init] ;
    [clGeoCoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 for (CLPlacemark *placeMark in placemarks)
		 {
             provinceOrCity = [[placeMark addressDictionary] objectForKey:@"State"];
             _currCity = provinceOrCity;
             if([_currCity hasSuffix:@"市"])
             {
                 //_currCity = [_currCity substringToIndex:[_currCity length] - 1];
            }
         }
     }];
}







- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
    return NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//网络状态改变的时候调用
- (void)changeNetwork:(NSNotification *)notification {
    NetworkStatus status = _reachability.currentReachabilityStatus;
    [self checkNetWork:status];
}

- (void)checkNetWork:(NetworkStatus)status {
    
    if (status == kNotReachable) {
        //NSLog(@"没有网络");
        _isNetWork = NO;
        _netWorkState = [NSString stringWithFormat:kNetWorkNone];
        [self showProgressHUD:_netWorkState];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideProgressHUD) userInfo:nil repeats:NO];
    }else if(status == kReachableViaWWAN) {
        NSLog(@"3G/2G");
        _isNetWork = YES;
        _netWorkState = [NSString stringWithFormat:@"3g"];
    }else if(status == kReachableViaWiFi) {
        _netWorkState = [NSString stringWithFormat:@"wifi"];
        _isNetWork = YES;
        NSLog(@"WIFI");
    }else{
        _netWorkState = [NSString stringWithFormat:@"4g"];
    }
}




-(UIFont *)getFont{
    return [UIFont fontWithName:@"Heiti SC" size:16];
}

-(UIFont *)getCustomFontForName:(NSString *)name WithFontSize:(int)i{
    return [UIFont fontWithName:@"FZKaTong-M19S" size:i];
}

#pragma mark - showProgressHUD

-(MBProgressHUD* ) showProgressHUD
{
    return [self showProgressHUD:nil] ;
}


-(MBProgressHUD* ) showProgressHUD:(NSString*) labelText
{
    if(_baseProgRessHUD != nil) {
        [self hideProgressHUD];
    }
    _baseProgRessHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _baseProgRessHUD.alpha = 0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _baseProgRessHUD.alpha = 1;
    [UIView commitAnimations];
    if(labelText) {
        _baseProgRessHUD.labelText = labelText;
    }
    [self.view addSubview:_baseProgRessHUD];
    [_baseProgRessHUD show:YES];
    return _baseProgRessHUD;
}



-(MBProgressHUD* ) showProgressHUD:(NSString*) labelText ForCloseToSec:(int)i
{
    if(_baseProgRessHUD != nil) {
        [self hideProgressHUD];
    }
    _baseProgRessHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _baseProgRessHUD.alpha = 0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _baseProgRessHUD.alpha = 1;
    [UIView commitAnimations];
    if(labelText) {
        _baseProgRessHUD.labelText = labelText;
    }
    [self.view addSubview:_baseProgRessHUD];
    [_baseProgRessHUD show:YES];
    [self closeHideHUD_ToSec:i];
    return _baseProgRessHUD;
}

-(void) hideProgressHUD
{
    if(_baseProgRessHUD != nil) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        _baseProgRessHUD.alpha = 0;
        [UIView commitAnimations];
        [_baseProgRessHUD removeFromSuperview];
        _baseProgRessHUD = nil;
    }
}

-(void)closeHideHUD_ToSec:(int)i{
    [NSTimer scheduledTimerWithTimeInterval:i target:self selector:@selector(hideProgressHUD) userInfo:nil repeats:NO];

}




- (void)showStatusTip:(BOOL)show title:(NSString *)title withSec:(int)sec{
    if (_tipWindow == nil) {
        _tipWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        _tipWindow.windowLevel = UIWindowLevelStatusBar;
        _tipWindow.backgroundColor = [UIColor blackColor];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:13];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.tag = 2013;
        [_tipWindow addSubview:tipLabel];
        
        UIImageView *progress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue_statusbar_progress.png"]];
        progress.frame = CGRectMake(0, 20-6, 100, 6);
        progress.tag = 2012;
        [_tipWindow addSubview:progress];
    }
    
    UILabel *tipLabel = (UILabel *)[_tipWindow viewWithTag:2013];
    UIImageView *progress = (UIImageView *)[_tipWindow viewWithTag:2012];
    if (show) {
        tipLabel.text = title;
        _tipWindow.hidden = NO;
        //不能使用下面方式显示window
        //        [_tipWindow makeKeyAndVisible];
        
        progress.left = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [UIView setAnimationRepeatCount:1000];
        //匀速的移动
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        progress.left = 320;
        [UIView commitAnimations];
    } else {
        progress.hidden = YES;
        tipLabel.text = title;
    }
    [self performSelector:@selector(removeTipWindow) withObject:nil afterDelay:sec];

}

- (void)removeTipWindow {
    _tipWindow.hidden = YES;
    _tipWindow = nil;
}


- (NSString*) sha1:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}





// 搜索子串
-(BOOL)isSearchString:(NSString *)string subString:(NSString *)subString{
    NSRange range = [subString rangeOfString:string];
    if (range.location!=NSNotFound)
        return YES;
    return NO;
}
//GBK 转到 UTF-8
-(NSString *)stringGBK_TO_UTF8_FromFile:(NSString *)fileString{

    NSData *data = [NSData dataWithContentsOfFile:fileString];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [[NSString alloc] initWithData:data encoding:enc];
}


//NSString中如果包括中文字符的话转换为NSURL得到的值为nil
-(NSURL *)stringContent_ZH_To_URL:(NSString *)string{
    NSURL * url = [NSURL URLWithString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url;
}




//压缩图片
-(UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize{
    // creat a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this newcontext, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;

}

-(void)currImageSaveToPhoto{

    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -self.view.left, -self.view.top);
    
    [[self.view layer] renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    [self showProgressHUD:@"正在保存..."];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideProgressHUD) userInfo:nil repeats:NO];
}




// 应用内购买请求路径
-(NSString *)getStoreKitForSandBox{
    return @"https://sandbox.itunes.apple.com/verifyReceipt";
}

-(NSString *)getStoreKitForBuy{
    return @"https://buy.itunes.apple.com/verifyReceipt";
}

-(NSString *)getStoreKitTransactionJson:(NSString *)string{
    return [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"}", string];
}





-(NSString *)getDateForTimeIntervalSince1970{
    NSDate * localData = [NSDate date];
    NSString * timeSp = [NSString stringWithFormat:@"%ld", (long)[localData timeIntervalSince1970]];
    return timeSp;
}


-(NSDate *)getDateFormatForTimeIntervalSince1970:(NSTimeInterval)time{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    return confromTimesp;
}


@end


/*

 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 
 
 */
CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

CGRect CGRectMoveToCenter(CGRect rect, CGPoint center)
{
    CGRect newrect = CGRectZero;
    newrect.origin.x = center.x-CGRectGetMidX(rect);
    newrect.origin.y = center.y-CGRectGetMidY(rect);
    newrect.size = rect.size;
    return newrect;
}

@implementation UIView (ViewGeometry)

// Retrieve and set the origin
- (CGPoint) origin
{
	return self.frame.origin;
}

- (void) setOrigin: (CGPoint) aPoint
{
	CGRect newframe = self.frame;
	newframe.origin = aPoint;
	self.frame = newframe;
}


// Retrieve and set the size
- (CGSize) size
{
	return self.frame.size;
}

- (void) setSize: (CGSize) aSize
{
	CGRect newframe = self.frame;
	newframe.size = aSize;
	self.frame = newframe;
}

// Query other frame locations
- (CGPoint) bottomRight
{
	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (CGPoint) bottomLeft
{
	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (CGPoint) topRight
{
	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y;
	return CGPointMake(x, y);
}


// Retrieve and set height, width, top, bottom, left, right
- (CGFloat) height
{
	return self.frame.size.height;
}

- (void) setHeight: (CGFloat) newheight
{
	CGRect newframe = self.frame;
	newframe.size.height = newheight;
	self.frame = newframe;
}

- (CGFloat) width
{
	return self.frame.size.width;
}

- (void) setWidth: (CGFloat) newwidth
{
	CGRect newframe = self.frame;
	newframe.size.width = newwidth;
	self.frame = newframe;
}

- (CGFloat) top
{
	return self.frame.origin.y;
}

- (void) setTop: (CGFloat) newtop
{
	CGRect newframe = self.frame;
	newframe.origin.y = newtop;
	self.frame = newframe;
}

- (CGFloat) left
{
	return self.frame.origin.x;
}

- (void) setLeft: (CGFloat) newleft
{
	CGRect newframe = self.frame;
	newframe.origin.x = newleft;
	self.frame = newframe;
}

- (CGFloat) bottom
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void) setBottom: (CGFloat) newbottom
{
	CGRect newframe = self.frame;
	newframe.origin.y = newbottom - self.frame.size.height;
	self.frame = newframe;
}

- (CGFloat) right
{
	return self.frame.origin.x + self.frame.size.width;
}

- (void) setRight: (CGFloat) newright
{
	CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
	CGRect newframe = self.frame;
	newframe.origin.x += delta ;
	self.frame = newframe;
}

// Move via offset
- (void) moveBy: (CGPoint) delta
{
	CGPoint newcenter = self.center;
	newcenter.x += delta.x;
	newcenter.y += delta.y;
	self.center = newcenter;
}

// Scaling
- (void) scaleBy: (CGFloat) scaleFactor
{
	CGRect newframe = self.frame;
	newframe.size.width *= scaleFactor;
	newframe.size.height *= scaleFactor;
	self.frame = newframe;
}

// Ensure that both dimensions fit within the given size by scaling down
- (void) fitInSize: (CGSize) aSize
{
	CGFloat scale;
	CGRect newframe = self.frame;
	
	if (newframe.size.height && (newframe.size.height > aSize.height))
	{
		scale = aSize.height / newframe.size.height;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	if (newframe.size.width && (newframe.size.width >= aSize.width))
	{
		scale = aSize.width / newframe.size.width;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	self.frame = newframe;
}
@end







/**
    NSStringExt...
 */


@implementation NSString (URLDecoding)


- (NSString*) urlDecodedString {
    
    CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef) self,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    
    // We need to replace "+" with " " because the CF method above doesn't do it
    NSString *decodedString = [[NSString alloc] initWithString:(__bridge NSString*) decodedCFString];
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}



- (NSString *)urlCodedString{
    
    CFStringRef stringRef =  CFURLCreateStringByAddingPercentEscapes(nil,
                                                                     (CFStringRef) self,
                                                                     nil,
                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString * string = [[NSString alloc] initWithString:(__bridge NSString *)stringRef];
    return string;
}
@end






@implementation FormValidateUtil
#define ISNULLSTR(str) (str == nil || (NSObject *)str == [NSNull null] || str.length == 0)

+(BOOL) isAccountVerify:(NSString*) account{
    if(ISNULLSTR(account)) {
        return NO;
    }
    NSString * patternString = @"^([a-zA-Z0-9_.\u4e00-\u9fa5]{6,16})+$";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patternString];
    return ([regextest evaluateWithObject:account] == YES);
}


+(BOOL) isPasswordVerify:(NSString*) password{
    if(ISNULLSTR(password)) {
        return NO;
    }
    NSString * patternString = @"^([a-zA-Z0-9_-`~!@#$%^&*()+\\|\\\\=,./?><\\{\\}\\[\\]]{8,16})+$";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patternString];
    return ([regextest evaluateWithObject:password] == YES);
}

+(BOOL) isMobilePhoneVerify:(NSString*) mobileNO{
    if(ISNULLSTR(mobileNO)) {
        return NO;
    }
    NSString * patternString = @"^1[3|5|8][0-9]{9}$";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patternString];
    return ([regextest evaluateWithObject:mobileNO] == YES);
}

+(BOOL) isEmailVerify:(NSString *)email
{
    if (ISNULLSTR(email)) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return ([emailTest evaluateWithObject:email] == YES);
}


+(BOOL) isCardNumberVerify:(NSString *)cardNumber{

    if (ISNULLSTR(cardNumber)) {
        return NO;
    }
    NSString * patternString = @"[0-9]{16,16}$";
    NSPredicate * regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patternString];
    return ([regextest evaluateWithObject:cardNumber] == YES);
}
@end




CommandFileManager * fileManager = nil;
@implementation CommandFileManager


+(CommandFileManager *)sharedFileManager{
    
    @synchronized(self) {
        if (fileManager == nil) {
            fileManager = [[CommandFileManager alloc] init];
        }
        return fileManager;
    }
}
- (id)init
{
    self = [super init];
    if (self) {
        
        _fileManager = [[NSFileManager alloc] init];
        
    }
    return self;
}

-(NSFileManager *)getFileManager{
    return _fileManager;
}


// 获取document或者bundle的path
-(NSString *)getDocumentPathOrBundle:(int)i{
    
    if (0 == i) {
        NSString * documentPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/"];
        return documentPath;
    }else{
        return [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/"];
    }
}

// bundle路径
-(NSString *)getBundlePath{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/"];
    
}

-(NSString *)getCustomIndexBundle:(int)i{

    NSString * str  = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"];
    return [str stringByAppendingFormat:@"%i.bundle/", i];
}

// document路径
-(NSString *)getDocumentPath{
    return  [NSHomeDirectory() stringByAppendingFormat:@"/Documents/"];
}

-(NSString *)getLibPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return [libraryDirectory stringByAppendingFormat:@"/"];
}

-(NSString *)getCachePath{
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    return [cachePath stringByAppendingFormat:@"/"];
}
-(NSString *)getTempPath{
    return  NSTemporaryDirectory();
}







// 获取指定文件下的名字
-(NSMutableArray *)getCountFileOfType:(NSString *)type FromPath:(NSString *)fileP{
    
    NSDirectoryEnumerator *direnum = [_fileManager enumeratorAtPath:fileP];
    NSMutableArray * arrayFile = [[NSMutableArray alloc] initWithCapacity:10];
    NSString *fileName = nil;
    
    while ((fileName = [direnum nextObject])) {
        if([[fileName pathExtension] isEqualToString:type]){
            [arrayFile addObject:fileName];
        }// end if
    }//end while
    return arrayFile;
}

// 指定路径的所有文件，取决isType类型的参数
-(NSMutableArray *)getFilesPathCountOfType:(NSString *)type FromPath:(NSString *)fileP isType:(BOOL)isType{
    
    NSDirectoryEnumerator *direnum = [_fileManager enumeratorAtPath:fileP];
    NSMutableArray * arrayFile = [[NSMutableArray alloc] initWithCapacity:10];
    NSString *fileName = nil;
    
    while ((fileName = [direnum nextObject])) {
        //  isType 代表返回指定文件
        if (isType) {
            if([[fileName pathExtension] isEqualToString:type]){
                [arrayFile addObject:[NSString stringWithFormat:@"%@%@", fileP, fileName]];
            }// end if
        }else{
            [arrayFile addObject:[NSString stringWithFormat:@"%@%@", fileP, fileName]];
        }
    }//end while
    return arrayFile;
}



@end







