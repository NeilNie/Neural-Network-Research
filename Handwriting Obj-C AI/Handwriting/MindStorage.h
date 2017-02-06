//
//  MindStorage.h
//  Handwriting
//
//  Created by Yongyang Nie on 2/6/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import "Mind.h"
#import <Foundation/Foundation.h>

@interface MindStorage : NSObject

-(BOOL)storeMind:(Mind *)mind path:(NSString *)path;

-(NSDictionary *)getMind:(NSString *)path;

@end
