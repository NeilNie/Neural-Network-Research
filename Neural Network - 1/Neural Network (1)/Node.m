//
//  Vertex.m
//  Word Ladder
//
//  Created by Yongyang Nie on 1/15/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Node.h"

@implementation Node

- (instancetype)initWithKey:(NSString *)key value:(float)v
{
    self = [super init];
    if (self) {
        self.connections = [NSMutableArray array];
        self.value = v;
        self.key = key;
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        self.connections = [NSMutableArray array];
        self.value = 0.00;
        self.key = key;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"key: %@ \n connections: %@", self.key, [self.connections description]];
}

@end
