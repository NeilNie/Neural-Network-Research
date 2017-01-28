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
@property (nonatomic, strong) NSMutableDictionary *connections; //@{@"key1": @"weight1"},
                                                           //@{@"key2": @"weight2"},

- (instancetype)initWithValue:(float)v;

@end
