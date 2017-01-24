//
//  Vertex.h
//  Word Ladder
//
//  Created by Yongyang Nie on 1/15/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

#pragma mark - Instance Variables

@property double value;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableArray *connections; //@{@"key1": @"weight1"},
                                                           //@{@"key2": @"weight2"},

#pragma mark - Constructors

- (instancetype)initWithKey:(NSString *)key value:(float)v;
- (instancetype)initWithKey:(NSString *)key;

@end
