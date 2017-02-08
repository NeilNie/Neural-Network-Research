//
//  ViewController.m
//  Neural Network (1)
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "ViewController.h"
#import "Mind.h"

#if __has_feature(objc_arc)
#define MDLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define MDLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"execution time: %f", -[startTime timeIntervalSinceNow])

@implementation ViewController


-(void)test{
    
    Mind *m = [[Mind alloc] initWith:2 hidden:3 outputs:1 learningRate:0.99 momentum:0.5 weights:nil];
    
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
    
    float r1 = [m forwardPropagation:[NSMutableArray arrayWithArray:inputs[0]]][0];
    NSLog(@"calculated: %f", r1);
    NSLog(@"actual %@", answers[0]);
    [m print:[m forwardPropagation:[NSMutableArray arrayWithArray:inputs[1]]] count:1];
    NSLog(@"actual %@", answers[1]);
    NSLog(@"--------------------------");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end
