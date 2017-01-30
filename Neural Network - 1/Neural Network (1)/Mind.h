 //
//  Mind.h
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "NeuralMath.h"
#import "Neuron.h"

struct Coordinate {
    int x;
    int y;
};

struct tuple {
    float input;
    float output;
};

@interface Mind : NSObject

//instance properties

@property int layerCount;

@property double targetValue;

@property double outputSum;

@property double outputSumError;

@property double deltaOutputSum;

@property (nonatomic, strong) NSMutableArray <NSMutableArray <Neuron *>*>* network;

@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSNumber *>*>* adjMatrix;

//instance methods

- (instancetype)init:(NSArray *)array;

-(void)setIputs:(NSArray *)inputs;

-(void)randomWeightAllLayers;

-(void)addInputLayer:(NSMutableArray *)array;

-(void)forwardPropagation;

-(void)backwardPropagation;

-(void)insertLayer:(int)count;

@end
