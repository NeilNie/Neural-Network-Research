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

    Mind *m = [[Mind alloc] init];
    m.targetValue = 0.00;
    [m insertLayer:2];
    [m insertLayer:3];
    [m insertLayer:1];
    [m addWeightFromVertex:@"0-1" toLayer:1 withValues:@[@0.8, @0.4, @0.3]];
    NSLog(@"%@", m);
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
