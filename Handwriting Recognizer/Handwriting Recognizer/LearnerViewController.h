//
//  LearnerViewController.h
//  Handwriting Recognizer
//
//  Created by Yongyang Nie on 2/20/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WritingLearner.h"
#import "Pixel.h"

@interface LearnerViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *input;
@property (weak, nonatomic) IBOutlet UIImageView *output;
@property (strong, nonatomic) WritingLearner *wl;


@end
