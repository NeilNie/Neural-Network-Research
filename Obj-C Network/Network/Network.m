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

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"execution time: %f", -[startTime timeIntervalSinceNow])

@implementation Network

/*
 A module to implement the stochastic gradient descent learning
 algorithm for a feedforward neural network.  Gradients are calculated
 using backpropagation.  Note that I have focused on making the code
 simple, easily readable, and easily modifiable.  It is not optimized,
 and omits many desirable features.*/

- (instancetype)init:(NSArray *)sizes{
    
    self = [super init];
    if (self) {

        self.num_layers = (int)sizes.count;
        self.sizes = sizes;
        self.num_bias = self.num_layers - 1;
        
        self.bias = [NSMutableArray array];
        for (int i = 1; i < self.num_layers; i++)
            [self.bias addObject:[Matrix randMatrixOfRows:[sizes[i] intValue] columns:1]];
        
        self.weights = [NSMutableArray array];
        for (int i = 0; i < sizes.count-1; i++){
            [self.weights addObject:[Matrix randMatrixOfRows:[sizes[i+1] intValue] columns:[sizes[i] intValue]]];
        }
    }
    return self;
}

-(Matrix *)feedforward:(Matrix *)a{
    //Return the output of the network if ``a`` is input.
    for (int i = 0; i < self.weights.count; i++)
        a = [self applySigmoid:[[self.weights[i] matrixByMultiplyingWithRight:a] matrixByAdding:self.bias[i]]];
    
    return a;
}

-(void)SGD:(NSMutableArray *)training_data epochs:(int)epochs mb_size:(int)mini_batch_size eta:(double)eta test_data:(NSMutableArray *)test_data{
    
    int n_test = (int)test_data.count;
    
    for (int i = 0; i < epochs; i++){
        
        // shuffle training_data
        [self shuffle:training_data];
        
        // create mini batches
        NSMutableArray *mini_batches = [NSMutableArray array];
        for (int x = 0; x < training_data.count; x+=mini_batch_size) {
            [mini_batches addObject:[training_data subarrayWithRange:NSMakeRange(x, mini_batch_size)]];
        }
        // loop through mini_batches, update with the batch
        for (NSMutableArray *mini_batch in mini_batches){
            [self update_mini_batch:mini_batch eta:eta];
        }
        NSLog(@"epoch: %i: %i / %i", i, [self evaluate:test_data], n_test);
    }
}

-(void)update_mini_batch:(NSMutableArray *)mini_batch eta:(double)eta{
    
    //nabla_b = [np.zeros(b.shape) for b in self.biases]
    NSMutableArray *nabla_b = [NSMutableArray array];
    for (int i = 0; i < self.bias.count; i++)
        [nabla_b addObject:[Matrix matrixOfRows:[(Matrix *)self.bias[i] rows] columns:[(Matrix *)self.bias[i] columns] value:0.00]];
    
    //nabla_w = [np.zeros(w.shape) for w in self.weights]
    NSMutableArray *nabla_w = [NSMutableArray array];
    for (Matrix *w in self.weights)
        [nabla_w addObject:[Matrix matrixOfRows:[w rows] columns:[w columns] value:0.00]];
    
    
    for (int x = 0; x < mini_batch.count; x++) {
        Tuple *t = [self backprop:[(Tuple *)mini_batch[x] first] y:[(Tuple *)mini_batch[x] second]];
        NSArray *delta_nabla_w = t.first;
        NSArray *delta_nabla_b = t.second;
        
        for (int j = 0; j < nabla_b.count; j++) //nb, dnb in zip(nabla_b, delta_nabla_b)
            [nabla_b[j] add:delta_nabla_b[j]];
        
        for (int z = 0; z < nabla_w.count; z++) //nw, dnw in zip(nabla_w, delta_nabla_w)
            [nabla_w[z] add:delta_nabla_w[z]];
        
        for (int l = 0; l < nabla_w.count; l++) //w, nw in zip(self.weights, nabla_w)
            [self.weights[l] subtract:[nabla_w[l] matrixByMultiplyingWithScalar:eta / (double)mini_batch.count]];
        
        //b, nb in zip(self.biases, nabla_b)
        //[b - (eta / (double)mini_batch.count) * nb];
        for (int w = 0; w < self.bias.count; w++)
            [self.bias[w] subtract:[nabla_b[w] matrixByMultiplyingWithScalar:eta / (double)mini_batch.count]];
    }
}

-(Tuple *)backprop:(Matrix *)x y:(Matrix *)y{
    
    //nabla_b = [np.zeros(b.shape) for b in self.biases]
    NSMutableArray *nabla_b = [NSMutableArray array];
    for (Matrix *b in self.bias)
        [nabla_b addObject:[Matrix matrixOfRows:[b rows] columns:[b columns] value:0.00]];
    
    //nabla_w = [np.zeros(w.shape) for w in self.weights]
    NSMutableArray *nabla_w = [NSMutableArray array];
    for (Matrix *w in self.weights)
        [nabla_w addObject:[Matrix matrixOfRows:[w rows] columns:[w columns] value:0.00]];
    
    
    // feedforward
    Matrix *activation = x;
    NSMutableArray <Matrix *>*activations = [NSMutableArray array]; // list to store all the activations, layer by layer
    NSMutableArray <Matrix *>*zs = [NSMutableArray array];          // list to store all the z vectors, layer by layer
    for (int i = 0; i < self.weights.count; i++){ //b, w in zip(self.biases, self.weights)
        Matrix *z = [[self.weights[i] matrixByMultiplyingWithRight:activation] matrixByAdding:self.bias[i]]; //z = np.dot(w, activation)+b
        [zs addObject:z];
        activation = [self applySigmoid:z];
        [activations addObject:activation];
    }
    
    // backward pass
    //delta = self.cost_derivative(activations[-1], y) * sigmoid_prime(zs[-1])
    //nabla_b[-1] = delta
    //nabla_w[-1] = np.dot(delta, activations[-2].transpose();
    Matrix *delta = [self :[self cost_derivative:activations.lastObject y:y] times:[self applySigmoidPrime:[zs objectAtIndex:zs.count-1]]];
    [nabla_b replaceObjectAtIndex:nabla_b.count-1 withObject:delta];
    [nabla_w replaceObjectAtIndex:nabla_w.count-1 withObject:[delta matrixByMultiplyingWithRight:[[activations objectAtIndex:activations.count-2] matrixByTransposing]]];
    
    // Note that the variable l in the loop below is used a little
    // Here, l = 1 means the last layer of neurons, l = 2 is the second-last layer, and so on.  It's a renumbering of the
    // scheme in the book, used here to take advantage of the fact that Python can use negative indices in lists.
    for (int i = self.num_layers-2; i <= 0; i--){
        Matrix *sp = [self applySigmoidPrime:zs[i]];
        //delta = self.weights[-l+1].transpose(), delta) * sp
        delta = [self :[[self.weights[i + 1] matrixByTransposing] matrixByMultiplyingWithRight:delta] times:sp];
        //nabla_b[-l] = delta
        [nabla_b replaceObjectAtIndex:i withObject:delta];
        //nabla_w[-l] = np.dot(delta, activations[-l-1].transpose())
        [nabla_w replaceObjectAtIndex:i withObject:[delta matrixByMultiplyingWithRight:[activations[i-1] matrixByTransposing]]];
    }
    return [[Tuple alloc] init:nabla_w object2:nabla_b];
}

-(int)evaluate:(NSMutableArray *)test_data{
    
    int correct = 0;
    for (int i = 0; i < test_data.count; i++){
        Matrix *m = [self feedforward:[[test_data objectAtIndex:i] first]];
        int result = [self largestIndex:[m array] count:10];
        int realResult = [self largestIndex:[(Matrix *)[(Tuple *)test_data[i] second] array] count:10];
        if (result == realResult) {
            correct++;
        }
    }
    return correct;
}

#pragma mark - Private Helpers

-(Matrix *) cost_derivative:(Matrix *)output_activations y:(Matrix *)y{
    //Return the vector of partial derivatives partial C_x partial a for the output activations.
    return [output_activations matrixBySubtracting:y];
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

-(int)largestIndex:(double *)array count:(int)count{
    
    float n = array[0];
    int index = 0;
    
    for (int i = 0; i < count; i++) {
        if (array[i] > n){
            index = i;
            n = array[i];
        }
    }
    return index;
}

-(Matrix *):(Matrix *)m1 times:(Matrix *)m2{
    
    if(m1.rows != m2.rows || m1.columns != m2.columns)
        @throw [NSException exceptionWithName:@"Matrices size error" reason:@"parameter matrices sizes have to be equal" userInfo:nil];
    
    Matrix *m = [Matrix matrixOfRows:m1.rows columns:m1.columns value:0.00];
    for (int i = 0; i < m1.rows; i++) {
        for (int x = 0; x < m1.columns; x++) {
            [m setValue:[m1 valueAtRow:i column:x] * [m2 valueAtRow:i column:x] row:i column:x];
        }
    }
    return m;
}

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

-(Matrix *)applyBias:(Matrix *)mat bias:(double)bias{
    
    for (int i = 0; i < mat.rows; i++) {
        for (int x = 0; x < mat.columns; x++)
            [mat setValue:[mat valueAtRow:i column:x] + bias row:i column:x];
    }
    return mat;
}

-(Matrix *)applySigmoid:(Matrix *)mat{
    
    for (int i = 0; i < mat.rows; i++) {
        for (int x = 0; x < mat.columns; x++)
            [mat setValue:[self sigmoid:[mat valueAtRow:i column:x]] row:i column:x];
    }
    return mat;
}

-(Matrix *)applySigmoidPrime:(Matrix *)mat{
    
    for (int i = 0; i < mat.rows; i++) {
        for (int x = 0; x < mat.columns; x++)
            [mat setValue:[self sigmoid_prime:[mat valueAtRow:i column:x]] row:i column:x];
    }
    return mat;
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
