//
//  GistService.h
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "Gist.h"

@interface GistService : NSObject

@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *requestManager;

-(void) findGistsWithCompleteBlock:(void(^)(NSArray *gists)) complete withFailBlock:(void(^)()) fail;

-(void) findGistByGithubId:(NSString *)githubId withCompleteBlock:(void(^)(Gist *)) complete withFailBlock:(void(^)()) fail;

@end
