//
//  WritingTrainer.h
//  Handwriting
//
//  Created by Yongyang Nie on 2/4/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mind.h"
#import "MindStorage.h"

@interface WritingTrainer : NSObject

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic, strong) NSMutableArray *testImageArray;
@property (nonatomic, strong) NSMutableArray *testLabelArray;
@property (nonatomic, strong) Mind *mind;

-(instancetype)initTrainer;

-(void)getMindWithPath:(NSString *)path;

-(float)evaluate:(int)ntest;

-(int)largestIndex:(float *)array count:(int)count;

-(void)train:(int)batchSize epochs:(int)epochs correctRate:(float)correctRate;

@end

