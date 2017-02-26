//
//  Tuple.m
//  Network
//
//  Created by Yongyang Nie on 2/12/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Tuple.h"

@implementation Tuple

- (instancetype)init:(id)object1 object2:(id)object2;
{
    self = [super init];
    if (self) {
        self.first= object1;
        self.second = object2;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"first: %@, second: %@", [self.first description], [self.second description]];
}

@end
