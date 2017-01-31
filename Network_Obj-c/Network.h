//
//  Network.h
//  Network_Obj-c
//
//  Created by Yongyang Nie on 1/30/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface Network : NSObject

@property BNNSFilter *hidden_layer;
@property BNNSFilter *output_layer;
@property BNNSFilter *input_layer;

-(float)predict:(float[])inputs;

@end
