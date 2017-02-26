//
//  MindStorage.m
//  Handwriting
//
//  Created by Yongyang Nie on 2/6/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "MindStorage.h"
#import <Foundation/Foundation.h>

@implementation MindStorage

+(BOOL)storeMind:(Mind *)mind path:(NSString *)path{
    
    NSMutableArray *hiddenWeights = [MindStorage convertToArray:mind.weights->hiddenWeights count:mind.numHiddenWeights];
    NSMutableArray *outputWeights = [MindStorage convertToArray:mind.weights->outputWeights count:mind.numOutputWeights];
    NSDictionary *dic = @{@"hiddenWeights": hiddenWeights,
                          @"outputWeights": outputWeights};
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSError *error;
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    NSLog(@"%@", error);
    if (error)
        return NO;
    return YES;
}

+(NSDictionary *)getMind:(NSString *)path{
    return nil;
}

+(NSMutableArray *)convertToArray:(float *)array count:(int)count{
    
    NSMutableArray *objects = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [objects addObject:[NSNumber numberWithFloat:array[i]]];
    }
    return objects;
}

@end
