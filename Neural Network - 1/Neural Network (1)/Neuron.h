//
//  Vertex.h
//  Word Ladder
//
//  Created by Yongyang Nie on 1/15/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Neuron : NSObject

#pragma mark - Instance Variables

@property double value;
@property int index;

- (instancetype)initWithValue:(float)v;

@end
