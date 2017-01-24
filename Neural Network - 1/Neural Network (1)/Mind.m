//
//  Mind.m
//  Simple Neural Network
//
//  Created by Yongyang Nie on 1/25/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Mind.h"

@implementation Mind

#pragma mark - Constructors

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = [[NSMutableArray alloc] init];
        self.input = [[NSMutableArray alloc] init];
        self.output = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Instance Method

-(void)updateValueAt:(NSString *)key{
    
}

-(void)forwardPropagation{
    
}

-(void)backwardPropagation{
    
}

-(void)insertLayer:(int)count{
    
    for (int i = 0; i < count; i++) {
        [self.graph addVertex:[NSString stringWithFormat:@"%i-%i", self.layerCount, i]];
    }
    self.layerCount++;
}

-(void)addWeightFromVertex:(NSString *)key toLayer:(int)t withValues:(NSArray <NSNumber *>*)values{
    
    Vertex *v = [self.graph getVertex:key];
    for (NSNumber *n in values) {
        [v.connections addObject:@{}]
    }
}

-(void)updateWeightFromVertex:(NSString *)key toLayer:(int)t withValues:(NSArray <NSNumber *>*)values{
    
}

@end
