//
//  Localisator.m
//  CustomLocalisator
//
//  Created by Hasan_Sawaed on 11/27/13.
//  Copyright (c) 2013 Reuven M. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOCALIZATION(text) [[Localisator sharedInstance] localizedStringForKey:(text)]
static NSString * const kNotificationLanguageChanged = @"kNotificationLanguageChanged";



@interface Localisator : NSObject

@property (nonatomic, readonly) NSArray* availableLanguages;
@property (nonatomic, assign) BOOL saveInUserDefaults;
@property (nonatomic, retain) NSString * currentLanguage;

+ (Localisator*)sharedInstance;
-(NSString *)localizedStringForKey:(NSString*)key;
-(BOOL)setLanguage:(NSString*)newLanguage;

@end
