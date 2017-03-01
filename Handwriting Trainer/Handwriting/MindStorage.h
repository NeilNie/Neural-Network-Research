//
//  MindStorage.h
//  Handwriting
//
//  Created by Yongyang Nie on 2/6/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mind.h"

/**
 @header MindStorage.h
 @class MindStorage
 
 If you have a trained neural network you can store it with MindStore. Stored information can be retrieved as well.
 */
@interface MindStorage : NSObject

/**
 @brief Store information from an instance of the Mind class to a given path. 
 
 @param mind An instance of mind
 @param path The path to store the mind data.
 
 @return BOOL If unable to store, return NO
 */
+(BOOL)storeMind:(Mind *)mind path:(NSString *)path;

/**
 @brief Retrieve the stored mind from a given path.
 
 @param path Path for the stored mind.
 
 @return Mind return an instance of Mind from the path.
 */
+(Mind *)getMind:(NSString *)path;

@end
