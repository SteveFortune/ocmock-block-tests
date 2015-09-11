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

- (void)testFindGistsFiresCompleteBlockWithResultsOnSuccess {
    
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

- (void)testFindGistsFiresFailBlock {
    
    [[_mockRequestManager stub] GET:[OCMArg any] parameters:[OCMArg any] success:[OCMArg any] failure:[OCMArg invokeBlock]];

    __block BOOL invoked;
    [_service findGistsWithCompleteBlock:nil withFailBlock:^{
        invoked = YES;
    }];

    XCTAssertTrue(invoked, @"Our failure handler doesn't invoke the success block");

}

@end
