//
//  WritingTrainer.m
//  Handwriting
//
//  Created by Yongyang Nie on 2/4/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "WritingTrainer.h"

#if __has_feature(objc_arc)
#define MDLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define MDLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"execution time: %f", -[startTime timeIntervalSinceNow])

@implementation WritingTrainer

- (instancetype)initTrainer
{
    self = [super init];
    if (self) {
        
        NSData *trainImages = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Trainer/MNIST Data/train-images-idx3-ubyte"];
        NSData *trainLabels = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Trainer/MNIST Data/train-labels-idx1-ubyte"];
        NSData *testImages = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Trainer/MNIST Data/t10k-images-idx3-ubyte"];
        NSData *testLabels = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Trainer/MNIST Data/t10k-labels-idx1-ubyte"];
        
        if (!trainLabels || !trainImages || !testImages || !testLabels)
            @throw [NSException exceptionWithName:@"Constructor Failed" reason:@"Error retrieving data" userInfo:nil];
        
        CGSize imageSize = CGSizeMake(28, 28);
        int nPixels = imageSize.width * imageSize.height;
        
        self.imageArray = [NSMutableArray array];
        self.labelArray = [NSMutableArray array];
        self.testImageArray = [NSMutableArray array];
        self.testLabelArray = [NSMutableArray array];
        
        // Store image/label byte indices
        int imagePosition = 16; // Start after header info
        int labelPosition = 8;  // Start after header info
        
        for (int i = 0; i < 60000; i++) {
            
            if (i%10000 == 0 || i == 60000 - 1)
                [self.delegate updateLogText:[NSString stringWithFormat:@"%.2f %%", (float)i / 600.0]];
            
            //extract images
            uint8 *ints = calloc(nPixels, sizeof(uint8));
            [trainImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
            
            NSMutableArray *pixels  = [[NSMutableArray alloc] initWithCapacity:nPixels];
            for (int i = 0; i < nPixels; i++)
                [pixels addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
            
            //extract labels1
            uint8 *trainLabel = calloc(1, sizeof(uint8));
            [trainLabels getBytes:trainLabel range:NSMakeRange(labelPosition, 1)];
            [self.labelArray addObject:[NSNumber numberWithInt:trainLabel[0]]];
            [self.imageArray addObject:pixels];
            trainLabel = NULL;
            ints = NULL;
            
            // Extract test image/label if we're still in range
            if (i < 10000) {
                //extract images
                uint8 *ints = calloc(nPixels, sizeof(uint8));
                [testImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
                
                NSMutableArray *pixels  = [[NSMutableArray alloc] initWithCapacity:nPixels];
                for (int i = 0; i < nPixels; i++)
                    [pixels addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
                
                ints = NULL;
                [self.testImageArray addObject:pixels];
                
                // Extract labels
                uint8 *tli = calloc(1, sizeof(uint8));
                [testLabels getBytes:tli range:NSMakeRange(labelPosition, 1)];
                [self.testLabelArray addObject:[NSNumber numberWithInt:tli[0]]];
                tli = NULL;
            }
            imagePosition += nPixels;
            labelPosition++;
        }
        self.mind = [[Mind alloc] initWith:784 hidden:40 outputs:10 learningRate:0.8 momentum:0.0 hiddenWeights:nil outputWeights:nil];
    }
    return self;
}

-(void)train:(int)batchSize epochs:(int)epochs correctRate:(float)correctRate{
    
    TICK;
    int count = 0;
    float rate = 0.00;
    while (rate < correctRate) {
        
        [self shuffle:self.imageArray withArray:self.labelArray];

        for (int i = 0; i < batchSize; i++) {
            
            NSMutableArray *batch = [NSMutableArray arrayWithArray:self.imageArray[i]];
            [self.mind forwardPropagation:batch];
            NSMutableArray *answer = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
            [answer replaceObjectAtIndex:[self.labelArray[i] intValue] withObject:@1];
            [self.mind backwardPropagation:answer];
        }
        rate = [self evaluate:10000] * 100;
        MDLog(@"%.2f", rate);
        count ++;
//        if (rate >= 93 && count%2 == 0)
//            [self.mind resetLearningRate:self.mind.learningRate * 0.9];
    }
    TOCK;
    NSLog(@"%i", count);
    [self showNotification];
    [MindStorage storeMind:self.mind path:@"/Users/Neil/Desktop/mindData"];
}

-(float)evaluate:(int)ntest{
    
    if (ntest == 0 || ntest > self.testLabelArray.count)
        @throw [NSException exceptionWithName:@"Invalid parameter" reason:@"Number of tests is not valid. " userInfo:nil];
    
    int correct = 0;
    for (int i = 0; i < ntest; i++) {
        
        NSMutableArray *image = [NSMutableArray arrayWithArray:self.testImageArray[i]];
        int result = [self largestIndex:[self.mind forwardPropagation:image] count:10];
        int answer = [self.testLabelArray[i] intValue];
        
        if (result == answer)
            correct++;
    }
    return (float)correct / (float)ntest;
}

-(void)getMindWithPath:(NSString *)path{
    
    self.mind = [MindStorage getMind:path];
}

#pragma mark - Private Helpers

- (void)showNotification{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Finished Training";
    notification.informativeText = @"The neural network has finished training";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

-(int)largestIndex:(float *)array count:(int)count{
    
    float n = array[0];
    int index = 0;
    
    for (int i = 0; i < count; i++) {
        if (array[i] > n){
            index = i;
            n = array[i];
        }
    }
    return index;
}

- (void)shuffle:(NSMutableArray *)array{
    
    NSUInteger count = [array count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

- (void)shuffle:(NSMutableArray *)array1 withArray:(NSMutableArray *)array2{
    
    if (array1.count != array2.count)
        @throw [NSException exceptionWithName:@"Invalid parameter" reason:@"array1 count differs from array2 count" userInfo:nil];
    
    NSUInteger count = [array1 count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array1 exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        [array2 exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
