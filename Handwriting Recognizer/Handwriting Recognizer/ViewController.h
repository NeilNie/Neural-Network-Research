//
//  ViewController.h
//  DrawPad
//
//  Created by Ray Wenderlich on 9/3/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mind.h"
#import "WritingTrainer.h"

@interface ViewController : UIViewController <UIActionSheetDelegate> {
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    NSTimer *timer;
    int time;
}

@property (strong, nonatomic) WritingTrainer *wt;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UILabel *percentage;
@property (weak, nonatomic) IBOutlet UIView *rec;
@property (weak, nonatomic) IBOutlet UIImageView *processedImage;
@property CGRect boundingBox;

- (IBAction)reset:(id)sender;

@end
