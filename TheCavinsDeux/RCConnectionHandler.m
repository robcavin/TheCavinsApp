//
//  RCConnectionHandler.m
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/13/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import "RCConnectionHandler.h"

#define POST_BOUNDARY @"jYfg5Y6HGVCjhyzxPUIw"

// Define the simple object that will actually handle download messages
@interface RCConnectionDataHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSHTTPURLResponse* response;
@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, copy)   void(^callback)(NSURLConnection* connection, NSHTTPURLResponse* response, NSData* ret, NSError* err);

@end

@implementation RCConnectionDataHandler

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)new_data {
    
    if (!self.data) {
        NSInteger responseSize = self.response.expectedContentLength;
        if (responseSize == NSURLResponseUnknownLength) responseSize = 0;
        self.data = [NSMutableData dataWithCapacity:responseSize];
    }
    [self.data appendData:new_data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.callback(connection,self.response, self.data, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.callback(connection,self.response, self.data, nil);
}

@end


// Define the static connection handler itself
@implementation RCConnectionHandler

static NSMutableDictionary* requests;

+ (void) addCSRFToRequest:(NSMutableURLRequest*)request {
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:API_DOMAIN]];
    NSHTTPCookie* csrfCookie = [cookies objectAtIndex:[cookies indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([((NSHTTPCookie*)obj).name isEqualToString:@"csrftoken"]) {
            *stop = YES;
            return YES;
        };
        return NO;
    }]];
    [request setValue:csrfCookie.value forHTTPHeaderField:@"X-CSRFToken"];
}


+ (void) multipartFormDataInitialize:(NSMutableURLRequest*)request {
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", POST_BOUNDARY];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
}

+ (NSData*) multipartFormDataWithParams:(NSDictionary*)params {
    
    NSMutableString* postString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        
        [postString appendString:[NSString stringWithFormat:@"\r\n--%@\r\n",POST_BOUNDARY]];
        [postString appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]];
        [postString appendString:[NSString stringWithFormat:@"%@",obj]];
    }];
    
    return [postString dataUsingEncoding:NSUTF8StringEncoding];
}


+ (NSData*) multipartFormDataWithFileData:(NSData*)fileData
                             withFileName:(NSString*)fileName
                          withContentType:(NSString*)contentType
                                   forKey:(NSString*)key {

    NSMutableString* postString = [NSMutableString string];
    [postString appendString:[NSString stringWithFormat:@"\r\n--%@\r\n",POST_BOUNDARY]];
    [postString appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, fileName]];
    [postString appendString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",contentType]];
    
    NSMutableData* postBody = [NSMutableData dataWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:fileData];
    
    return postBody;
}

+ (NSData*) multipartFormDataTerminate {
    return [[NSString stringWithFormat:@"\r\n--%@--\r\n",POST_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (void) cancelAllRequestsOwnedBy:(id)owner {
    NSMutableArray* liveConnectionKeys = [NSMutableArray alloc];
    
    if (owner == nil)
        [liveConnectionKeys addObjectsFromArray:[requests allKeys]];
    else {
        [requests enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* obj, BOOL *stop) {
            if ([[obj objectForKey:@"owner"] isEqual:owner]) [liveConnectionKeys addObject:key];
        }];
    }
    
    for (id key in liveConnectionKeys) {
        NSDictionary* dict = [requests objectForKey:key];
        [(NSURLConnection*)[dict objectForKey:@"connection"] cancel];
        [requests removeObjectForKey:key];
    }
}


// Publicly visible functions
+ (BOOL) requestWithEndpoint:(NSString*)endpoint
                  withMethod:(NSString*)method
                  andHeaders:(NSDictionary*)headers
                    withArgs:(NSDictionary*)args
                   withFiles:(NSArray*)files
                   withOwner:(id)owner
                    callback:(void(^)(NSHTTPURLResponse* response, NSData* data))callback {
    
    NSString *urlString = [API_DOMAIN stringByAppendingString:endpoint];
    
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    
    NSArray* allowedMethods = @[@"GET",@"POST"];
    if (![allowedMethods containsObject:method]) return NO;
    
    [request setHTTPMethod:method];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    if ([method isEqualToString:@"POST"]) {
        
        [self addCSRFToRequest:request];
        
        
        // If we only have post args with no files
        if (!(files && [files count])) {
            NSMutableArray* bodyComponents = [NSMutableArray arrayWithCapacity:[args count]];
            [args enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
                [bodyComponents addObject:
                 [NSString stringWithFormat:@"%@=%@",
                  key,
                  [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }];

            NSString* bodyString = [bodyComponents componentsJoinedByString:@"&"];

            [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        // If we have files to add
        else {
            [self multipartFormDataInitialize:request];
            
            NSMutableData* postBody = [NSMutableData data];
            [postBody appendData:[self multipartFormDataWithParams:args]];
            for (NSDictionary* file in files) {
                NSData* data = [file objectForKey:@"data"];
                if (!data) data = [NSData dataWithContentsOfFile:[file objectForKey:@"path"]];
                [postBody appendData:[self multipartFormDataWithFileData:data
                                                            withFileName:[file objectForKey:@"filename"]
                                                         withContentType:[file objectForKey:@"mime-type"]
                                                                  forKey:[file objectForKey:@"name"]]];
            }
            [postBody appendData:[self multipartFormDataTerminate]];

            [request setHTTPBody:postBody];
        }
    }
    
    // Set up return handler
    RCConnectionDataHandler* dataHandler = [[RCConnectionDataHandler alloc] init];
    
    dataHandler.callback = ^(NSURLConnection* connection, NSHTTPURLResponse* response, NSData* data, NSError* error) {
        [requests removeObjectForKey:[NSNumber numberWithInt:[connection hash]]];
        if (error) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else {
            if (callback) callback(response,data);
        }
    };
    
    // Now create the connection and kick it off
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:dataHandler startImmediately:YES];
    
    if (!requests) requests = [NSMutableDictionary dictionary];
    [requests setObject:@{@"connection":connection,@"owner":owner} forKey:[NSNumber numberWithInt:[connection hash]]];
    
    return YES;
}


+ (BOOL) requestJSONWithEndpoint:(NSString*)endpoint
                      withMethod:(NSString*)method
                        withArgs:(NSDictionary*)args
                       withFiles:(NSArray*)files
                       withOwner:(id)owner
                        callback:(void(^)(NSHTTPURLResponse* response, id json))callback {
    
    [self requestWithEndpoint:endpoint
                   withMethod:method
                   andHeaders:@{@"Accept":@"application/json"}
                     withArgs:args
                    withFiles:files
                    withOwner:owner
                     callback:^(NSHTTPURLResponse *response, NSData *data) {
                         NSError* error = nil;
                         id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                         
                         // Error parsing JSON
                         if (error) {
                             NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Response Error"
                                                                                 message:[error localizedDescription]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                             [alertView show];
                             
                         }
                         
                         // Success
                         else {
                             if (callback) callback(response,result);
                         }
                     }];
    return YES;
}

@end
