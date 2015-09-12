//
//  Strange_TypesTests.m
//  Strange TypesTests
//
//  Created by Stephen Fortune on 09/09/2015.
//  Copyright (c) 2015 Stephen Fortune. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

struct OCMStruct {
    NSUInteger prop1;
    NSUInteger prop2;
};

typedef NSObject *OCMTypedefObj;
typedef struct OCMStruct OCMStructTypedef;
typedef BOOL (^OCMBlockTypedef)(NSString *);

@interface OCMStrangeTypes : NSObject

@end

@implementation OCMStrangeTypes

- (void)doLotsOfParams:(void (^)(NSString *, NSString *, long, NSInteger, double, char, NSNumber *, NSIndexPath *))longBlock {}
- (void)doReturnValue:(NSString *(^)())returnBlock {}
- (void)doInnerBlock:(void(^)(BOOL(^)(NSString *), OCMBlockTypedef))blockWithBlock {}
- (void)doTypedef:(void(^)(OCMTypedefObj, OCMTypedefObj *))typedefBlock {}
- (void)doStructs:(void(^)(struct OCMStruct, OCMStructTypedef, struct OCMStruct *, OCMStructTypedef *))structBlock {}
- (void)doVoidPtr:(void(^)(void *))voidPtrBlock {}

@end

@interface OCMBlockArgCallerTests : XCTestCase {
    id mock;
}

@end

@implementation OCMBlockArgCallerTests

- (void)setUp {
    [super setUp];
    mock = OCMClassMock([OCMStrangeTypes class]);
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInvokingBlockWithManyVaryingParams {

    NSNumber *num = @3L;
    NSLog(@"Num type: %s", num.objCType);
    OCMStub([mock doLotsOfParams:([OCMArg invokeBlockWithArgs:@"One", @"Two", @3, @4, @5.23, @'6', @7, [NSIndexPath indexPathWithIndex:8], nil])]);
    __block BOOL invoked = NO;

    [mock doLotsOfParams:^(NSString *one, NSString *two, long three, NSInteger four, double five, char six, NSNumber *seven, NSIndexPath *eight) {
        
        invoked = YES;
        
        XCTAssertEqualObjects(one, @"One");
        XCTAssertEqualObjects(two, @"Two");
        XCTAssertEqual(three, 3);
        XCTAssertEqual(four, 4);
        XCTAssertEqual(five, 5.23);
        XCTAssertEqual(six, '6');
        XCTAssertEqualObjects(seven, @7);
        XCTAssertEqualObjects(eight, [NSIndexPath indexPathWithIndex:8]);
        
    }];
    
    XCTAssertTrue(invoked, @"Block not invoked");
    
}

- (void)testInvokingBlockWithReturnValue {

    OCMStub([mock doReturnValue:[OCMArg invokeBlockWithArgs:nil]]);
    __block BOOL invoked = NO;
    
    [mock doReturnValue:^NSString *{
        invoked = YES;
        return @"Returning this";
    }];

    XCTAssertTrue(invoked, @"Block not invoked");

}

- (void)testInvokingBlockWithBlockParams {

    BOOL (^firstParam)(NSString *) = ^(NSString *param){
        return [param isEqualToString:@"one"];
    };
    OCMBlockTypedef secondParam = ^(NSString *param){
        return [param isEqualToString:@"two"];
    };

    OCMStub([mock doInnerBlock:([OCMArg invokeBlockWithArgs:firstParam, secondParam, nil])]);
    __block BOOL invoked = NO;

    [mock doInnerBlock:^(BOOL (^blockArg)(NSString *param), OCMBlockTypedef blockArg2) {
        
        invoked = YES;
        XCTAssertEqualObjects(blockArg, firstParam);
        XCTAssertTrue(blockArg(@"one"));
        XCTAssertFalse(blockArg(@"notOne"));
        
        XCTAssertEqualObjects(blockArg2, secondParam);
        XCTAssertTrue(blockArg2(@"two"));
        XCTAssertFalse(blockArg2(@"notTwo"));
        
    }];
    
    XCTAssertTrue(invoked, @"Block not invoked");

}

- (void)testInvokingBlockWithTypedefObjects {

    NSObject *obj = [NSObject new];
    OCMStub([mock doTypedef:([OCMArg invokeBlockWithArgs:obj, OCMOCK_VALUE(&obj), nil])]);
    __block BOOL invoked = NO;

    [mock doTypedef:^(OCMTypedefObj obj1, __autoreleasing OCMTypedefObj *obj2) {
        invoked = YES;
        XCTAssertEqualObjects(obj1, obj);
        XCTAssertEqualObjects(*obj2, obj);
    }];

    XCTAssertTrue(invoked, @"Block not invoked");

}

- (void)testInvokingBlockWithStructs {
    
    OCMStub([mock doStructs:([OCMArg invokeBlockWithArgs:
                              OCMOCK_VALUE(((struct OCMStruct){ 1, 2 })),
                              OCMOCK_VALUE(((OCMStructTypedef){ 3, 4 })),
                              OCMOCK_VALUE((&(struct OCMStruct){ 5, 6 })),
                              OCMOCK_VALUE((&(OCMStructTypedef){ 7, 8 })),
                              nil])]);
    __block BOOL invoked = NO;
    
    [mock doStructs:^(struct OCMStruct a, OCMStructTypedef b, struct OCMStruct *c, OCMStructTypedef *d) {
    
        invoked = YES;

        XCTAssertEqual(a.prop1, 1);
        XCTAssertEqual(a.prop2, 2);

        XCTAssertEqual(b.prop1, 3);
        XCTAssertEqual(b.prop2, 4);

        XCTAssertEqual(c->prop1, 5);
        XCTAssertEqual(c->prop2, 6);

        XCTAssertEqual(d->prop1, 7);
        XCTAssertEqual(d->prop2, 8);

    }];
    
    XCTAssertTrue(invoked, @"Block not invoked");

}

- (void)testInvokingBlockWithVoidPtr {
    
    OCMStructTypedef *ptr = &(OCMStructTypedef){ 1, 2 };
    OCMStub([mock doVoidPtr:([OCMArg invokeBlockWithArgs:OCMOCK_VALUE(ptr), nil])]);
    
    __block BOOL invoked = NO;
    [mock doVoidPtr:^(void *vPtr) {
        invoked = YES;
        XCTAssertEqual(vPtr, ptr);
    }];

    XCTAssertTrue(invoked, @"Block not invoked");

}

@end
