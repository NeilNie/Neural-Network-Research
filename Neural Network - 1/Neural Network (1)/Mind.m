//
//  Mind.m
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Mind.h"

#if __has_feature(objc_arc)
#define MDLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define MDLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif


@implementation Mind

#pragma mark - Constructors

- (instancetype)initWith:(int)inputs hidden:(int)hidden outputs:(int)outputs learningRate:(float)learningRate momentum:(float)momentum weights:(NSArray <NSNumber *>*)weights
{
    self = [super init];
    if (self) {
        
        self.numInputs = inputs;
        self.numHidden = hidden;
        self.numOutputs = outputs;
        
        self.numHiddenWeights = (hidden * (inputs + 1));
        self.numOutputWeights = (outputs * (hidden + 1));
        
        self.numInputNodes = inputs + 1;
        self.numHiddenNodes = hidden + 1;
        
        self.learningRate = learningRate;
        self.momentumFactor = momentum;
        self.mfLR = (1.0 - momentum) * learningRate;
        
        self.inputCache = [self fillArray:self.numInputNodes value:0.00];
        self.hiddenOutputCache = [self fillArray:self.numHiddenNodes value:0.00];
        self.outputCache = [self fillArray:outputs value:0.00];
        
        self.outputErrors = [self fillArray:self.numOutputs value:0.00];
        self.hiddenErrorSums = [self fillArray:self.numHiddenNodes value:0.00];
        self.hiddenErrors = [self fillArray:self.numHiddenNodes value:0.00];
        self.outputWeightsNew = [self fillArray:self.numOutputWeights value:0.00];
        self.hiddenWeightsNew = [self fillArray:self.numHiddenWeights value:0.00];
        
        self.outputErrorIndices = [NSMutableArray array];
        self.hiddenOutputIndices = [NSMutableArray array];
        for (int weightIndex = 0; weightIndex < self.numOutputWeights; weightIndex++){
            [self.outputErrorIndices addObject:[NSNumber numberWithFloat:weightIndex / self.numHiddenNodes]];
            [self.hiddenOutputIndices addObject:[NSNumber numberWithFloat:weightIndex % self.numHiddenNodes]];
        }
        
        self.hiddenErrorIndices = [NSMutableArray array];
        self.inputIndices = [NSMutableArray array];
        for (int weightIndex = 0; weightIndex < self.numHiddenWeights; weightIndex++) {
            [self.hiddenErrorIndices addObject:[NSNumber numberWithFloat:weightIndex / self.numInputNodes]];
            [self.inputIndices addObject:[NSNumber numberWithFloat:weightIndex % self.numInputNodes]];
        }
        
        self.hiddenWeights = [self fillArray:self.numHiddenWeights value:0.00];
        self.previousHiddenWeights = self.hiddenWeights;
        self.outputWeights = [self fillArray:self.numHiddenNodes value:0.00];
        self.previousOutputWeights = self.outputWeights;
        
        if (weights) {
            if (weights.count != self.numHiddenWeights + self.numOutputWeights){
                NSLog(@"FFNN initialization error: Incorrect number of weights provided. Randomized weights will be used instead.");
                [self randomWeightAllLayers];
                return nil;
            }
            //            self.hiddenWeights = Array(weights[0..<self.numHiddenWeights])
            //            self.outputWeights = Array(weights[self.numHiddenWeights..<weights.count])
        } else {
            [self randomWeightAllLayers];
        }
    }
    return self;
}

#pragma mark - Instance Method

-(NSMutableArray <NSNumber *>*)forwardPropagation:(NSMutableArray <NSNumber *>*)inputs{
    
    //--------------------------------------------------
    //varify valid data
    if(self.numInputs != (int)inputs.count)
        @throw [NSException exceptionWithName:@"Neural networkd data inconsistancy" reason:@"inputs.cout != self.numInputs" userInfo:nil];
    
    [inputs insertObject:[NSNumber numberWithFloat:1.00f] atIndex:0];
    self.inputCache = inputs;
    //--------------------------------------------------
    // Calculate the weighted sums for the hidden layer
    float *hiddenWeightsf = [self convertToFloats:self.hiddenWeights];
    float *inputCachef = [self convertToFloats:self.inputCache];
    float *hiddenOutputCachef = [self convertToFloats:self.hiddenOutputCache];
    
    vDSP_mmul(hiddenWeightsf, 1,                        //input mat _A
              inputCachef, 1,                           //input mat _B
              hiddenOutputCachef, 1,                    //result mat _C
              self.numHidden, 1, self.numInputNodes);   //size constraints
    [self convertToObjects:hiddenOutputCachef count:(int)self.hiddenOutputCache.count array:self.hiddenOutputCache];
    
    hiddenWeightsf = NULL;
    inputCachef = NULL;
    hiddenOutputCachef = NULL;
    
    //--------------------------------------------------
    //apply activation functino to the calculated result
    [self applyActivitionIsOutput:NO];
    
    //--------------------------------------------------
    //calculate the weighted sum for all output layer
    float *outputWeightsf = [self convertToFloats:self.outputWeights];
    float *outputCachef = [self convertToFloats:self.outputCache];
    float *hiddenOutputCache2 = [self convertToFloats:self.hiddenOutputCache];
    
    vDSP_mmul(outputWeightsf, 1,
              hiddenOutputCache2, 1,
              outputCachef, 1,
              self.numOutputs, 1, self.numHiddenNodes);
    [self convertToObjects:outputCachef count:self.numOutputs array:self.outputCache];
    
    outputWeightsf = NULL;
    inputCachef = NULL;
    hiddenOutputCache2 = NULL;
    
    [self applyActivitionIsOutput:YES];
    
    return self.outputCache;
}

-(float)backwardPropagation:(NSMutableArray <NSNumber *>*)answer{
    
    //varify data
    if (answer.count != self.numOutputs)
        @throw [NSException exceptionWithName:@"Neural network data inconsistancy" reason:[NSString stringWithFormat:@"answer.count != self.numOutputs. answer.count should equal to %i", self.numOutputs] userInfo:nil];
    
    //----------------------------------------------------
    //calculate all the delta output sum, or output errors
    for (int i = 0; i < self.outputCache.count; i++){
        float f = [NeuralMath sigmoidPrime:[[self.outputCache objectAtIndex:i] floatValue]] * ([[answer objectAtIndex:i] floatValue] - [[self.outputCache objectAtIndex:i] floatValue]);
        [self.outputErrors replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:f]];
    }
    //----------------------------------------------------
    //calculate hidden error
    float *hiddenErrorSumf = [self convertToFloats:self.hiddenErrorSums];
    float *outWeightsf = [self convertToFloats:self.outputWeights];
    float *outputErrors = [self convertToFloats:self.outputErrors];
    vDSP_mmul(outputErrors, 1,
              outWeightsf, 1,
              hiddenErrorSumf, 1,
              1, self.numHiddenNodes, self.numOutputs);
    [self convertToObjects:hiddenErrorSumf count:self.numHiddenNodes array:self.hiddenErrorSums];
    outputErrors = NULL;
    outWeightsf = NULL;
    hiddenErrorSumf = NULL;
    
    for (int errorIndex = 0; errorIndex < self.hiddenErrorSums.count; errorIndex++){
        NSNumber *n = [NSNumber numberWithFloat:
                       [NeuralMath sigmoidPrime:[[self.hiddenOutputCache objectAtIndex:errorIndex] floatValue]] *
                       [[self.hiddenErrorSums objectAtIndex:errorIndex] floatValue]];
        [self.hiddenErrors replaceObjectAtIndex:errorIndex withObject:n];
    }
    
    //----------------------------------------------------
    //update all output the weights
    for (int x = 0; x < self.outputWeights.count; x++) {
        
        float offset = [self.outputWeights[x] floatValue] + (self.momentumFactor * ([self.outputWeights[x] floatValue] - [self.previousOutputWeights[x] floatValue]));
        int errorIndex = [self.outputErrorIndices[x] intValue];
        int hiddenOutputIndex = [self.hiddenOutputIndices[x] intValue];
        float mfLRErrIn = self.mfLR * [self.outputErrors[errorIndex] floatValue] * [self.hiddenOutputCache[hiddenOutputIndex] floatValue];
        //float mfLRErrIn = [self.outputErrors[errorIndex] floatValue];
        [self.outputWeightsNew replaceObjectAtIndex:x withObject:[NSNumber numberWithFloat:offset + mfLRErrIn]];
    }
    
    float *outputWeightsf = [self convertToFloats:self.outputWeights];
    float *previousOutputWeightsf = [self convertToFloats:self.previousOutputWeights];
    float *newOutputWeights = [self convertToFloats:self.outputWeightsNew];
    
    vDSP_mmov(outputWeightsf, previousOutputWeightsf, 1, self.numOutputWeights, 1, 1);
    vDSP_mmov(newOutputWeights, outputWeightsf, 1, self.numOutputWeights, 1, 1);
    
    [self convertToObjects:outputWeightsf count:self.numOutputWeights array:self.outputWeights];
    [self convertToObjects:previousOutputWeightsf count:self.numOutputWeights array:self.previousOutputWeights];
    
    outputWeightsf = NULL;
    previousOutputWeightsf = NULL;
    newOutputWeights = NULL;
    
    //    MDLog(@"output error %@", [[self.outputErrors valueForKey:@"description"] componentsJoinedByString:@", "]);
    //    MDLog(@"previous output weights %@", [[self.previousOutputWeights valueForKey:@"description"] componentsJoinedByString:@", "]);
    //    MDLog(@"current output weights %@", [[self.outputWeights valueForKey:@"description"] componentsJoinedByString:@", "]);
    
    //----------------------------------------------------
    //update all hidden the weights
    for (int i = 0; i < self.hiddenWeights.count; i++) {
        
        float offset = [self.hiddenWeights[i] floatValue] + (self.momentumFactor * ([self.hiddenWeights[i] floatValue]  - [self.previousHiddenWeights[i] floatValue]));
        int errorIndex = [self.hiddenErrorIndices[i] intValue];
        int inputIndex = [self.inputIndices[i] intValue];
        // Note: +1 on errorIndex to offset for bias 'error', which is ignored
        float mfLRErrIn = self.mfLR * [self.hiddenErrors[errorIndex + 1] floatValue] * [self.inputCache[inputIndex] floatValue];
        //float mfLRErrIn = [self.hiddenErrors[errorIndex + 1] floatValue];
        [self.hiddenWeightsNew replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:offset + mfLRErrIn]];
    }
    
    float *hiddenWeightsf = [self convertToFloats:self.hiddenWeights];
    float *previousHiddenWeightsf = [self convertToFloats:self.previousHiddenWeights];
    float *newHiddenWeights = [self convertToFloats:self.hiddenWeightsNew];
    
    vDSP_mmov(hiddenWeightsf, previousHiddenWeightsf, 1, self.numHiddenWeights, 1, 1);
    vDSP_mmov(newHiddenWeights, hiddenWeightsf, 1, self.numHiddenWeights, 1, 1);
    
    [self convertToObjects:hiddenWeightsf count:self.numHiddenWeights array:self.hiddenWeights];
    [self convertToObjects:previousHiddenWeightsf count:self.numHiddenWeights array:self.previousHiddenWeights];
    
    hiddenWeightsf = NULL;
    previousHiddenWeightsf = NULL;
    newHiddenWeights = NULL;
    
    //    MDLog(@"hidden error: %@", [[self.hiddenErrors valueForKey:@"description"] componentsJoinedByString:@", "]);
    //    MDLog(@"previous hidden weight %@", [[self.previousHiddenWeights valueForKey:@"description"] componentsJoinedByString:@", "]);
    //    MDLog(@"current hidden weights %@", [[self.hiddenWeights valueForKey:@"description"] componentsJoinedByString:@", "]);
    
    return [[self.outputErrors firstObject] floatValue];
}

-(void)train:(NSArray <NSArray <NSNumber*>*>*)inputs
      answer:(NSArray <NSArray <NSNumber *>*>*)answers
  testInputs:(NSArray <NSArray <NSNumber*>*>*)testInputs
 testOutputs:(NSArray <NSArray <NSNumber *>*>*)testOutput
   threshold:(float)threshold
{
    int i = 0;
    while (YES) {
        
        NSDate *methodStart = [NSDate date];
        
        i++;
        for (int i = 0; i < inputs.count; i++) {
            [self forwardPropagation:[NSMutableArray arrayWithArray:[inputs objectAtIndex:i]]];
            [self backwardPropagation:[NSMutableArray arrayWithArray:[answers objectAtIndex:i]]];
        }
        
        float error = [self evaluate:testInputs expected:testOutput];
        printf("calcuated error %f \n ", error);
        if (fabs(error) < threshold) {
            NSLog(@"number of epochs: %i", i);
            break;
        }
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        //NSLog(@"executionTime = %f", executionTime);
    }
}


-(float)evaluate:(NSArray <NSArray <NSNumber*>*>*)testInputs expected:(NSArray <NSArray <NSNumber*>*>*)answer{
    
    float total = 0.00;
    for (int x = 0; x < testInputs.count; x++) {
        
        NSMutableArray *input = [NSMutableArray arrayWithArray:[testInputs objectAtIndex:x]];
        NSMutableArray *result = [self forwardPropagation:[NSMutableArray arrayWithArray:input]];
        float error = 0.0;
        for (int i = 0; i < result.count; i++) {
            error = ([[result objectAtIndex:i] floatValue] - [[[answer objectAtIndex:x] objectAtIndex:i] floatValue]) + error;
        }
        error = error / result.count;
        total = total + fabs(error);
    }
    total = total / testInputs.count;
    
    return total;
}

-(void)randomWeightAllLayers{
    
    self.hiddenWeights = [NSMutableArray array];
    for (int i = 0; i < self.numHiddenWeights; i++) {
        
        float range = 1 / sqrt(self.numInputNodes);
        uint32_t rangeInt = 2000000 * range;
        float randomFloat = (float)arc4random_uniform(rangeInt) - (rangeInt / 2);
        
        [self.hiddenWeights addObject:[NSNumber numberWithFloat:randomFloat / 1000000]];
    }
    
    self.outputWeights = [NSMutableArray array];
    for (int i = 0; i < self.numOutputWeights; i++) {
        
        float range = 1 / sqrt(self.numInputNodes);
        uint32_t rangeInt = 2000000 * range;
        float randomFloat = (float)arc4random_uniform(rangeInt) - (rangeInt / 2);
        
        [self.outputWeights addObject:[NSNumber numberWithFloat:randomFloat / 1000000]];
    }
    
}

#pragma mark - Private Helper

-(void)applyActivitionIsOutput:(BOOL)isOutput{
    
    if (isOutput) {
        for (int i = 0; i < self.outputCache.count; i++) {
            NSNumber *postAct = [NSNumber numberWithFloat:[NeuralMath sigmoid:[self.outputCache[i] floatValue]]];
            [self.outputCache replaceObjectAtIndex:i withObject:postAct];
        }
    }else{
        for (int i = self.numHidden; i > 0; i--) {
            NSNumber *postActivation = [NSNumber numberWithFloat:[NeuralMath sigmoid:[self.hiddenOutputCache[i - 1] floatValue]]];
            [self.hiddenOutputCache replaceObjectAtIndex:i withObject:postActivation];
        }
        [self.hiddenOutputCache replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:1.00f]];
    }
}

-(float *)convertToFloats:(NSMutableArray *)array{
    
    float *f = malloc([array count] * sizeof(float));
    [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSNumber *number, NSUInteger i, BOOL *stop) {
        f[i] = [number floatValue];
    }];
    return f;
}

-(void)convertToObjects:(float *)floats count:(int)n array:(NSMutableArray <NSNumber *>*)array{
    
    for (int i = 0; i < n; i++) {
        [array replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:floats[i]]];
    }
}

-(NSMutableArray <NSNumber *>*)fillArray:(int)count value:(float)value{
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSNumber numberWithFloat:value]];
    }
    return array;
}

-(int)matSize:(NSArray *)array{
    
    int total = 0;
    for (NSNumber *n in array) {
        total += n.intValue;
    }
    return total;
}

#pragma mark - Override

-(NSString *)description{
    return nil;
}

@end
