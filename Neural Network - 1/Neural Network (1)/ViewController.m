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

    Mind *m = [[Mind alloc] init:@[@2, @3, @1]];
    NSLog(@"%@", m);
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
