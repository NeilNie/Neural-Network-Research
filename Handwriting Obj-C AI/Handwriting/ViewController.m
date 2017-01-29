//
//  ViewController.m
//  Handwriting
//
//  Created by Yongyang Nie on 2/3/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)loadData{

    
    NSString *path = [[NSBundle mainBundle] executablePath];
    NSURL *url = [[[NSURL fileURLWithPath:path] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"train-images-idx3-ubyte"];
    
    //NSData *trainData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz"]];
    NSData *trainData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"train-images-idx3-ubyte" ofType:@"txt"]];
    NSLog(@"%@", trainData);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadData];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
