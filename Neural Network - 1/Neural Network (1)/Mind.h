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

/// The number of input nodes to the network (read only).
@property int numInputs;
/// The number of hidden nodes in the network (read only).
@property int numHidden;
/// The number of output nodes from the network (read only).
@property int numOutputs;

/// The 'learning rate' parameter to apply during backpropagation.
/// This parameter may be safely tuned at any time, except for during a backpropagation cycle.
@property float learningRate;


/// The 'momentum factor' to apply during backpropagation.
/// This parameter may be safely tuned at any time, except for during a backpropagation cycle.
@property float momentumFactor;


/**
 The following private properties are allocated once during initializtion, in order to prevent frequent
 memory allocations for temporary variables during the update and backpropagation cycles.
 Some known properties are computed in advance in order to to avoid casting, integer division
 and modulus operations inside loops.
 */

/// (1 - momentumFactor) * learningRate.
/// Used frequently during backpropagation.
@property float mfLR;

/// The number of input nodes, INCLUDING the bias node.
@property int numInputNodes;
/// The number of hidden nodes, INCLUDING the bias node.
@property int numHiddenNodes;
/// The total number of weights connecting all input nodes to all hidden nodes.
@property int numHiddenWeights;
/// The total number of weights connecting all hidden nodes to all output nodes.
@property int numOutputWeights;

/// The current weights leading into all of the hidden nodes, serialized in a single array. float[]
@property (strong, nonatomic) NSArray <NSNumber *>* hiddenWeights;
/// The weights leading into all of the hidden nodes from the previous round of training, serialized in a single array.
/// Used for applying momentum during backpropagation. [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* previousHiddenWeights;
/// The current weights leading into all of the output nodes, serialized in a single array. [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* outputWeights;
/// The weights leading into all of the output nodes from the previous round of training, serialized in a single array. [Float]
/// Used for applying momentum during backpropagation.
@property (strong, nonatomic) NSArray <NSNumber *>* previousOutputWeights;

/// The most recent set of inputs applied to the network.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* inputCache;
/// The most recent outputs from each of the hidden nodes.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenOutputCache;
/// The most recent output from the network. [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* outputCache;

/// Temporary storage while calculating hidden errors, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* hiddenErrorSumsCache;
/// Temporary storage while calculating hidden errors, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* hiddenErrorsCache;
/// Temporary storage while calculating output errors, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* outputErrorsCache;
/// Temporary storage while updating hidden weights, for use during backpropagation. [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* nHiddenWeights; ///new hidden weights
/// Temporary storage while updating output weights, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* nOutputWeights; ///new hidden weights

/// The output error indices corresponding to each output weight.  = [Int]()
@property (strong, nonatomic) NSMutableArray <NSNumber *>* outputErrorIndices;
/// The hidden output indices corresponding to each output weight.  = [Int]()
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenOutputIndices;
/// The hidden error indices corresponding to each hidden weight.  = [Int]()
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenErrorIndices;
/// The input indices corresponding to each hidden weight.  = [Int]()
@property (strong, nonatomic) NSMutableArray <NSNumber *>* inputIndices;

@property (nonatomic, strong) NSMutableArray <NSMutableArray <Neuron *>*>* network;

@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSNumber *>*>* adjMatrix;

//instance methods

- (instancetype)initWith:(int)inputs
                  hidden:(int)hidden
                 outputs:(int)outputs
            learningRate:(float)learningRate
                momentum:(float)momentum
                 weights:(NSArray <NSNumber *>*)weights;

-(void)setIputs:(NSArray *)inputs;

-(void)randomWeightAllLayers;

-(void)addInputLayer:(NSMutableArray *)array;

-(NSArray <NSNumber *>*)predict:(NSArray <NSNumber *>*)inputs;

-(void)backwardPropagation;

-(void)insertLayer:(int)count;

@end
