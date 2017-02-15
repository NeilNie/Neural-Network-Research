//
//  Network.h
//  Handwriting
//
//  Created by Yongyang Nie on 2/9/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "YCMatrix.h"
#import "Tuple.h"

@interface Network : NSObject

@property int num_bias;

@property int num_layers;

@property (strong, nonatomic) NSArray *sizes;

@property (strong, nonatomic) NSMutableArray <Matrix *>*weights;

@property (strong, nonatomic) NSMutableArray <Matrix*>*bias;

/*! The list ``sizes`` contains the number of neurons in the respective layers of the network.  For example, if the list
 was [2, 3, 1] then it would be a three-layer network, with the first layer containing 2 neurons, the second layer 3 neurons,
 and the third layer 1 neuron.  The biases and weights for the network are initialized randomly, using a Gaussian
 distribution with mean 0, and variance 1.  Note that the first
 layer is assumed to be an input layer, and by convention we
 won't set any biases for those neurons, since biases are only
 ever used in computing the outputs from later layers.
 */
- (instancetype)init:(NSArray *)sizes;

/*! Return the number of test inputs for which the neural network outputs the correct result. Note that the neural
 network's output is assumed to be the index of whichever neuron in the final layer has the highest activation.
 */
-(int)evaluate:(NSMutableArray *)test_data;

-(Matrix *)feedforward:(Matrix *)a;

/*! 
 @brief Return a tuple ``(nabla_b, nabla_w)`` representing the gradient for the cost function C_x.  ``nabla_b`` and
 ``nabla_w`` are layer-by-layer lists of numpy arrays, similar to ``self.biases`` and ``self.weights``."
 
 @param x input
 @param y desired output
 @return Return a tuple (nabla_b, nabla_w)
 
 */
-(Tuple *)backprop:(Matrix *)x y:(Matrix *)y;

/*!
 @brief Update the network's weights and biases by applying gradient descent using backpropagation to a single mini batch.
 The ``mini_batch`` is a list of tuples ``(x, y)``, and ``eta``
 is the learning rate.
 
 @param mini_batch number of inputs
 @param eta number of hidden neurons
 
 @discussion This is a important component in the gradient descent process.
 */

-(void)update_mini_batch:(NSMutableArray *)mini_batch eta:(double)eta;

/*!
 @brief Train the neural network using mini-batch stochastic gradient descent.  The ``training_data`` is a list of tuples
 ``(x, y)`` representing the training inputs and the desired outputs.  The other non-optional parameters are
 self-explanatory.  If ``test_data`` is provided then the network will be evaluated against the test data after each
 epoch, and partial progress printed out.  This is useful for tracking progress, but slows things down substantially.
 
 @param training_data training data
 @param epochs number of epochs
 @param mini_batch_size number of epochs
 @param eta number of epochs
 @param test_data number of epochs
 
 @discussion For the mathmatical proves of gradient descent please http://sebastianruder.com/optimizing-gradient-descent/
 */

-(void)SGD:(NSMutableArray *)training_data
    epochs:(int)epochs
   mb_size:(int)mini_batch_size
       eta:(double)eta
 test_data:(NSMutableArray *)test_data;

@end
