//
//  Pixel.m
//  Handwriting Recognizer
//
//  Created by Yongyang Nie on 2/20/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Pixel.h"

@implementation Pixel

- (instancetype)init:(UInt8)a r:(UInt8)r g:(UInt8)g b:(UInt8)b
{
    self = [super init];
    if (self) {
        self.a = a;
        self.r = r;
        self.g = g;
        self.b = b;
    }
    return self;
}

@end
