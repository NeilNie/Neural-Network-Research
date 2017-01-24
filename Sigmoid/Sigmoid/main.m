//
//  main.m
//  Sigmoid
//
//  Created by Yongyang Nie on 1/24/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here..
        
        printf("Please enter value for the sigmoid function");
        
        float f = 0;
        char c;
        scanf("%f %c", &f, &c);
        
        if (c == 'v') {
            NSLog(@"%f", 1 / (1 + pow(M_E, -f)));
        }else if (c == 'd'){
            NSLog(@"%f", pow(M_E, -f) / pow(1 + pow(M_E, -f), 2));
        }
        
    }
    return 0;
}
