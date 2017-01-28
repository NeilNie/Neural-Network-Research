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
        self.layerCount = (int)array.count;
        [NeuralMath fillMat:self.adjMatrix h:[self matSize:array] w:[self matSize:array]];
        [self construct:array];
    }
    return self;
}

#pragma mark - Instance Method

-(void)updateValueAt:(NSString *)key{
    
}

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
        float w = [NeuralMath sigmoid:arc4random()%10];
        for (Neuron *n in layer)
            for (Neuron *t in nlayer)
                [self addConnection:n toNeuron:t weight:w];
    }
    
}

#pragma mark - Private Helper

-(int)matSize:(NSArray *)array{
#warning lack implementation
    return 0;
}

-(void)addConnection:(Neuron *)from toNeuron:(Neuron *)to weight:(float)weight{
    
    if (weight > 1)
        @throw [NSException exceptionWithName:@"Neural Network Data Error" reason:@"Weight of neural network is > 1" userInfo:nil];
    
    if (from) {
        [from.connections setObject:[NSNumber numberWithFloat:weight] forKey:[to description]];
    }else{
        from.connections = [NSMutableDictionary dictionary];
        [from.connections setObject:[NSNumber numberWithInt:weight] forKey:[to description]];
    }

    if (to) {
        [to.connections setObject:[NSNumber numberWithInt:weight] forKey:[from description]];
    }else{
        to.connections = [NSMutableDictionary dictionary];
        [to.connections setObject:[NSNumber numberWithInt:weight] forKey:[from description]];
    }
}

-(void)construct:(NSArray *)array{
    
    for (NSNumber *n in array) {
        NSMutableArray *layer = [NSMutableArray array];
        for (int x = 0; x < n.intValue; x++) {
            Neuron *neuron = [[Neuron alloc] initWithValue:0.00];
            [layer addObject:neuron];
        }
        [self.network addObject:layer];
    }
}

@end
