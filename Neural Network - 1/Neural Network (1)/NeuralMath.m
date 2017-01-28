//
//  NeuralMath.m
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "NeuralMath.h"

@implementation NeuralMath

+(float)sigmoid:(float)x{
    return 1 / (1 + pow(M_E, -x));
}

+(float)sigmoidPrime:(float)x{
    return pow(M_E, -x) / pow(1 + pow(M_E, -x), 2);
}

+(void)fillMat:(NSMutableArray <NSMutableArray *>* __nonnull)mat h:(int)h w:(int)w{
#warning lack implementation
}

+(NSMutableArray <NSMutableArray *>*)multiply:(NSMutableArray <NSMutableArray *>*)mat1 toMat:(NSMutableArray <NSMutableArray *>*)mat2{
    
    return nil;
}

@end
