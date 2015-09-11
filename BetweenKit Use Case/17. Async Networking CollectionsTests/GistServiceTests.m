//
//  _7__Async_Networking_CollectionsTests.m
//  17. Async Networking CollectionsTests
//
//  Created by Stephen Fortune on 27/12/2014.
//  Copyright (c) 2014 IceCube Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <OCMock/OCMock.h>
#import "GistService.h"

#define AssertEqualGistDescriptors(gist, githubIdComp, description) {                       \
    GistDescriptor *desc = gist;                                                            \
    XCTAssertTrue([desc isKindOfClass:[GistDescriptor class]], @"Not correct type");        \
    XCTAssertEqualObjects(githubIdComp, desc.githubId, @"Github IDs don't match");          \
    XCTAssertEqualObjects(description, desc.gistDescription, @"Descriptions don't match");  \
}

@interface GistServiceTests : XCTestCase {
    GistService *_service;
    id _mockRequestManager;
}

@end

@implementation GistServiceTests

- (void)setUp {
    [super setUp];
    _mockRequestManager = OCMClassMock([AFHTTPRequestOperationManager class]);
    OCMStub([_mockRequestManager manager]).andReturn(_mockRequestManager);
    _service = [[GistService alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitSetsUpRequestManager {
    XCTAssertEqualObjects(_service.requestManager, _mockRequestManager, @"Service should have initialised request manager to shared singleton");
}

- (void)testFindGistsMakesGETRequest {
    [_service findGistsWithCompleteBlock:[OCMArg any] withFailBlock:[OCMArg any]];
    OCMVerify([_mockRequestManager GET:@"https://api.github.com/gists/public" parameters:nil success:[OCMArg isNotNil] failure:[OCMArg isNotNil]]);
}

- (void)testFindGistsFiresCompleteBlockWithResultsOnSuccessfulRequest {
    
    NSArray *gists = @[ @{ @"id": @"a", @"description": @"First test gist" }, @{ @"id": @"b", @"description": @"Second test gist" }, @{ @"id": @"c" }, ];
    [[_mockRequestManager stub] GET:[OCMArg any] parameters:[OCMArg any] success:[OCMArg invokeBlockWithArgs:OCMDefault, gists, nil] failure:[OCMArg any]];

    __block NSArray *results;
    __block BOOL invoked;
    
    [_service findGistsWithCompleteBlock:^(NSArray *res) {
        invoked = YES;
        results = res;
    } withFailBlock:nil];
    
    XCTAssertTrue(invoked, @"Our success handler doesn't invoke the success block");
    XCTAssertNotNil(results, @"Results are nil");
    XCTAssertEqual(results.count, 3, @"Not enough results returned");
    AssertEqualGistDescriptors(results[0], @"a", @"First test gist");
    AssertEqualGistDescriptors(results[1], @"b", @"Second test gist");
    AssertEqualGistDescriptors(results[2], @"c", nil);

}

- (void)testFindGistsFiresFailBlockOnFailedRequest {
    
    [[_mockRequestManager stub] GET:[OCMArg any] parameters:[OCMArg any] success:[OCMArg any] failure:[OCMArg invokeBlock]];
    __block BOOL invoked;
    [_service findGistsWithCompleteBlock:nil withFailBlock:^{ invoked = YES; }];
    XCTAssertTrue(invoked, @"Our failure handler doesn't invoke the success block");

}

- (void)testFindGistMakesGETRequest {
    [_service findGistByGithubId:@"123" withCompleteBlock:[OCMArg any] withFailBlock:[OCMArg any]];
    OCMVerify([_mockRequestManager GET:@"https://api.github.com/gists/123" parameters:nil success:[OCMArg isNotNil] failure:[OCMArg isNotNil]]);    
}

- (void)testFindGistFirstCompleteBlockWithGistOnSuccessfulRequest {

    NSDictionary *gist = @{ @"description": @"Hi, I am a gist.", @"owner": @{ @"url": @"http://here.com" }, @"comments": @100, @"created_at": @"2015-09-11T17:35:39Z" };
    [[_mockRequestManager stub] GET:[OCMArg any] parameters:[OCMArg any] success:[OCMArg invokeBlockWithArgs:OCMDefault, gist, nil] failure:[OCMArg any]];
    
    __block Gist *result;
    __block BOOL invoked;
    
    [_service findGistByGithubId:@"123" withCompleteBlock:^(Gist *gist) {
        invoked = YES;
        result = gist;
    } withFailBlock:nil];
    
    XCTAssertTrue(invoked, @"Our success handler doesn't invoke the success block");
    XCTAssertNotNil(result, @"Gist is nil");
    XCTAssertEqualObjects(result.gistDescription, @"Hi, I am a gist.", @"Gist descriptions don't match");
    XCTAssertEqualObjects(result.ownerUrl, @"http://here.com", @"Owner urls don't match");
    XCTAssertEqualObjects(result.commentsCount, @100, @"Comment counts don't match");
    XCTAssertEqualObjects(result.createdAt, [NSDate dateWithTimeIntervalSince1970:1441992939], @"Dates don't match");

}

- (void)testFindGistFiresFailBlockOnFailedRequest {
    
    [[_mockRequestManager stub] GET:[OCMArg any] parameters:[OCMArg any] success:[OCMArg any] failure:[OCMArg invokeBlock]];
    __block BOOL invoked;
    [_service findGistByGithubId:@"123" withCompleteBlock:nil withFailBlock:^{ invoked = YES; }];
    XCTAssertTrue(invoked, @"Our failure handler doesn't invoke the success block");
    
}

@end
