//
//  ViewController.m
//  Handwriting
//
//  Created by Yongyang Nie on 2/3/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - WriteTrainer Delegate

-(void)updateLogText:(NSString *)string{
    self.textField.string = [self.textField.string stringByAppendingString:string];
}

#pragma mark - IBActions

-(IBAction)train:(id)sender{
    
    self.wt = [[WritingTrainer alloc] initTrainer];
    [self.wt evaluate:5000];
    self.wt.delegate = self;
    float rate = [self.wt evaluate:10000] * 100;
    NSLog(@"%.2f", rate);
    [self.wt train:1000 epochs:0 correctRate:95.0];
}

-(IBAction)loadData:(id)sender{
    [self.wt getMindWithPath:@"/Users/Neil/Desktop/mindData"];
}

-(IBAction)learn:(id)sender{
    
    self.wl = [[WritingLearner alloc] initLearner];
    NSLog(@"%f", [self.wl evaluate:5000]);
    [self.wl train:10000 epochs:30 correctRate:0];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
