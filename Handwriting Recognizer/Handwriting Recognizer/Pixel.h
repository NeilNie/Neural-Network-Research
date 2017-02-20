//
//  Pixel.h
//  Handwriting Recognizer
//
//  Created by Yongyang Nie on 2/20/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pixel : NSObject

@property UInt8 a;
@property UInt8 r;
@property UInt8 g;
@property UInt8 b;

- (instancetype)init:(UInt8)a r:(UInt8)r g:(UInt8)g b:(UInt8)b;

@end
