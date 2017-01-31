//
//  Network.m
//  Network_Obj-c
//
//  Created by Yongyang Nie on 1/30/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Network.h"

@implementation Network

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        BNNSFilterParameters filter_params;
        bzero(&filter_params, sizeof(filter_params));
        
        BNNSActivation activation;
        bzero(&activation, sizeof(activation));
        activation.function = BNNSActivationFunctionSigmoid;
        
        //stuff
        
        BNNSVectorDescriptor input_desc;
        bzero(&input_desc, sizeof(input_desc));
        input_desc.size = 2;
        input_desc.data_type = BNNSDataTypeFloat32;
        
        BNNSVectorDescriptor hidden_desc;
        bzero(&hidden_desc, sizeof(hidden_desc));
        hidden_desc.size = 2;
        hidden_desc.data_type = BNNSDataTypeFloat32;
        
        //self.hidden_layer = BNNSFilterCreateFullyConnectedLayer(&input_desc,
                                                           &hidden_desc, &input_to_hidden_params, &filter_params);
        if (self.hidden_layer == NULL) {
            NSLog(@"BNNSFilterCreateFullyConnectedLayer failed");
            return nil;
        }
    }
    return self;
}

-(float)predict:(float[])inputs{

    if (sizeof(inputs) != self.input_layer.size) {
        <#statements#>
    }
    float hidden[] = { 0.0f, 0.0f };
    float output[] = { 0.0f };
    
    if (BNNSFilterApply(self.hidden_layer, inputs, hidden) != 0) {
        fprintf(stderr, "BNNSFilterApply failed on hidden_layer\n");
    }

    if (BNNSFilterApply(self.output_layer, hidden, output) != 0) {
        fprintf(stderr, "BNNSFilterApply failed on output_layer\n");
    }
    
    NSLog(@"Predict %f = %f", inputs, output[0]);
    return output[0];
}

@end
