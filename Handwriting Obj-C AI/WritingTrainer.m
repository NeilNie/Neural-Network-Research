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

@implementation WritingTrainer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSData *trainImages = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/train-images-idx3-ubyte"];
        NSData *trainLabels = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/train-labels-idx1-ubyte"];
        NSData *testImages = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/t10k-images-idx3-ubyte"];
        NSData *testLabels = [NSData dataWithContentsOfFile:@"/Users/YongyangNie/Desktop/Neural Network Research/Handwriting Obj-C AI/MNIST Data/t10k-labels-idx1-ubyte"];
        
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
            uint8 *ints = calloc(nPixels, sizeof(uint8));
            [trainImages getBytes:ints range:NSMakeRange(imagePosition, 784)];
            
            NSMutableArray *pixels  = [[NSMutableArray alloc] initWithCapacity:nPixels];
            for (int i = 0; i < nPixels; i++)
                [pixels addObject:[NSNumber numberWithFloat:(float)ints[i] / 255]];
            
            ints = NULL;
            [self.imageArray addObject:pixels];
            
            //extract labels1
            uint8 *trainLabel = calloc(1, sizeof(uint8));
            [trainLabels getBytes:trainLabel range:NSMakeRange(labelPosition, 1)];
            [self.labelArray addObject:[NSNumber numberWithInt:trainLabel[0]]];
            trainLabel = NULL;
            
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
        self.mind = [[Mind alloc] initWith:784 hidden:30 outputs:10 learningRate:0.1 momentum:0.9 weights:nil];
    }
    return self;
}

-(void)train:(int)batchSize epochs:(int)epochs correctRate:(float)correctRate{
    
    int x = 0;
    float rate = 0.00;
    while (rate < correctRate) {
        
        [self shuffle:self.imageArray withArray:self.labelArray];
        
        for (int i = 0; i < batchSize; i++) {
            
            NSMutableArray *batch = [NSMutableArray arrayWithArray:self.imageArray[i]];
            [self.mind forwardPropagation:batch];
            
            NSMutableArray *answer = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
            [answer replaceObjectAtIndex:[self.labelArray[i] intValue] withObject:self.labelArray[i]];
            [self.mind backwardPropagation:answer];
        }
        x++;
        rate = [self evaluate:100] * 100;
        MDLog(@"%i: %.1f%%", x, rate);
    }
}

-(float)evaluate:(int)ntest{
    
    if (ntest == 0 || ntest >= self.testLabelArray.count)
        @throw [NSException exceptionWithName:@"Invalid parameter" reason:@"Number of tests is not valid. " userInfo:nil];
    
    int correct = 0;
    for (int i = 0; i < ntest; i++) {
        
        NSMutableArray *batch = [NSMutableArray arrayWithArray:self.testImageArray[i]];
        int result = [self largestIndex:[self.mind forwardPropagation:batch] count:10];
        int answer = [self.testLabelArray[i] intValue];
        
        if (result == answer)
            correct++;
    }
    [self shuffle:self.testImageArray withArray:self.testLabelArray];
    return (float)correct / (float)ntest;
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

- (NSImage *)getImage:(uint8 *)buffer width:(int)width height:(int)height{
    
    char* rgba = (char*)malloc(width*height*4);
    for(int i=0; i < width*height; ++i) {
        rgba[4*i] = buffer[3*i];
        rgba[4*i+1] = buffer[3*i+1];
        rgba[4*i+2] = buffer[3*i+2];
        rgba[4*i+3] = 0;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(buffer,
                                                       width,
                                                       height,
                                                       8, // bitsPerComponent
                                                       4*width, // bytesPerRow
                                                       colorSpace,
                                                       kCGImageAlphaNoneSkipLast);
    
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("image.png"), kCFURLPOSIXPathStyle, false);
    
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:CGSizeMake(28, 28)];
    
    CFStringRef type = kUTTypePNG; // or kUTTypeBMP if you like
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, type, 1, 0);
    
    CGImageDestinationAddImage(dest, cgImage, 0);
    
    CFRelease(cgImage);
    CFRelease(bitmapContext);
    CGImageDestinationFinalize(dest);
    free(rgba);
    return image;
}

@end
