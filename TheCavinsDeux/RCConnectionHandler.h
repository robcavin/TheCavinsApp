//
//  RCConnectionHandler.h
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/13/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_DOMAIN @"http://thecavins.com/"

@interface RCConnectionHandler : NSObject 

+ (BOOL) requestWithEndpoint:(NSString*)endpoint
                  withMethod:(NSString*)method
                  andHeaders:(NSDictionary*)headers
                    withArgs:(NSDictionary*)args
                   withFiles:(NSArray*)files
                   withOwner:(id)owner
        withProgressCallback:(void(^)(float completionPercentage))progressCallback
      withCompletionCallback:(void(^)(NSHTTPURLResponse* response, NSData* data))callback;

+ (BOOL) requestJSONWithEndpoint:(NSString*)endpoint
                      withMethod:(NSString*)method
                        withArgs:(NSDictionary*)args
                       withFiles:(NSArray*)files
                       withOwner:(id)owner
            withProgressCallback:(void(^)(float completionPercentage))progressCallback
          withCompletionCallback:(void(^)(NSHTTPURLResponse* response, id json))callback;

+ (void) cancelAllRequestsOwnedBy:(id)owner;

@end
