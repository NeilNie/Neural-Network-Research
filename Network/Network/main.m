//
//  main.m
//  Network
//
//  Created by Yongyang Nie on 2/12/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Network.h"
#import "Training.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Training *t = [[Training alloc] initTrainer];
        NSLog(@"%@", t);
        [t train:30 epochs:30 learningRate:3.0];
    }
    return 0;
}
