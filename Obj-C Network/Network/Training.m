//
//  Training.m
//  Network
//
//  Created by Yongyang Nie on 2/14/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Training.h"

#if __has_feature(objc_arc)
#define MDLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define MDLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"execution time: %f", -[startTime timeIntervalSinceNow])

@implementation Training

- (instancetype)initTrainer
{
    self = [super init];
    if (self) {
        
        NSData *trainImages = [NSData dataWithContentsOfFile:@"/Users/Neil/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/train-images-idx3-ubyte"];
        NSData *trainLabels = [NSData dataWithContentsOfFile:@"/Users/Neil/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/train-labels-idx1-ubyte"];
        NSData *testImages = [NSData dataWithContentsOfFile:@"/Users/Neil/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/t10k-images-idx3-ubyte"];
        NSData *testLabels = [NSData dataWithContentsOfFile:@"/Users/Neil/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/t10k-labels-idx1-ubyte"];
        
        if (!trainLabels || !trainImages || !testImages || !testLabels)
            @throw [NSException exceptionWithName:@"Constructor Failed" reason:@"Error retrieving data" userInfo:nil];
        
        CGSize imageSize = CGSizeMake(28, 28);
        int nPixels = imageSize.width * imageSize.height;
        
        self.trainingData = [NSMutableArray array];
        self.testData = [NSMutableArray array];
        // Store image/label byte indices
        int imagePosition = 16; // Start after header info
        int labelPosition = 8;  // Start after header info
        
        for (int i = 0; i < 60000; i++) {
            
            if (i%10000 == 0 || i == 60000 - 1)
                NSLog(@"%.2f %%", (float)i / 600.0);
            
            //extract images
            uint8 *ints = calloc(nPixels, sizeof(uint8));
            [trainImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
            
            NSMutableArray *pixels  = [[NSMutableArray alloc] initWithCapacity:nPixels];
            for (int i = 0; i < nPixels; i++)
                [pixels addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
            
            //extract labels1
            uint8 *trainLabel = calloc(1, sizeof(uint8));
            [trainLabels getBytes:trainLabel range:NSMakeRange(labelPosition, 1)];
            
            Matrix *pix = [Matrix matrixFromNSArray:pixels rows:(int)pixels.count columns:1];
            
            NSMutableArray *answer = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
            [answer replaceObjectAtIndex:trainLabel[0] withObject:[NSNumber numberWithInt:1]];
            Matrix *l = [Matrix matrixFromNSArray:answer rows:10 columns:1];
            
            Tuple *t = [[Tuple alloc] init:pix object2:l];
            [self.trainingData addObject:t];
            trainLabel = NULL;
            ints = NULL;
            
            // Extract test image/label if we're still in range
            if (i < 10000) {
                //extract images
                uint8 *ints = calloc(nPixels, sizeof(uint8));
                [testImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
                
                NSMutableArray *ps  = [[NSMutableArray alloc] initWithCapacity:nPixels];
                for (int i = 0; i < nPixels; i++)
                    [ps addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
                
                // Extract labels
                uint8 *tli = calloc(1, sizeof(uint8));
                [testLabels getBytes:tli range:NSMakeRange(labelPosition, 1)];
                
                Matrix *img = [Matrix matrixFromNSArray:ps rows:(int)ps.count columns:1];
                NSMutableArray *answer = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
                [answer replaceObjectAtIndex:tli[0] withObject:[NSNumber numberWithInt:1]];
                Matrix *a = [Matrix matrixFromNSArray:answer rows:10 columns:1];
                Tuple *t = [[Tuple alloc] init:img object2:a];
                [self.testData addObject:t];
                
                tli = NULL;
                ints = NULL;
            }
            imagePosition += nPixels;
            labelPosition++;
        }
        TICK;
        self.network = [[Network alloc] init:@[@784, @30, @10]];
        TOCK;
    }
    return self;
}

-(void)train:(int)batchSize epochs:(int)epochs learningRate:(float)eta{
    [self.network SGD:self.trainingData epochs:epochs mb_size:batchSize eta:eta test_data:self.testData];
}

@end
