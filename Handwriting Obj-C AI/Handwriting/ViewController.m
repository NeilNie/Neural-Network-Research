//
//  ViewController.m
//  Handwriting
//
//  Created by Yongyang Nie on 2/3/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)updateImage:(NSImage *)image{
    self.image.image = image;
}

- (IBAction)action:(id)sender {
    self.image.image = self.wt.image;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wt = [[WritingTrainer alloc] init];
    self.wt.delegate = self;
    [self.wt train:2000 epochs:0 correctRate:90.0];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
