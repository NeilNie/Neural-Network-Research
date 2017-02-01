 //
//  Mind.h
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

/*!
 @header ViewController.h
 
 @brief This is the header file where the super-code is contained.
 
 The following  properties are allocated once during initializtion, in order to prevent frequent
 memory allocations for temporary variables during the update and backpropagation cycles.
 Some known properties are computed in advance in order to to avoid casting, integer division
 and modulus operations inside loops.
 
 There are also methods declared in this file. Refer to their documentations.
 
 @author Yongyang Nie
 @copyright  2017 Yongyang Nie
 @version    17.01.31
 */

#import <Foundation/Foundation.h>
#import <stdio.h>
#import <Accelerate/Accelerate.h>
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

#pragma mark - Properties

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
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenWeights;
/// The weights leading into all of the hidden nodes from the previous round of training, serialized in a single array.
/// Used for applying momentum during backpropagation. [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* previousHiddenWeights;
/// The current weights leading into all of the output nodes, serialized in a single array. [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* outputWeights;
/// The weights leading into all of the output nodes from the previous round of training, serialized in a single array. [Float]
/// Used for applying momentum during backpropagation.
@property (strong, nonatomic) NSArray <NSNumber *>* previousOutputWeights;

///// The most recent set of inputs applied to the network.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* inputCache;
///// The most recent output of all hidden nodes.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenOutputCache;
///// The most recent output from the network. [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* outputCache;

/// Temporary storage while calculating hidden errors, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenErrorSums;
/// Temporary storage while calculating hidden errors, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenErrors;
/// Temporary storage while calculating output errors, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSMutableArray <NSNumber *>* outputErrors;
/// Temporary storage while updating hidden weights, for use during backpropagation. [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* nHiddenWeights; ///new hidden weights
/// Temporary storage while updating output weights, for use during backpropagation.  [Float]
@property (strong, nonatomic) NSArray <NSNumber *>* nOutputWeights; ///new hidden weights

///// The output error indices corresponding to each output weight.  = [Int]()
//@property (strong, nonatomic) NSMutableArray <NSNumber *>* outputErrorIndices;
///// The hidden output indices corresponding to each output weight.  = [Int]()
//@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenOutputIndices;
///// The hidden error indices corresponding to each hidden weight.  = [Int]()
//@property (strong, nonatomic) NSMutableArray <NSNumber *>* hiddenErrorIndices;
///// The input indices corresponding to each hidden weight.  = [Int]()
//@property (strong, nonatomic) NSMutableArray <NSNumber *>* inputIndices;


#pragma mark - Instance Methods

/*!
 @brief This is the constructor for the neural network.
 
 @param inputs number of inputs
 @param hidden number of hidden neurons
 @param outputs number of outpus
 @param learningRate the learning rate of the network, a good start is 0.7
 @param momentum the momentum of the learing, play around with this number, a good estimate is
 @param weights initialize the network with weights from other network or from the past. If initializing new network, set it as null
 
 @return instancetype
 
 @discussion This is a comprehensive constructor. Further improve this parameter so that it can reinitialize neural networks from the past. Also be able to add multiple hidden layers in the middle.
 */
- (instancetype)initWith:(int)inputs
                  hidden:(int)hidden
                 outputs:(int)outputs
            learningRate:(float)learningRate
                momentum:(float)momentum
                 weights:(NSArray <NSNumber *>*)weights;

/*!
 @brief Use the network to evaluate some output.
 @param inputs An array of `Float`s. Each element corresponding to one input node. Note: inputs.count has == to self.numInputNodes
 @return NSMutableArray <NSNumber *>* as an array of `Float`s
 @exception inputs has to equal to self.numInputs
 @discussion Propagates the given inputs through the neural network, returning the network's output. While the network is evaluating, it will add a bias node. The result will be cached.
 */
-(NSMutableArray <NSNumber *>*)forwardPropagation:(NSMutableArray <NSNumber *>*)inputs;

/**
 Backward propagation method in this feed forward neural network. Trains the network by comparing its most recent output to the given 'answers', adjusting the network's weights as needed.
 @param answer The desired output for the most recent update to the network, as an array<nsnumber<float>>.
 @returns float calculated error
 @exception Answer and self.numOutputs has to be the same.
 */
-(float)backwardPropagation:(NSMutableArray <NSNumber *>*)answer;

-(void)setIputs:(NSArray *)inputs;

-(void)randomWeightAllLayers;


@end
