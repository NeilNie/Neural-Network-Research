//
//  ViewController.m
//  DrawPad
//
//  Created by Ray Wenderlich on 9/3/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    
    self.wt = [[WritingTrainer alloc] init];
    [self.wt getMindWithPath:[[NSBundle mainBundle] pathForResource:@"mindData" ofType:nil]];
    
    [super viewDidLoad];
}
- (IBAction)recognize:(id)sender {

    NSMutableArray *pixels = [self getPixelsFromImage];

    float *result = [self.wt.mind forwardPropagation:pixels];
    [self.wt.mind print:result count:10];
    self.result.text = [NSString stringWithFormat:@"It's likely to be: %i", [self.wt largestIndex:result count:10]];
}

- (IBAction)pencilPressed:(id)sender {
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
}

- (IBAction)eraserPressed:(id)sender {
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
}

- (IBAction)reset:(id)sender {
    
    self.mainImage.image = nil;
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
    //UIImage *croppedImage = []
    // Scale character to max 20px in either dimension
    UIImage *scaledImage = [self imageWithImage:self.mainImage.image convertToSize:CGSizeMake(20, 20)];
    // Center character in 28x28 white box
    UIImage *character = [self addBorderToImage:scaledImage];
    
    self.mainImage.image = character;
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(character.CGImage));
    UInt8 * data = (UInt8 *) CFDataGetBytePtr(pixelData);
    unsigned long bytesPerRow = CGImageGetBytesPerRow(character.CGImage);
    unsigned long bytesPerPixel = (CGImageGetBitsPerPixel(character.CGImage) / 8);
    int position = 0;
    for (int i = 0; i<character.size.height; i++) {
        for (int i = 0; i<character.size.height; i++) {
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
    
    rect = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y + 114, self.boundingBox.size.width, self.boundingBox.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image {
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.tempDrawImage];
    
    if (CGRectIsEmpty(self.boundingBox))
        self.boundingBox = CGRectMake(lastPoint.x - 1 / 2, lastPoint.y - 1 / 2, 1, 1);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.tempDrawImage];
    
    if (currentPoint.x < CGRectGetMinX(self.boundingBox)) {
        self.boundingBox = [self updateRect:currentPoint.x - 5 - 20 maxX:0 minY:0 maxY:0 rect:self.boundingBox];
        
    } else if (currentPoint.x > CGRectGetMaxX(self.boundingBox)) {
        //self.updateRect(rect: &self.boundingBox!, minX: nil, maxX: currentPoint.x + self.brushWidth + 20, minY: nil, maxY: nil)
        self.boundingBox = [self updateRect:0 maxX:currentPoint.x + 5 + 20 minY:0 maxY:0 rect:self.boundingBox];
    }
    if (currentPoint.y < CGRectGetMinY(self.boundingBox)) {
        //self.updateRect(rect: &self.boundingBox!, minX: nil, maxX: nil, minY: currentPoint.y - self.brushWidth - 20, maxY: nil)
        self.boundingBox = [self updateRect:0 maxX:0 minY:currentPoint.y - 5 - 20 maxY:0 rect:self.boundingBox];
    } else if (currentPoint.y > CGRectGetMaxY(self.boundingBox)) {
        //self.updateRect(rect: &self.boundingBox!, minX: nil, maxX: nil, minY: nil, maxY: currentPoint.y + self.brushWidth + 20)
        self.boundingBox = [self updateRect:0 maxX:0 minY:0 maxY:currentPoint.y + 5 + 20 rect:self.boundingBox];
    }
    
    UIView *rect = [[UIView alloc] initWithFrame:self.boundingBox];
    rect.backgroundColor = [UIColor greenColor];
    [self.view addSubview:rect];
    
    UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
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
}

-(CGRect)updateRect:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY rect:(CGRect)rect{
    
    CGFloat width;
    CGFloat height;
    width = ((maxX > CGRectGetMaxX(rect)) ? maxX : CGRectGetMaxX(rect)) - ((minX > CGRectGetMinX(rect)) ? minX : CGRectGetMinX(rect));
    height = ((maxY > CGRectGetMaxY(rect)) ? maxY : CGRectGetMaxY(rect)) - ((minY > CGRectGetMinY(rect)) ? minY : CGRectGetMinY(rect));
    
    CGRect newRect = CGRectMake((minX > CGRectGetMinX(rect)) ? minX : CGRectGetMinX(rect),
                                (minY > CGRectGetMinY(rect)) ? minY : CGRectGetMinY(rect),
                                width, height);
    return newRect;
}
@end
