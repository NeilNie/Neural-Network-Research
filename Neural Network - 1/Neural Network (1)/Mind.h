//
//  Mind.h
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface Mind : NSObject

//instance properties

@property int layerCount;

@property double targetValue;

@property double outputSum;

@property double outputSumError;

@property double deltaOutputSum;

@property (nonatomic, strong) NSMutableArray <Node *>*input;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <Node *>*>* hidden;
@property (nonatomic, strong) NSMutableArray <Node *>*output;

//instance methods

-(void)forwardPropagation;

-(void)backwardPropagation;

-(void)insertLayer:(int)count;

-(void)addWeightFromVertex:(NSString *)key toLayer:(int)t withValues:(NSArray <NSNumber *>*)values;

-(void)updateWeightFromVertex:(NSString *)key toLayer:(int)t withValues:(NSArray <NSNumber *>*)values;

@end
