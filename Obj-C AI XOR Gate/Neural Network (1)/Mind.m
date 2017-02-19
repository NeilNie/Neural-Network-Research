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
        
        self.numHiddenWeights = (hidden * (inputs));
        self.numOutputWeights = (outputs * (hidden));
        
        self.learningRate = learningRate;
        self.momentumFactor = momentum;
        self.mfLR = (1.0 - momentum) * learningRate;
        
        self.io = calloc(self.numInputs + self.numOutputs + self.numHidden, sizeof(float));
        self.io->inputs = calloc(self.numInputs, sizeof(float));
        self.io->outputs = calloc(self.numOutputs, sizeof(float));
        self.io->hiddenOutputs = calloc(self.numHidden, sizeof(float));
        
        self.errors = calloc(self.numOutputs + self.numHidden * 2, sizeof(float));
        self.errors->outputErrors = calloc(self.numOutputs, sizeof(float));
        self.errors->hiddenErrors = calloc(self.numHidden, sizeof(float));
        self.errors->hiddenErrorSums = calloc(self.numHidden, sizeof(float));

        self.weights = calloc(self.numHiddenWeights * 2 + self.numOutputWeights * 2, sizeof(float));
        self.weights->hiddenWeights = calloc(self.numHiddenWeights, sizeof(float));
        self.weights->previousHiddenWeights = calloc(self.numHiddenWeights, sizeof(float));
        self.weights->outputWeights = calloc(self.numOutputWeights, sizeof(float));
        self.weights->previousOutputWeights = calloc(self.numOutputWeights, sizeof(float));
        self.weights->hiddenWeightsNew = calloc(self.numHiddenWeights, sizeof(float));
        self.weights->outputWeightsNew = calloc(self.numOutputWeights, sizeof(float));
        
        self.outputErrorIndices = [NSMutableArray array];
        self.hiddenOutputIndices = [NSMutableArray array];
        for (int weightIndex = 0; weightIndex < self.numOutputWeights; weightIndex++){
            [self.outputErrorIndices addObject:[NSNumber numberWithFloat:weightIndex / self.numHidden]];
            [self.hiddenOutputIndices addObject:[NSNumber numberWithFloat:weightIndex % self.numHidden]];
        }
        
        self.hiddenErrorIndices = [NSMutableArray array];
        self.inputIndices = [NSMutableArray array];
        for (int weightIndex = 0; weightIndex < self.numHiddenWeights; weightIndex++) {
            [self.hiddenErrorIndices addObject:[NSNumber numberWithFloat:weightIndex / self.numInputs]];
            [self.inputIndices addObject:[NSNumber numberWithFloat:weightIndex % self.numInputs]];
        }
        
        if (weights) {
            if (weights.count != self.numHiddenWeights + self.numOutputWeights){
                NSLog(@"FFNN initialization error: Incorrect number of weights provided. Randomized weights will be used instead.");
                [self randomWeightAllLayers];
                return nil;
            }
        } else {
            [self randomWeightAllLayers];
        }
    }
    return self;
}

#pragma mark - Instance Method 


-(float *)forwardPropagation:(NSMutableArray <NSNumber *>*)inputs{
    
    //--------------------------------------------------
    //varify valid data
    if(self.numInputs != (int)inputs.count)
        @throw [NSException exceptionWithName:@"Neural networkd data inconsistancy" reason:@"inputs.cout != self.numInputs" userInfo:nil];
    
    for (int i = 0; i < self.numInputs; i++) {
        self.io->inputs[i] = [inputs[i] floatValue];
    }
    //--------------------------------------------------
    // Calculate the weighted sums for the hidden layer

    vDSP_mmul(self.weights->hiddenWeights, 1,                        //input mat _A
              self.io->inputs, 1,                           //input mat _B
              self.io->hiddenOutputs, 1,                    //result mat _C
              self.numHidden, 1, self.numInputs);   //size constraints

    
    //--------------------------------------------------
    //apply activation functino to the calculated result
    [self applyActivitionIsOutput:NO];
    
    //--------------------------------------------------

    vDSP_mmul(self.weights->outputWeights, 1,
              self.io->hiddenOutputs, 1,
              self.io->outputs, 1,
              self.numOutputs, 1, self.numInputs);
    
    [self applyActivitionIsOutput:YES];
    
    return self.io->outputs;
}

-(void)backwardPropagation:(NSMutableArray <NSNumber *>*)answer{
    
    //varify data
    if (answer.count != self.numOutputs)
        @throw [NSException exceptionWithName:@"Neural network data inconsistancy" reason:[NSString stringWithFormat:@"answer.count != self.numOutputs. answer.count should equal to %i", self.numOutputs] userInfo:nil];
    
    //----------------------------------------------------
    //calculate all the delta output sum, or output errors
    for (int i = 0; i < self.numOutputs; i++)
        self.errors->outputErrors[i] = [NeuralMath sigmoidPrime:self.io->outputs[i]] * ([[answer objectAtIndex:i] floatValue] - self.io->outputs[i]);;
    
    //----------------------------------------------------
    //calculate hidden error
    vDSP_mmul(self.errors->outputErrors, 1,
              self.weights->outputWeights, 1,
              self.errors->hiddenErrorSums, 1,
              1, self.numHidden, self.numOutputs);

    for (int errorIndex = 0; errorIndex < self.numHidden; errorIndex++)
        self.errors->hiddenErrors[errorIndex] = [NeuralMath sigmoidPrime:self.io->hiddenOutputs[errorIndex]] * self.errors->hiddenErrorSums[errorIndex];
    
    //----------------------------------------------------
    //update all output the weights
    for (int x = 0; x < self.numOutputWeights; x++) {
        
        float offset = self.weights->outputWeights[x] + (self.momentumFactor * (self.weights->outputWeights[x] - self.weights->previousOutputWeights[x]));
        int errorIndex = [self.outputErrorIndices[x] intValue];
        int hiddenOutputIndex = [self.hiddenOutputIndices[x] intValue];
        float mfLRErrIn = self.mfLR * self.errors->outputErrors[errorIndex] * self.io->hiddenOutputs[hiddenOutputIndex];
        self.weights->outputWeightsNew[x] = offset + mfLRErrIn;
    }
    
    vDSP_mmov(self.weights->outputWeights, self.weights->previousOutputWeights, 1, self.numOutputWeights, 1, 1);
    vDSP_mmov(self.weights->outputWeightsNew, self.weights->outputWeights, 1, self.numOutputWeights, 1, 1);
    
    //----------------------------------------------------
    //update all hidden the weights
    for (int i = 0; i < self.numHiddenWeights; i++) {
        
        float offset = self.weights->hiddenWeights[i] + (self.momentumFactor * (self.weights->hiddenWeights[i] - self.weights->previousHiddenWeights[i]));
        int errorIndex = [self.hiddenErrorIndices[i] intValue];
        int inputIndex = [self.inputIndices[i] intValue];
        // Note: +1 on errorIndex to offset for bias 'error', which is ignored
        float mfLRErrIn = self.mfLR * self.errors->hiddenErrors[errorIndex] * self.io->inputs[inputIndex];
        self.weights->hiddenWeightsNew[i] = offset + mfLRErrIn;
    }

    vDSP_mmov(self.weights->hiddenWeights, self.weights->previousHiddenWeights, 1, self.numHiddenWeights, 1, 1);
    vDSP_mmov(self.weights->hiddenWeightsNew, self.weights->hiddenWeights, 1, self.numHiddenWeights, 1, 1);
}

-(float)costFunction:(NSMutableArray <NSNumber *>*)forward desired:(NSMutableArray *)desired{
    
    [self forwardPropagation:forward];
    float sum = 0.00;
    for (int i = 0; self.numHidden; i++) {
        sum += pow([desired[i] floatValue] - self.io->outputs[i], 2.0);
    }
    float J = 0.5*sum;
    return J;
}

-(void)costFunctionPrime:(NSMutableArray <NSNumber *>*)inputs desired:(NSMutableArray *)desired{
    
    //Compute derivative with respect to W and W2 for a given X and y:
//    [self forwardPropagation:inputs];
//    
//    for (int i = 0; <#condition#>; i++) {
//        <#statements#>
//    }
//    delta3 = np.multiply(-(y-self.yHat), self.sigmoidPrime(self.z3))
//    dJdW2 = np.dot(self.a2.T, delta3)
//    
//    delta2 = np.dot(delta3, self.W2.T)*self.sigmoidPrime(self.z2)
//    dJdW1 = np.dot(X.T, delta2)
//    
//    return dJdW1, dJdW2
}

-(void)sigmoid:(float *)array{
    
}

-(void)sigmoidPrime:(float *)array{
    
}

-(void)train:(NSArray <NSArray <NSNumber*>*>*)inputs
      answer:(NSArray <NSArray <NSNumber *>*>*)answers
  testInputs:(NSArray <NSArray <NSNumber*>*>*)testInputs
 testOutputs:(NSArray <NSArray <NSNumber *>*>*)testOutput
   threshold:(float)threshold
{
    int i = 0;
    while (YES) {

        i++;
        for (int i = 0; i < inputs.count; i++) {
            [self forwardPropagation:[NSMutableArray arrayWithArray:[inputs objectAtIndex:i]]];
            [self backwardPropagation:[NSMutableArray arrayWithArray:[answers objectAtIndex:i]]];
        }
        
        float error = [self evaluate:testInputs expected:testOutput];
        printf("error %f\n", error);
        if (fabs(error) < threshold) {
            NSLog(@"number of epochs: %i", i);
            break;
        }
    }
}


-(float)evaluate:(NSArray <NSArray <NSNumber*>*>*)testInputs expected:(NSArray <NSArray <NSNumber*>*>*)answer{
    
    float total = 0.00;
    for (int x = 0; x < testInputs.count; x++) {
        
        NSMutableArray *input = [NSMutableArray arrayWithArray:[testInputs objectAtIndex:x]];
        float *result = [self forwardPropagation:[NSMutableArray arrayWithArray:input]];
        float error = 0.0;
        for (int i = 0; i < self.numOutputs; i++) {
            error = (result[i] - [[[answer objectAtIndex:x] objectAtIndex:i] floatValue]) + error;
        }
        error = error / self.numOutputs;
        total = total + fabs(error);
    }
    total = total / testInputs.count;
    
    return total;
}

-(void)randomWeightAllLayers{

    for (int i = 0; i < self.numHiddenWeights; i++) {
        
        float range = 1 / sqrt(self.numInputs);
        uint32_t rangeInt = 2000000 * range;
        float randomFloat = (float)arc4random_uniform(rangeInt) - (rangeInt / 2);
        self.weights->hiddenWeights[i] = randomFloat / 1000000;
    }
    
    for (int i = 0; i < self.numOutputWeights; i++) {
        
        float range = 1 / sqrt(self.numInputs);
        uint32_t rangeInt = 2000000 * range;
        float randomFloat = (float)arc4random_uniform(rangeInt) - (rangeInt / 2);
        self.weights->outputWeights[i] = randomFloat / 1000000;
    }
}

#pragma mark - Private Helper


-(void)applyActivitionIsOutput:(BOOL)isOutput{
    
    if (isOutput) {
        for (int i = 0; i < self.numOutputs; i++)
            self.io->outputs[i] = [NeuralMath sigmoid:self.io->outputs[i]];
    }else{
        for (int i = self.numHidden; i > 0; i--)
            self.io->hiddenOutputs[i] = [NeuralMath sigmoid:self.io->hiddenOutputs[i - 1]];
        //self.io->hiddenOutputs[0] = 1.00;
    }
}

-(void)convertToObjects:(float *)floats count:(int)n array:(NSMutableArray <NSNumber *>*)array{
    for (int i = 0; i < n; i++)
        [array replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:floats[i]]];
}

-(NSMutableArray <NSNumber *>*)fillArray:(int)count value:(float)value{
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++)
        [array addObject:[NSNumber numberWithFloat:value]];
    return array;
}

-(int)matSize:(NSArray *)array{
    
    int total = 0;
    for (NSNumber *n in array)
        total += n.intValue;
    return total;
}

-(void)print:(float *)array count:(int)count{
    for (int i = 0; i < count; i++)
        MDLog(@"%f", array[i]);
}

#pragma mark - Override

-(NSString *)description{
    return nil;
}

@end
