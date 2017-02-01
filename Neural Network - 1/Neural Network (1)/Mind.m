//
//  Mind.m
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Mind.h"

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
        self.mfLR = (1 - momentum) * learningRate;
        
        self.inputCache = [self fillArray:self.numInputs value:0.00];
        self.hiddenOutputCache = [self fillArray:self.numHiddenNodes value:0.00];
        self.outputCache = [self fillArray:outputs value:0.00];
        
        self.outputErrors = [self fillArray:self.numOutputs value:0.00];
        self.hiddenErrorSums = [self fillArray:self.numHiddenNodes value:0.00];
        self.hiddenErrors = [self fillArray:self.numHiddenNodes value:0.00];
        self.nOutputWeights = [self fillArray:self.numOutputWeights value:0.00];
        self.nHiddenWeights = [self fillArray:self.numOutputWeights value:0.00];
        
        //        self.outputErrorIndices = [NSMutableArray array];
        //        self.hiddenOutputIndices = [NSMutableArray array];
        //        for (int weightIndex = 0; weightIndex < self.numOutputWeights; weightIndex++){
        //            [self.outputErrorIndices addObject:[NSNumber numberWithFloat:weightIndex / self.numHiddenNodes]];
        //            [self.hiddenOutputIndices addObject:[NSNumber numberWithFloat:weightIndex % self.numHiddenNodes]];
        //        }
        //
        //        self.hiddenErrorIndices = [NSMutableArray array];
        //        self.inputIndices = [NSMutableArray array];
        //        for (int weightIndex = 0; weightIndex < self.numHiddenWeights; weightIndex++) {
        //            [self.hiddenErrorIndices addObject:[NSNumber numberWithFloat:weightIndex / self.numInputNodes]];
        //            [self.inputIndices addObject:[NSNumber numberWithFloat:weightIndex % self.numInputNodes]];
        //        }
        
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
    
    //varify valid data
    if(self.numInputs != (int)inputs.count)
        @throw [NSException exceptionWithName:@"Neural networkd data inconsistancy" reason:@"inputs.cout != self.numInputs" userInfo:nil];
    
    [inputs insertObject:[NSNumber numberWithFloat:1.0] atIndex:0];
    
    // Calculate the weighted sums for the hidden layer
    float *hiddenOutputCachef = [self convertToFloats:self.hiddenOutputCache];
    vDSP_mmul([self convertToFloats:self.hiddenWeights], 1, //input mat _A
              [self convertToFloats:self.inputCache], 1,    //input mat _B
              hiddenOutputCachef, 1,                              //result mat _C
              self.numHidden, 1, self.numInputNodes);       //size constraints
    
    [self convertToObjects:hiddenOutputCachef count:self.numHiddenNodes array:self.hiddenOutputCache];
    
    //apply activation functino to the calculated result
    [self applyActivation:self.hiddenOutputCache];
    
    //calculate the weighted sum for all output layer
    float *outputCachef = [self convertToFloats:self.outputCache];
    vDSP_mmul([self convertToFloats:self.outputWeights], 1,
              [self convertToFloats:self.outputCache], 1,
              outputCachef, 1,
              self.numOutputs, 1, self.numHidden);
    [self convertToObjects:outputCachef count:self.numOutputs array:self.hiddenOutputCache];
    
    [self applyActivation:self.outputCache];
    
    return self.outputCache;
}

/*
 
 
 // Calculate output errors
 
 // Calculate hidden errors
 
 // Update output weights
 for weightIndex in 0..<self.outputWeights.count {
 let offset = self.outputWeights[weightIndex] + (self.momentumFactor * (self.outputWeights[weightIndex] - self.previousOutputWeights[weightIndex]))
 let errorIndex = self.outputErrorIndices[weightIndex]
 let hiddenOutputIndex = self.hiddenOutputIndices[weightIndex]
 let mfLRErrIn = self.mfLR * self.outputErrorsCache[errorIndex] * self.hiddenOutputCache[hiddenOutputIndex]
 self.newOutputWeights[weightIndex] = offset + mfLRErrIn
 }
 
 vDSP_mmov(outputWeights, &previousOutputWeights, 1, vDSP_Length(numOutputWeights), 1, 1)
 vDSP_mmov(newOutputWeights, &outputWeights, 1, vDSP_Length(numOutputWeights), 1, 1)
 
 // Update hidden weights
 for weightIndex in 0..<self.hiddenWeights.count {
 let offset = self.hiddenWeights[weightIndex] + (self.momentumFactor * (self.hiddenWeights[weightIndex]  - self.previousHiddenWeights[weightIndex]))
 let errorIndex = self.hiddenErrorIndices[weightIndex]
 let inputIndex = self.inputIndices[weightIndex]
 // Note: +1 on errorIndex to offset for bias 'error', which is ignored
 let mfLRErrIn = self.mfLR * self.hiddenErrorsCache[errorIndex + 1] * self.inputCache[inputIndex]
 self.newHiddenWeights[weightIndex] = offset + mfLRErrIn
 }
 
 vDSP_mmov(hiddenWeights, &previousHiddenWeights, 1, vDSP_Length(numHiddenWeights), 1, 1)
 vDSP_mmov(newHiddenWeights, &hiddenWeights, 1, vDSP_Length(numHiddenWeights), 1, 1)
 
 // Sum and return the output errors
 return self.outputErrorsCache.reduce(0, { (sum, error) -> Float in
 return sum + abs(error)
 })
 
 */

-(float)backwardPropagation:(NSMutableArray <NSNumber *>*)answer{
    
    //varify data
    if (answer.count != self.numOutputs)
        @throw [NSException exceptionWithName:@"Neural network data inconsistancy" reason:[NSString stringWithFormat:@"answer.count != self.numOutputs. answer.count should equal to %i", self.numOutputs] userInfo:nil];
    
    //----------------------------------------------------
    //calculate all the delta output sum, or output errors
    for (int i = 0; i < self.outputCache.count; i++)
        [self.outputErrors addObject:[NSNumber numberWithFloat:
                                      [NeuralMath sigmoidPrime:[[self.outputCache objectAtIndex:i] floatValue]] *
                                      ([[self.outputCache objectAtIndex:i] floatValue] - [[answer objectAtIndex:i] floatValue])]];
    
    //----------------------------------------------------
    //calculate hidden error
    float *hiddenErrorSumf = [self convertToFloats:self.hiddenErrorSums];
    vDSP_mmul([self convertToFloats:self.outputErrors], 1,
              [self convertToFloats:self.outputWeights], 1,
              hiddenErrorSumf, 1,
              1, self.numHiddenNodes, self.numOutputs);
    [self convertToObjects:hiddenErrorSumf count:self.numHiddenNodes array:self.hiddenErrorSums];
    
    for (int i = 0; i < self.hiddenErrorSums.count; i++)
        [self.hiddenErrors replaceObjectAtIndex:i withObject:
         [NSNumber numberWithFloat:[NeuralMath sigmoidPrime:
                                    [[self.hiddenOutputCache objectAtIndex:i] floatValue] *
                                    [[self.hiddenErrorSums objectAtIndex:i] floatValue]]]];
    
    //----------------------------------------------------
    //update all the weights
    
    return 0.00;
}

-(void)randomWeightAllLayers{
    
    self.hiddenWeights = [NSMutableArray array];
    for (int i = 0; i < self.numHiddenWeights; i++) {
        float f = ((float)rand() / RAND_MAX) * 10;
        [self.hiddenWeights addObject:[NSNumber numberWithFloat:f]];
    }
    
    self.outputWeights = [NSMutableArray array];
    for (int i = 0; i < self.numOutputs; i++) {
        float f = ((float)rand() / RAND_MAX) * 10;
        [self.outputWeights addObject:[NSNumber numberWithFloat:f]];
    }
    
}

-(void)setIputs:(NSArray *)inputs{
    
}

#pragma mark - Private Helper

-(void)applyActivation:(NSMutableArray <NSNumber *>*)inputs{
    
    for (int i = 0; i < inputs.count; i++) {
        NSNumber *postActivation = [NSNumber numberWithFloat:[NeuralMath sigmoid:[[inputs objectAtIndex:i] floatValue]]];
        [inputs replaceObjectAtIndex:i withObject:postActivation];
    }
}

-(float *)convertToFloats:(NSMutableArray *)array{
    
    float *f = malloc([array count] * sizeof(float));
    [self.hiddenWeights enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSNumber *number, NSUInteger i, BOOL *stop) {
        f[i] = [number floatValue];
    }];
    return f;
}

-(void)convertToObjects:(float *)floats count:(int)n array:(NSMutableArray <NSNumber *>*)array{
    
    for (int i = 0; i < n; i++) {
        [array addObject:[NSNumber numberWithFloat:floats[i]]];
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
