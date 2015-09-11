//
//  GistService.m
//  BetweenKit
//
//  Created by Stephen Fortune on 20/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "GistService.h"
#import "Routing.h"

@interface GistService ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end

@implementation GistService

- (id)init{
    self = [super init];
    if(self){
        _requestManager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

- (void)findGistsWithCompleteBlock:(void(^)(NSArray *))complete withFailBlock:(void(^)())fail {
    
    [self.requestManager GET:GISTS_URL_FOR_GISTS() parameters:nil success:^(AFHTTPRequestOperation *operation, id gists) {

        NSMutableArray *emptyGists = [[NSMutableArray alloc] init];
        
        for(NSDictionary *gistJson in gists){
            GistDescriptor *gistDescriptor = [[GistDescriptor alloc] init];
            gistDescriptor.githubId = gistJson[@"id"];
            gistDescriptor.gistDescription = gistJson[@"description"];
            [emptyGists addObject:gistDescriptor];
        }
        
        NSArray *immutableCopy = [NSArray arrayWithArray:emptyGists];
        complete(immutableCopy);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail();
    }];
}

- (void)findGistByGithubId:(NSString *)githubId withCompleteBlock:(void(^)(Gist *))complete withFailBlock:(void(^)())fail {

    
    [self.requestManager GET:GISTS_URL_FOR_GIST_WITH_ID(githubId) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *gistDictionary = responseObject;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        Gist *gist = [[Gist alloc] initWithGithubId:githubId];
        
        gist.gistDescription = gistDictionary[@"description"];
        gist.ownerUrl = gistDictionary[@"owner"][@"url"];
        gist.commentsCount = gistDictionary[@"comments"];
        gist.createdAt = [formatter dateFromString:gistDictionary[@"created_at"]];
        
        complete(gist);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail();
    }];
    
}

@end
