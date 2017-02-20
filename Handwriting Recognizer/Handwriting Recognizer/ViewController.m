//
//  ViewController.m
//  DrawPad
//
//  Created by Ray Wenderlich on 9/3/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "ViewController.h"

#if __has_feature(objc_arc)
#define MDLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define MDLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 20;
    opacity = 1.0;
    
    self.wt = [[WritingTrainer alloc] init];
    [self.wt getMindWithPath:[[NSBundle mainBundle] pathForResource:@"mindData" ofType:nil]];
    
    [super viewDidLoad];
}
- (IBAction)recognize:(id)sender {
    
    self.rec.frame = self.boundingBox;
    self.rec.hidden = NO;
    self.rec.layer.borderColor = [[UIColor greenColor] CGColor];
    self.rec.layer.borderWidth = 3.0f;
    self.rec.layer.cornerRadius = 5.0f;
    self.rec.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.rec];
    
    NSMutableArray *pixels = [self getPixelsFromImage];
    
    float *result = [self.wt.mind forwardPropagation:pixels];
    MDLog(@"result");
    [self.wt.mind print:result count:10];
    self.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self largestIndex:result count:10] * 100];
    self.result.text = [NSString stringWithFormat:@"%i", [self.wt largestIndex:result count:10]];
    self.boundingBox = CGRectZero;
}

- (IBAction)reset:(id)sender {
    
    self.mainImage.image = nil;
    self.result.text = @"";
    self.percentage.text = @"";
    self.processedImage.image = nil;
    self.rec.hidden = YES;;
}

-(float)largestIndex:(float *)array count:(int)count{
    
    float n = array[0];
    
    for (int i = 0; i < count; i++) {
        if (array[i] > n)
            n = array[i];
    }
    return n;
}


- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

-(NSMutableArray *)getPixelsFromImage{
    
    NSMutableArray *pixelsArray = [NSMutableArray array];
    
    // Extract drawing from canvas and remove surrounding whitespace
    UIImage *croppedImage = [self cropImage:self.mainImage.image toRect:self.boundingBox];
    // Scale character to max 20px in either dimension
    UIImage *scaledImage = [self imageWithImage:croppedImage convertToSize:CGSizeMake(20, 20)];
    // Center character in 28x28 white box
    UIImage *character = [self addBorderToImage:scaledImage];
    
    self.processedImage.image = character;
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(character.CGImage));
    UInt8 * data = (UInt8 *)CFDataGetBytePtr(pixelData);
    unsigned long bytesPerRow = CGImageGetBytesPerRow(character.CGImage);
    unsigned long bytesPerPixel = (CGImageGetBitsPerPixel(character.CGImage) / 8);
    int position = 0;
    for (int i = 0; i < character.size.height; i++) {
        for (int x = 0; x < character.size.width; x++) {
            float alpha = (float)data[position + 3];
            [pixelsArray addObject:[NSNumber numberWithFloat:alpha / 255]];
            position += bytesPerPixel;
        }
        if (position % bytesPerRow != 0) {
            position += (bytesPerRow - (position % bytesPerRow));
        }
    }
    
    CFRelease(pixelData);
    
    return pixelsArray;
}

-(NSMutableArray *)pixelFromImage:(UIImage *)image{
    
    NSMutableArray *pixelsArray = [NSMutableArray array];
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    UInt8 * data = (UInt8 *) CFDataGetBytePtr(pixelData);
    unsigned long bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    unsigned long bytesPerPixel = (CGImageGetBitsPerPixel(image.CGImage) / 8);
    int position = 0;
    for (int i = 0; i<image.size.height; i++) {
        for (int i = 0; i<image.size.height; i++) {
            float alpha = (float)data[position + 3];
            [pixelsArray addObject:[NSNumber numberWithFloat:alpha / 255]];
            position += bytesPerPixel;
        }
        if (position % bytesPerRow != 0) {
            position += (bytesPerRow - (position % bytesPerRow));
        }
    }
    CFRelease(pixelData);
    
    return pixelsArray;
}

-(UIImage *) addBorderToImage:(UIImage *)image{
    
    UIGraphicsBeginImageContext(CGSizeMake(28, 28));
    UIImage *white = [UIImage imageNamed:@"white.png"];
    [white drawAtPoint:CGPointZero];
    [image drawAtPoint:CGPointMake((28 - image.size.width) / 2, (28 - image.size.height) / 2)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}

-(void)countTimer{
    
    time++;
    if (time >= 15) {
        [self recognize:nil];
        [timer invalidate];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.tempDrawImage];
    
    if (CGRectIsEmpty(self.boundingBox))
        self.boundingBox = CGRectMake((lastPoint.x - brush) - 2, (lastPoint.y - brush) / 2, brush, brush);
    [timer invalidate];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.tempDrawImage];
    
    if (currentPoint.x < CGRectGetMinX(self.boundingBox))
        self.boundingBox = [self updateRect:currentPoint.x - brush - 5 maxX:0 minY:0 maxY:0 rect:self.boundingBox];
    else if (currentPoint.x > CGRectGetMaxX(self.boundingBox))
        self.boundingBox = [self updateRect:0 maxX:currentPoint.x + brush + 5 minY:0 maxY:0 rect:self.boundingBox];
    if (currentPoint.y < CGRectGetMinY(self.boundingBox))
        self.boundingBox = [self updateRect:0 maxX:0 minY:currentPoint.y - brush - 5 maxY:0 rect:self.boundingBox];
    else if (currentPoint.y > CGRectGetMaxY(self.boundingBox))
        self.boundingBox = [self updateRect:0 maxX:0 minY:0 maxY:currentPoint.y + brush + 5 rect:self.boundingBox];
    
    UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countTimer) userInfo:nil repeats:YES];
}

-(CGRect)updateRect:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY rect:(CGRect)rect{
    
    CGFloat width = ((maxX != 0) ? maxX : CGRectGetMaxX(rect)) - ((minX != 0) ? minX : CGRectGetMinX(rect));
    CGFloat height = ((maxY != 0) ? maxY : CGRectGetMaxY(rect)) - ((minY != 0) ? minY : CGRectGetMinY(rect));
    
    CGRect newRect = CGRectMake((minX != 0) ? minX : CGRectGetMinX(rect),
                                (minY != 0) ? minY : CGRectGetMinY(rect),
                                width, height);
    return newRect;
}

@end
