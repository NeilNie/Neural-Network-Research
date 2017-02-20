//
//  LearnerViewController.m
//  Handwriting Recognizer
//
//  Created by Yongyang Nie on 2/20/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "LearnerViewController.h"

@interface LearnerViewController ()

@end

@implementation LearnerViewController

-(void)recognize:(id)sender{

    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
    [array replaceObjectAtIndex:[self.input.text intValue] withObject:@1];
    float *result = [self.wl.mind forwardPropagation:array];
    self.output.image = [self convertPixelToUIImage:result];
}

- (UIImage *) convertPixelToUIImage:(float *) buffer{

    char* rgba = (char*)malloc(28*28*4);
    for(int i = 0; i < 28*28; i++) {
        rgba[4*i] = 0;
        rgba[4*i+1] = 0;
        rgba[4*i+2] = 0;
        rgba[4*i+3] = buffer[i] * 255;
    }

    size_t bufferLength = 28 * 28 * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rgba, bufferLength, NULL);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef iref = CGImageCreate(28, 28, 8, 32, 4 * 28,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,   // data provider
                                    NULL,       // decode
                                    YES,            // should interpolate
                                    renderingIntent);
    
    UIImage *image = [UIImage imageWithCGImage:iref];
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);

    return image;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wl = [[WritingLearner alloc] init];
    [self.wl getMindWithPath:[[NSBundle mainBundle] pathForResource:@"mindData-learn" ofType:nil]];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarButtonItemStylePlain;
    numberToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc] initWithTitle:@"Write" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.input.inputAccessoryView = numberToolbar;
}

-(void)cancelNumberPad{
    [self.input resignFirstResponder];
    self.input.text = @"";
}

-(void)doneWithNumberPad{
    [self recognize:nil];
    [self.input resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
