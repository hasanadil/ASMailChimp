//
//  ASMailChimp.h
//  Adio
//
//  Created by Hasan on 3/8/14.
//  Copyright (c) 2014 LabelTop Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASMailChimp : NSObject

/**
 Initialization
 
 @param apiKey It is found in the user settings on MailChimp.
 */
-(id) initWithApiKey:(NSString*)apiKey;

 /**
 Add a subscriber to a list.
  
 @param email A well formed email address
 @param listId The list id. This is not the list id that is visible in the MailChimp url pattern. It is found in the list settings on MailChimp.
 */
-(void) addSubscriberWithEmail:(NSString*)email toList:(NSString*)listId completion:(void (^)(id result, NSError* error))completion;

/**
 Remove a subscriber from a list.
 
 @param email A well formed email address
 @param listId The list id. This is not the list id that is visible in the MailChimp url pattern. It is found in the list settings on MailChimp.
 */
-(void) removeSubscriberWithEmail:(NSString*)email fromList:(NSString*)listId completion:(void (^)(id result, NSError* error))completion;

/**
 * Call this initializer once, likely in your AppDelegate
 */
+(void) initializeWithApiKey:(NSString*)apiKey;

/**
 * Use this method to fetch an instance.
 */
+(ASMailChimp*) sharedInstance;

@end
