//
//  Training.h
//  Network
//
//  Created by Yongyang Nie on 2/14/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Network.h"
#import "Tuple.h"

@interface Training : NSObject

@property (nonatomic, strong) NSMutableArray <Tuple *>*trainingData;
@property (nonatomic, strong) NSMutableArray <Tuple *>*testData;

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) Network *network;

-(instancetype)initTrainer;

-(void)train:(int)batchSize epochs:(int)epochs learningRate:(float)eta;

@end
