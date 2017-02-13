//
//  Network.m
//  Handwriting
//
//  Created by Yongyang Nie on 2/9/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Network.h"

#if __has_feature(objc_arc)
#define MDLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define MDLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

@implementation Network

/*
 
 A module to implement the stochastic gradient descent learning
 algorithm for a feedforward neural network.  Gradients are calculated
 using backpropagation.  Note that I have focused on making the code
 simple, easily readable, and easily modifiable.  It is not optimized,
 and omits many desirable features.*/

- (instancetype)init:(NSMutableArray *)sizes{
    
    self = [super init];
    if (self) {
        /*The list ``sizes`` contains the number of neurons in the
         respective layers of the network.  For example, if the list
         was [2, 3, 1] then it would be a three-layer network, with the
         first layer containing 2 neurons, the second layer 3 neurons,
         and the third layer 1 neuron.  The biases and weights for the
         network are initialized randomly, using a Gaussian
         distribution with mean 0, and variance 1.  Note that the first
         layer is assumed to be an input layer, and by convention we
         won't set any biases for those neurons, since biases are only
         ever used in computing the outputs from later layers.*/
        self.num_layers = (int)sizes.count;
        self.sizes = sizes;
        
        self.bias = calloc(self.num_layers - 1, sizeof(double));
        self.bias->bias = calloc(self.num_layers - 1, sizeof(double));
        for (int i = 0; i < self.num_layers-1; i++)
            self.bias->bias[i] = [self randf];
    
        self.weights = [NSMutableArray array];
        for (int i = 0; i < sizes.count-1; i++){
            Matrix *weight = [Matrix matrixOfRows:[sizes[i+1] intValue] columns:[sizes[i] intValue]];
            [self weightMat:weight];
            [self.weights addObject:weight];
        }
    }
    return self;
}

-(NSMutableArray *)feedforward:(NSMutableArray *)a{
    //Return the output of the network if ``a`` is input.
//    for (b, w in zip(self.biases, self.weights)){
//        a = sigmoid(np.dot(w, a)+b);
//    }
    return a;
}

-(void)SGD:(NSMutableArray *)training_data epochs:(int)epochs mb_size:(int)mini_batch_size eta:(double)eta test_data:(NSMutableArray *)test_data{
    
    /*Train the neural network using mini-batch stochastic
     gradient descent.  The ``training_data`` is a list of tuples
     ``(x, y)`` representing the training inputs and the desired
     outputs.  The other non-optional parameters are
     self-explanatory.  If ``test_data`` is provided then the
     network will be evaluated against the test data after each
     epoch, and partial progress printed out.  This is useful for
     tracking progress, but slows things down substantially.*/
    
    int n_test = (int)test_data.count;
    
    for (int i = 0; i < epochs; i++){
        
        // shuffle training_data
        [self shuffle:training_data];
        
        // create mini batches
        NSMutableArray *mini_batches = [NSMutableArray array];
        for (int i = 0; i < training_data.count; i+=mini_batch_size) {
            [mini_batches addObject:[training_data subarrayWithRange:NSMakeRange(i, mini_batch_size)]];
        }
        // loop through mini_batches, update with the batch
        for (NSMutableArray *mini_batch in mini_batches){
            [self update_mini_batch:mini_batch eta:eta];
        }
        NSLog(@"epoch: %i: %i / %i", i, [self evaluate:test_data], n_test);
    }
}

-(void)update_mini_batch:(NSMutableArray *)mini_batch eta:(double)eta{
    
    /*Update the network's weights and biases by applying
     gradient descent using backpropagation to a single mini batch.
     The ``mini_batch`` is a list of tuples ``(x, y)``, and ``eta``
     is the learning rate.
    NSMutableArray *nabla_b = [
               np.zeros(b.shape) for b in self.biases]
    
    NSMutableArray *nabla_w = [
               np.zeros(w.shape) for w in self.weights]
    
    for (x, y in mini_batch){
        delta_nabla_b, delta_nabla_w = self.backprop(x, y)
        nabla_b = [nb+dnb for nb, dnb in zip(nabla_b, delta_nabla_b)]
        nabla_w = [nw+dnw for nw, dnw in zip(nabla_w, delta_nabla_w)]
        
        self.weights = [w - (eta / len(mini_batch)) * nw for w, nw in zip(self.weights, nabla_w)]
        self.biases = [b - (eta / len(mini_batch)) * nb for b, nb in zip(self.biases, nabla_b)]
    }*/
}

-(NSMutableArray *)backprop:(NSMutableArray *)x y:(NSMutableArray *)y{
    
    /*Return a tuple ``(nabla_b, nabla_w)`` representing the
     gradient for the cost function C_x.  ``nabla_b`` and
     ``nabla_w`` are layer-by-layer lists of numpy arrays, similar
     to ``self.biases`` and ``self.weights``."
    NSMutableArray *nabla_b = [np.zeros(b.shape) for b in self.biases]
    NSMutableArray *nabla_w = [np.zeros(w.shape) for w in self.weights]
    
    // feedforward
    activation = x
    activations = [x] // list to store all the activations, layer by layer
    zs = []           // list to store all the z vectors, layer by layer
    for b, w in zip(self.biases, self.weights){
        z = np.dot(w, activation)+b
        zs.append(z)
        activation = sigmoid(z)
        activations.append(activation)
        
        // backward pass
        delta = self.cost_derivative(activations[-1], y) * sigmoid_prime(zs[-1])
        nabla_b[-1] = delta
        nabla_w[-1] = np.dot(delta, activations[-2].transpose())
        // Note that the variable l in the loop below is used a little
        // differently to the notation in Chapter 2 of the book.  Here,
        // l = 1 means the last layer of neurons, l = 2 is the
        // second-last layer, and so on.  It's a renumbering of the
        // scheme in the book, used here to take advantage of the fact
        // that Python can use negative indices in lists.
        for (l in range(2, self.num_layers)){
            z = zs[-l];
            sp = sigmoid_prime(z);
            delta = np.dot(self.weights[-l+1].transpose(), delta) * sp;
            nabla_b[-l] = delta;
            nabla_w[-l] = np.dot(delta, activations[-l-1].transpose());
            
        }
    }
    return nabla_b, nabla_w;*/
    return nil;
}

-(int)evaluate:(NSMutableArray *)test_data{
    /*Return the number of test inputs for which the neural
     network outputs the correct result. Note that the neural
     network's output is assumed to be the index of whichever
     neuron in the final layer has the highest activation.
    test_results = [(np.argmax(self.feedforward(x)), y)
                    for (x, y) in test_data]
    return sum(int(x == y) for (x, y) in test_results)*/
    return 0;
}

#pragma mark - Private Helpers

-(double) cost_derivative:(double)output_activations y:(double)y{
    //Return the vector of partial derivatives partial C_x partial a for the output activations.
    return (output_activations-y);
}

-(void)weightMat:(Matrix *)mat{
    
    for (int x = 0; x < mat.rows; x++) {
        for (int y = 0; y < mat.columns; y++)
            [mat setValue:[self randf] row:x column:y];
    }
}

-(void)printMat:(double *)mat size:(CGSize)size{
    
    for (int i = 0; size.height; i++) {
        double *r = &mat[i];
        [self print:r count:size.width];
    }
}

- (NSArray *)flatten:(NSArray *)array1 withArray:(NSArray *)array2
{
    NSMutableArray *flattened = [NSMutableArray new];
    NSUInteger array1Count = [array1 count];
    NSUInteger array2Count = [array2 count];
    NSUInteger i;
    for (i = 0; i < array1Count && i < array2Count; i++) {
        [flattened addObject:array1[i]];
        [flattened addObject:array2[i]];
    }
    NSArray *overflow = nil;
    NSUInteger overflowCount = 0;
    if (array1Count >= i) {
        overflow = array1;
        overflowCount = array1Count;
    } else if (array2Count >= i) {
        overflow = array2;
        overflowCount = array2Count;
    }
    if (overflow) {
        for (; i < overflowCount; i++)
            [flattened addObject:overflow[i]];
    }
    return flattened;
}

-(void)print:(double *)array count:(int)count{
    for (int i = 0; i < count; i++) {
        MDLog(@"%f", array[i]);
    }
}

- (void)shuffle:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

#pragma mark - Math helpers

-(double)randf{
    
    double range = 1 / sqrt([self.sizes[0] intValue]);
    uint32_t rangeInt = 2000000 * range;
    double randomdouble = (double)arc4random_uniform(rangeInt) - (rangeInt / 2);
    
    return randomdouble / 1000000;
}

-(double)sum:(NSMutableArray *)array{
    double sum = 0;
    for (NSNumber *number in array)
        sum+=number.doubleValue;
    return sum;
}

-(double)productSum:(NSMutableArray *)array{
    double product = 0;
    for (int i = 0; i < array.count-1; i++)
        product += [array[i] doubleValue] * [array[i+1] doubleValue];
    return product;
}
// Miscellaneous functions
-(double) sigmoid:(double)z{
    //The sigmoid function.
    return 1.0/(1.0+pow(M_E, -z));
}

-(double) sigmoid_prime:(double)z{
    //Derivative of the sigmoid function.
    return [self sigmoid:z]*(1-[self sigmoid:z]);
}

@end
