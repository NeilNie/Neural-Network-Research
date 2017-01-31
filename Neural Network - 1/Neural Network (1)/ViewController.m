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

    Mind *m = [[Mind alloc] initWith:728 hidden:30 outputs:10 learningRate:3.0 momentum:0.5 weights:nil];
    [m randomWeightAllLayers];
    [m setIputs:@[@3, @1]];
    
    NSLog(@"%@", m);
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
