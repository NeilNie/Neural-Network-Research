//
//  ViewController.m
//  Neural Network (1)
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "ViewController.h"
#import "Mind.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Mind *m = [[Mind alloc] initWith:2 hidden:3 outputs:1 learningRate:0.7 momentum:0.9 weights:nil];
    
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
    
    NSLog(@"weights before: %@", m.hiddenWeights);
    
//    m.hiddenWeights = [NSMutableArray arrayWithObjects:@-3.7918458, @-6.90853262, @6.98613739, @1.12071455, @-1.25512421, @1.64953291, @-3.47620749, @6.27779627, @-6.31441021, nil];
//    m.outputWeights = [NSMutableArray arrayWithObjects:@-3.81147313, @12.0268393, @-2.6202569, @11.0241117, nil];
//    NSLog(@"%@", [m forwardPropagation:[NSMutableArray arrayWithObjects:@0.0, @0.0, nil]]);
//    NSLog(@"%f", [m backwardPropagation:[NSMutableArray arrayWithObjects:@0, nil]]);
    
    [m train:inputs answer:answers testInputs:inputs testOutputs:answers threshold:0.005];
    NSLog(@"calculated output: %@", [m forwardPropagation:[NSMutableArray arrayWithArray:inputs[0]]]);
    NSLog(@"actual %@", answers[0]);
    NSLog(@"calculated output: %@", [m forwardPropagation:[NSMutableArray arrayWithArray:inputs[1]]]);
    NSLog(@"actual %@", answers[1]);
    NSLog(@"--------------------------");
    NSLog(@"now weights %@", m.hiddenWeights);
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end
