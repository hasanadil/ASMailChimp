//
//  ASMailChimp.m
//  Adio
//
//  Created by Hasan on 3/8/14.
//  Copyright (c) 2014 LabelTop Software. All rights reserved.
//

#import "ASMailChimp.h"

@interface ASMailChimp()
{
    dispatch_queue_t queue;
}

@property (strong, nonatomic) NSString* apiKey;
@property (strong, nonatomic) NSString* apiRegion;
@property (strong, nonatomic) NSString* apiVersion;

@end

@implementation ASMailChimp

-(id) initWithApiKey:(NSString*)apiKey
{
    self = [super init];
    if (self) {
        [self setApiVersion:@"2.0"];
        [self setApiKey:apiKey];
        [self setApiRegion:[self.apiKey substringFromIndex:[self.apiKey rangeOfString:@"-" options:NSBackwardsSearch].location + 1]];
        queue = dispatch_queue_create("com.assemblelabs.mailchimp", NULL);
    }
    return self;
}

-(NSString*) endPointAddress
{
    return [NSString stringWithFormat:@"https://%@.api.mailchimp.com/%@/", [self apiRegion], [self apiVersion]];
}

#pragma mark mailchimp api functions

-(void) addSubscriberWithEmail:(NSString*)email toList:(NSString*)listId completion:(void (^)(id result, NSError* error))completion
{
    NSDictionary* requestDict = @{@"apikey": self.apiKey,
                                  @"id": listId,
                                  @"email": @{@"email": email, @"euid": @"", @"leid": @""},
                                  @"email_type": @"html",
                                  @"double_optin": @YES};
    [self sendRequestFor:@"lists" withAction:@"subscribe" data:requestDict completion:completion];
}

-(void) removeSubscriberWithEmail:(NSString*)email fromList:(NSString*)listId completion:(void (^)(id result, NSError* error))completion
{
    NSDictionary* requestDict = @{@"apikey": self.apiKey,
                                  @"id": listId,
                                  @"email": @{@"email": email, @"euid": @"", @"leid": @""}};
    [self sendRequestFor:@"lists" withAction:@"unsubscribe" data:requestDict completion:completion];
}

#pragma mark generic helpers

-(void) sendRequestFor:(NSString*)section withAction:(NSString*)action data:(NSDictionary*)dictionary  completion:(void (^)(id result, NSError* error))completion
{
    NSError* error = nil;
    NSData* requestJson = [NSJSONSerialization dataWithJSONObject:dictionary
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    if (error) {
        completion(nil, error);
        return;
    }
    
    // Create the request
    NSString* address = [NSString stringWithFormat:@"%@%@/%@.json", [self endPointAddress], section, action];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%ld", requestJson.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestJson];
    
    dispatch_block_t requestBlock = ^{
        
        if (error) {
            completion(nil, error);
            return;
        }
        
        // Peform the request
        NSURLResponse *response;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if (error) {
            dispatch_async( dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSString *responeString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        //convert response to a dict to check status from server
        NSDictionary* responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:kNilOptions
                                      error:&error];
        if (error) {
            dispatch_async( dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSString* status = [responseDict objectForKey:@"status"];
        if ([status isEqualToString:@"error"]) {
            dispatch_async( dispatch_get_main_queue(), ^{
                completion(nil, [self createErrorWithMessage:[responseDict objectForKey:@"error"]]);
            });
            return;
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            completion(responseDict, nil);
        });
    };
    
    dispatch_async(queue, requestBlock);
}

-(NSError*) createErrorWithMessage:(NSString*)message
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:message forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"com.assemblelabs.mailchimp" code:100 userInfo:errorDetail];
}

#pragma mark singleton

static ASMailChimp* _sharedInstance;

+(void) initializeWithApiKey:(NSString*)apiKey
{
    if (_sharedInstance) {
        if ([[_sharedInstance apiKey] isEqualToString:apiKey]) {
            return;
        }
    }
    _sharedInstance = [[ASMailChimp alloc] initWithApiKey:apiKey];
}

+(ASMailChimp*) sharedInstance
{
    if (!_sharedInstance) {
        NSLog(@"ASMailChimp: Did you forget to call \"[ASMailChimp initializeWithApiKey:@\"My MailChimp api key\"]\"");
        return nil;
    }
    return _sharedInstance;
}

@end




