//
//  Vertex.m
//  Word Ladder
//
//  Created by Yongyang Nie on 1/15/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Neuron.h"

@implementation Neuron

- (instancetype)initWithValue:(float)v
{
    self = [super init];
    if (self) {
        self.connections = [NSMutableDictionary dictionary];
        self.value = v;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"connections: %@", [self.connections description]];
}

@end
