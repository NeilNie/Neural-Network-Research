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

typedef struct {
    double *bias;
}bias;

@interface Network : NSObject

@property int num_layers;

@property (strong, nonatomic) NSMutableArray *sizes;

@property (strong, nonatomic) NSMutableArray <Matrix *>*weights;

@property bias *bias;

- (instancetype)init:(NSMutableArray *)sizes;

-(int)evaluate:(NSMutableArray *)test_data;

-(NSMutableArray *)feedforward:(NSMutableArray *)a;

-(NSMutableArray *)backprop:(NSMutableArray *)x y:(NSMutableArray *)y;

-(void)update_mini_batch:(NSMutableArray *)mini_batch eta:(double)eta;

-(void)SGD:(NSMutableArray *)training_data
    epochs:(int)epochs
   mb_size:(int)mini_batch_size
       eta:(double)eta
 test_data:(NSMutableArray *)test_data;

@end
