
/*
 使用方法：
 比如某个JSON数据解析后的数据（NSDictionary对象）是：
 //dict
 {
 "id": 50234
 "name":"David",
 "age":40,
 "email":"david@gmail.com"
 }
 
 你可以定义一个RMUser类：
 
 // RMUser.h
 @interface RMUser : NSObject
 @property (nonatomic, retain) NSNumber* id;
 @property (nonatomic, retain) NSString* name;
 @property (nonatomic, retain) NSString* email;
 @property (nonatomic, retain) NSNumber* age;
 @end
 
 这时候，利用RMMapper可以很方便将之前的JSON数据直接转化成RMUser类：
 
 RMUser* user = [RMMapper objectWithClass:[RMUser class] fromDictionary:dict];
 
 如果需要将user保存到NSUserDefaults，那么需要引入头文件：
 
 #import "NSObject+RMArchivable.h"
 
 然后保存数据到NSUserDefaults:
 
 NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
 [defaults rm_setCustomObject:user forKey:@"SAVED_DATA"];
 
 如果要获取之前保存的数据：
 
 user = [defaults rm_customObjectForKey:@"SAVED_DATA"];
 
 */
#import <Foundation/Foundation.h>

@interface RMMapper : NSObject

/**
 Answer from http://stackoverflow.com/questions/754824/get-an-object-attributes-list-in-objective-c/13000074#13000074
 
 Return dictionary of property name and type from a class.
 Useful for Key-Value Coding.
 */
+ (NSDictionary *)propertiesForClass:(Class)cls;

/** Populate existing object with values from dictionary
 */
+ (id) populateObject:(id)obj fromDictionary:(NSDictionary*)dict;
+ (id) populateObject:(id)obj fromDictionary:(NSDictionary*)dict exclude:(NSArray*)excludeArray;


/** Create a new object with given class and populate it with value from dictionary
 */
+ (id) objectWithClass:(Class)cls fromDictionary:(NSDictionary*)dict;

/** Convert an object to a dictionary
 */
+ (NSDictionary*) dictionaryForObject:(id)obj;
+ (NSDictionary*) dictionaryForObject:(id)obj include:(NSArray*)includeArray;
+ (NSMutableDictionary*) mutableDictionaryForObject:(id)obj;
+ (NSMutableDictionary*) mutableDictionaryForObject:(id)obj include:(NSArray*)includeArray;


/** Convert an array of dict to array of object with predefined class
 */
+ (NSArray*) arrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;
+ (NSMutableArray*) mutableArrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;

@end
