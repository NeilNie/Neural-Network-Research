//
//  Simple_Neural_NetworkTests.m
//  Simple Neural NetworkTests
//
//  Created by Yongyang Nie on 2/2/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Mind.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"execution time: %f", -[startTime timeIntervalSinceNow])

@interface Simple_Neural_NetworkTests : XCTestCase

@end

@implementation Simple_Neural_NetworkTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

/*!
 This tests the network with predeterminded weights. The test will make sure that forward and backward propagations are functioning.
 
 */
-(void)testBasicNetwork{
    
    Mind *m = [[Mind alloc] initWith:2 hidden:3 outputs:1 learningRate:0.7 momentum:0.3 weights:nil];
    
    NSMutableArray *hw = [NSMutableArray arrayWithObjects:@-3.7918458, @-6.90853262, @6.98613739, @1.12071455, @-1.25512421, @1.64953291, @-3.47620749, @6.27779627, @-6.31441021, nil];
    NSMutableArray *ow = [NSMutableArray arrayWithObjects:@-3.81147313, @12.0268393, @-2.6202569, @11.0241117, nil];
    
    for (int i = 0; i<hw.count; i++)
        m.weights->hiddenWeights[i] = [hw[i] floatValue];
    for (int i = 0; i<ow.count; i++)
        m.weights->outputWeights[i] = [ow[i] floatValue];
    
    float result = [m forwardPropagation:[NSMutableArray arrayWithObjects:@0.0, @0.0, nil]][0];
    [m backwardPropagation:[NSMutableArray arrayWithObjects:@0, nil]];

    XCTAssertGreaterThan(0.006, result);
}

- (void)timeOutTest {
    
    // This is an example of a performance test case.
    Mind *m = [[Mind alloc] initWith:2 hidden:3 outputs:1 learningRate:0.9 momentum:0.3 weights:nil];
    
    NSArray *inputs = @[
                        @[@0.0, @0.0],
                        @[@0.0, @1.0],
                        @[@1.0, @0.0],
                        @[@1.0, @1.0]
                        ];
    
    NSArray *answers = [NSArray arrayWithObjects:
                        [NSArray arrayWithObject:@0.0],
                        [NSArray arrayWithObject:@1.0],
                        [NSArray arrayWithObject:@1.0],
                        [NSArray arrayWithObject:@0.0],
                        nil];
    
    [m train:inputs answer:answers testInputs:inputs testOutputs:answers threshold:0.005];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

-(void)testNetwork{
    
    Mind *m = [[Mind alloc] initWith:2 hidden:3 outputs:1 learningRate:0.9 momentum:0.3 weights:nil];
    
    NSArray *inputs = @[
                        @[@0.0, @0.0],
                        @[@0.0, @1.0],
                        @[@1.0, @0.0],
                        @[@1.0, @1.0]
                        ];
    
    NSArray *answers = [NSArray arrayWithObjects:
                        [NSArray arrayWithObject:@0.0],
                        [NSArray arrayWithObject:@1.0],
                        [NSArray arrayWithObject:@1.0],
                        [NSArray arrayWithObject:@0.0],
                        nil];
    
    [self measureBlock:^{
        [m train:inputs answer:answers testInputs:inputs testOutputs:answers threshold:0.004];
    }];

    float r1 = [m forwardPropagation:[NSMutableArray arrayWithArray:inputs[0]]][0];
    NSLog(@"calculated: %f", r1);
    NSLog(@"actual %@", answers[0]);
    [m print:[m forwardPropagation:[NSMutableArray arrayWithArray:inputs[1]]] count:1];
    NSLog(@"actual %@", answers[1]);
    NSLog(@"--------------------------");
    
    XCTAssertGreaterThan(0.005, fabs(r1 - [answers[0][0] floatValue]));
}

@end
