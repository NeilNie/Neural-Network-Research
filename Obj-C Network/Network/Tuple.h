//
//  Tuple.h
//  Network
//
//  Created by Yongyang Nie on 2/12/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tuple : NSObject

@property id first;
@property id second;

- (instancetype)init:(id)object1 object2:(id)object2;

@end
