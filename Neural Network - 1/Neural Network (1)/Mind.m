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
        self.network = [NSMutableArray array];
        self.adjMatrix = [NeuralMath fillMat:MAX(hidden, inputs) w:MAX(hidden, inputs)];;
       
        self.numHiddenWeights = (hidden * (inputs + 1));
        self.numOutputWeights = (outputs * (hidden + 1));
        
        self.numInputs = inputs;
        self.numHidden = hidden;
        self.numOutputs = outputs;
        
        self.numInputNodes = inputs + 1;
        self.numHiddenNodes = hidden + 1;
        
        self.learningRate = learningRate;
        self.momentumFactor = momentum;
        self.mfLR = (1 - momentum) * learningRate;
        
        self.inputCache = [self fillArray:self.numInputs value:0.00];
        self.hiddenOutputCache = [self fillArray:self.numHiddenNodes value:0.00];
        self.outputCache = [self fillArray:outputs value:0.00];
        
        self.outputErrorsCache = [self fillArray:self.numOutputs value:0.00];
        self.hiddenErrorSumsCache = [self fillArray:self.numHiddenNodes value:0.00];
        self.hiddenErrorsCache = [self fillArray:self.numHiddenNodes value:0.00];
        self.nOutputWeights = [self fillArray:self.numOutputWeights value:0.00];
        self.nHiddenWeights = [self fillArray:self.numOutputWeights value:0.00];
        
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

-(void)forwardPropagation{
    
}

-(void)backwardPropagation{
    
}

-(void)insertLayer:(int)count{
    
}

-(void)randomWeightAllLayers{

//    for (int i = 0; i < self.layerCount - 1; i++) {
//        
//        NSMutableArray *layer = [self.network objectAtIndex:i];
//        NSMutableArray *nlayer = [self.network objectAtIndex:i + 1];
//        float w = [NeuralMath sigmoid:arc4random()%10 - 3/7];
//        for (Neuron *n in layer)
//            for (Neuron *t in nlayer)
//                [self addConnection:n toNeuron:t weight:w];
//    }
    
}
-(void)addInputLayer:(NSMutableArray *)array{
    [self.network addObject:array];
}

-(void)setIputs:(NSArray *)inputs{
    
    if (inputs.count != self.network.firstObject.count)
        @throw [NSException exceptionWithName:@"Neural Network data inconsistancy" reason:@"input counts differs from input layer neuron count" userInfo:nil];
    
    for (int i = 0; i < inputs.count; i++) {
        Neuron *n = [self.network.firstObject objectAtIndex:i];
        n.value = [[inputs objectAtIndex:i] doubleValue];
    }
}

#pragma mark - Private Helper

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

-(void)addConnection:(Neuron *)from toNeuron:(Neuron *)to weight:(float)weight{
    NSMutableArray *row = [self.adjMatrix objectAtIndex:from.index];
    [row replaceObjectAtIndex:to.index withObject:[NSNumber numberWithFloat:weight]];
    
    NSMutableArray *row2 = [self.adjMatrix objectAtIndex:to.index];
    [row2 replaceObjectAtIndex:from.index withObject:[NSNumber numberWithFloat:weight]];
}

-(void)construct:(NSArray *)array{
    
    int index = 0;
    for (NSNumber *n in array) {
        NSMutableArray *layer = [NSMutableArray array];
        for (int x = 0; x < n.intValue; x++) {
            Neuron *neuron = [[Neuron alloc] initWithValue:0.00];
            neuron.index = index;
            index++;
            [layer addObject:neuron];
        }
        [self.network addObject:layer];
    }
}

#pragma mark - Override

-(NSString *)description{
    return [NSString stringWithFormat:@"network: %@ \n adjMatrix: %@", [self.network description], [self.adjMatrix description]];
}

@end
