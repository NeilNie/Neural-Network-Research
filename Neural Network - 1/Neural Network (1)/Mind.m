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

- (instancetype)init:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.network = [NSMutableArray array];
        self.adjMatrix = [NeuralMath fillMat:[self matSize:array] w:[self matSize:array]];;
        self.layerCount = (int)array.count;
        [self construct:array];
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

    for (int i = 0; i < self.layerCount - 1; i++) {
        
        NSMutableArray *layer = [self.network objectAtIndex:i];
        NSMutableArray *nlayer = [self.network objectAtIndex:i + 1];
        float w = [NeuralMath sigmoid:arc4random()%10 - 3/7];
        for (Neuron *n in layer)
            for (Neuron *t in nlayer)
                [self addConnection:n toNeuron:t weight:w];
    }
    
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
