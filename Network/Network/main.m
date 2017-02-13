//
//  main.m
//  Network
//
//  Created by Yongyang Nie on 2/12/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Network.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        Network *n = [[Network alloc] init:@[@2, @3, @1]];
    }
    return 0;
}
