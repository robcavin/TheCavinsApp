//
//  RCConnectionHandler.h
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/13/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_DOMAIN @"http://10.0.0.10:8080/"

@interface RCConnectionHandler : NSObject 

+ (BOOL) requestWithEndpoint:(NSString*)endpoint
                  withMethod:(NSString*)method
                  andHeaders:(NSDictionary*)headers
                    withArgs:(NSDictionary*)args
                   withFiles:(NSArray*)files
                   withOwner:(id)owner
                    callback:(void(^)(NSHTTPURLResponse* response, NSData* data))callback;

+ (BOOL) requestJSONWithEndpoint:(NSString*)endpoint
                      withMethod:(NSString*)method
                        withArgs:(NSDictionary*)args
                       withFiles:(NSArray*)files
                       withOwner:(id)owner
                        callback:(void(^)(NSHTTPURLResponse* response, id json))callback;

@end
