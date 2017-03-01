//
//  NeuralMath.h
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @header NeuralMath.h
 @class NeuralMath
 
 Important calculation for the neural network
 */
@interface NeuralMath : NSObject

/**
 @brief Apply sigmoid function to a given value
 */
+(float)sigmoid:(float)x;

/**
 @brief Apply sigmoid prime function to a given value
 */
+(float)sigmoidPrime:(float)y;

/**
 @brief Fill a matrix with zero as value. 
 */
+(NSMutableArray *__nonnull)fillMat:(int)h w:(int)w;

@end
