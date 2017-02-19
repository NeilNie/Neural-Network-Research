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
        
        
        NSData *trainImages = [NSData dataWithContentsOfFile:@"/Users/Neil/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/train-images-idx3-ubyte"];
        NSData *trainLabels = [NSData dataWithContentsOfFile:@"/Users/Neil/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/train-labels-idx1-ubyte"];
        NSData *testImages = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"train-images-idx3-ubyte" ofType:nil]];
        NSData *testLabels = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"train-labels-idx1-ubyte" ofType:nil]];
        
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
                NSLog(@"%.2f %%", (float)i / 600.0);
            
            //extract images
            uint8_t *ints = calloc(nPixels, sizeof(uint8_t));
            [trainImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
            
            NSMutableArray *pixels  = [[NSMutableArray alloc] initWithCapacity:nPixels];
            for (int i = 0; i < nPixels; i++)
                [pixels addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
            
            ints = NULL;
            [self.imageArray addObject:pixels];
            
            //extract labels1
            uint8_t *trainLabel = calloc(1, sizeof(uint8_t));
            [trainLabels getBytes:trainLabel range:NSMakeRange(labelPosition, 1)];
            [self.labelArray addObject:[NSNumber numberWithInt:trainLabel[0]]];
            trainLabel = NULL;
            
            // Extract test image/label if we're still in range
            if (i < 10000) {
                //extract images
                uint8_t *ints = calloc(nPixels, sizeof(uint8_t));
                [testImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
                
                NSMutableArray *pixels  = [[NSMutableArray alloc] initWithCapacity:nPixels];
                for (int i = 0; i < nPixels; i++)
                    [pixels addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
                
                ints = NULL;
                [self.testImageArray addObject:pixels];
                
                // Extract labels
                uint8_t *tli = calloc(1, sizeof(uint8_t));
                [testLabels getBytes:tli range:NSMakeRange(labelPosition, 1)];
                [self.testLabelArray addObject:[NSNumber numberWithInt:tli[0]]];
                tli = NULL;
            }
            imagePosition += nPixels;
            labelPosition++;
        }
        self.mind = [[Mind alloc] initWith:784 hidden:35 outputs:10 learningRate:0.1 momentum:0.9 lmbda:0.00 hiddenWeights:nil outputWeights:nil];
    }
    return self;
}

-(void)train:(int)batchSize epochs:(int)epochs correctRate:(float)correctRate{
    
    int cnt = 0;
    float rate = 0.00;
    while (rate < correctRate) {
        
        TICK;
        
        [self shuffle:self.imageArray withArray:self.labelArray];
        
        for (int i = 0; i < batchSize; i++) {

            if (i%10000 == 0 || i == 60000 - 1)
                NSLog(@"%.2f %%", (float)i / 600.0);
            
            NSMutableArray *batch = [NSMutableArray arrayWithArray:self.imageArray[i]];
            [self.mind forwardPropagation:batch];
            NSMutableArray *answer = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
            [answer replaceObjectAtIndex:[self.labelArray[i] intValue] withObject:self.labelArray[i]];
            [self.mind backwardPropagation:answer];
        }
        rate = [self evaluate:10000] * 100;
        cnt ++;
        
//        if (rate >= 80) {
//            [self.mind ResetLearningRate:self.mind.learningRate * 0.75];
//            [self.mind ResetMomentum:self.mind.momentumFactor * 0.75];
//        }
        TOCK;
    }
    [MindStorage storeMind:self.mind path:@"/Users/Neil/Desktop/mindData"];
}

-(void)SGD:(NSMutableArray *)training_data epochs:(int)epochs mini_batch_size:(int)mini_batch_size eta:(float)eta test_data:(NSMutableArray *)test_data{
    
    /*Train the neural network using mini-batch stochastic
     gradient descent.  The "training_data" is a list of tuples
     "(x, y)" representing the training inputs and the desired
     outputs.  The other non-optional parameters are
     self-explanatory.  If "test_data" is provided then the
     network will be evaluated against the test data after each
     epoch, and partial progress printed out.  This is useful for
     tracking progress, but slows things down substantially.*/
}

-(void)update_mini_batch:(NSMutableArray *)mini_batch eta:(float)eta{
    
    /*Update the network's weights and biases by applying
     gradient descent using backpropagation to a single mini batch.
     The "mini_batch" is a list of tuples "(x, y)", and "eta"
     is the learning rate.
     
     nabla_b = [np.zeros(b.shape) for b in self.biases]
     nabla_w = [np.zeros(w.shape) for w in self.weights]
     for x, y in mini_batch:
     delta_nabla_b, delta_nabla_w = self.backprop(x, y)
     nabla_b = [nb+dnb for nb, dnb in zip(nabla_b, delta_nabla_b)]
     nabla_w = [nw+dnw for nw, dnw in zip(nabla_w, delta_nabla_w)]
     self.weights = [w-(eta/len(mini_batch))*nw
     for w, nw in zip(self.weights, nabla_w)]
     self.biases = [b-(eta/len(mini_batch))*nb
     for b, nb in zip(self.biases, nabla_b)] */
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
    [self shuffle:self.testImageArray withArray:self.testLabelArray];
    NSLog(@"%i / %i", correct, ntest);
    return (float)correct / (float)ntest;
}

-(void)getMindWithPath:(NSString *)path{
    
    self.mind = [MindStorage getMind:path];
}

#pragma mark - Private Helpers

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

- (void)shuffle:(NSMutableArray *)array
{
    
    NSUInteger count = [array count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

- (void)shuffle:(NSMutableArray *)array1 withArray:(NSMutableArray *)array2
{
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
