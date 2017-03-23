//
//  VTUtils.m
//
//
//  Created by Vincent Tuscano on 5/4/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//


#import "VTUtils.h"


@implementation VTUtils



+(NSDictionary *)processResponse:(NSDictionary *)dict{
    return dict;
}

+(BOOL)isResponseSuccessful:(NSDictionary *)dict{
    return ( [[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]] isEqualToString:@"1"] || [[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]] isEqualToString:@"true"]);
}

+(void)applyHexagonMask:(UIView *)obj{
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"hexagon.png"] CGImage];
    mask.frame = CGRectMake(0, 0, obj.width,obj.height);
    obj.layer.mask = mask;
    obj.layer.masksToBounds = YES;
}

+(void)removeLoadingView:(UIView *)view{
    UIView *foundView = [view viewWithTag:222];
    if(foundView){
        [foundView removeFromSuperview];
    }
}


+ (UIImage *)radialGradientImage:(CGSize)size start:(UIColor *)start end:(UIColor *)end centre:(CGPoint)center radius:(float)radius {
    // Render a radial background
    // http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
    // Initialise
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    
    // Create the gradient's colours
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGColorRef colorRef = [start CGColor];
    const CGFloat *_components = CGColorGetComponents(colorRef);
    
    CGColorRef colorRefEnd = [end CGColor];
    const CGFloat *_endComponents = CGColorGetComponents(colorRefEnd);
    
    CGFloat components[8] = { _components[0],_components[1],_components[2], _components[3],  // Start color
        _endComponents[0],_endComponents[1],_endComponents[2], _endComponents[3] }; // End color
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    // Normalise the 0-1 ranged inputs to the width of the image
    CGPoint myCentrePoint = CGPointMake(center.x * size.width, center.y * size.height);
    float myRadius = MIN(size.width, size.height) * radius;
    
    // Draw it!
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                 0, myCentrePoint, myRadius,
                                 kCGGradientDrawsAfterEndLocation);
    
    // Grab it as an autoreleased image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Clean up
    CGColorSpaceRelease(myColorspace); // Necessary?
    CGGradientRelease(myGradient); // Necessary?
    UIGraphicsEndImageContext(); // Clean up
    return image;
}



+(UIView *)buildAnimatedLoadingViewWithMessage:(NSString *)message andColor:(UIColor *)color withDelay:(float)delay{
    
    
    if(!color)
        color = [UIColor colorWithHexString:@"333333"];
    
//    if(!delay)
//        delay = 0;
    
    //color = [UIColor colorWithHexString:@"#000000"];
    
    //    uint boxWidth = 120;
    uint boxHeight = 120;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
        //boxWidth = 200;
        //boxHeight = 130;
    }
    
    int horizontalOffset = 0;
    //    if(![FBAppController sharedInstance].sideNavViewController.view.hidden){
    //        horizontalOffset = [FBAppController sharedInstance].sideNavViewController.view.width/2;
    //    }
    
    UILabel *appIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    appIcon.text = @"1";
    appIcon.font = [UIFont fontWithName:FONT_ICONS size:38];
    appIcon.textColor = [UIColor whiteColor];
    [appIcon sizeToFit];
    
    //    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UILabel *loadingMessage = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30, 30)];
    loadingMessage.text = message;
    loadingMessage.textAlignment = NSTextAlignmentCenter;
    loadingMessage.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
    loadingMessage.backgroundColor = [UIColor clearColor];
    loadingMessage.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:14];
    [loadingMessage sizeToFit];
    
    
    UIView *curtain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width, screenBounds.size.height)];
    curtain.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    curtain.alpha = 1;
    
    //    UIView *blackBox = [[UIView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - boxWidth/2, screenBounds.size.height/2 - boxWidth/2, boxWidth, boxHeight)];
    //    blackBox.layer.cornerRadius = 12.0;
    //    blackBox.backgroundColor = [color colorWithAlphaComponent:0.8];
    //    spinner.frame = CGRectMake(boxWidth/4,boxHeight/2.5, boxWidth/2, 50);
    
    UIView *blackBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, screenBounds.size.width/2, boxHeight)];
    blackBox.backgroundColor = [color colorWithAlphaComponent:0];
    blackBox.layer.cornerRadius = 20;
    blackBox.x = (screenBounds.size.width/2 - blackBox.width/2) + horizontalOffset;
    blackBox.y = screenBounds.size.height/2 - blackBox.height/2;
    appIcon.y = curtain.height/2 - appIcon.height/2;
//    appIcon.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    appIcon.x = curtain.width/2 - appIcon.width/2;
    loadingMessage.x = blackBox.width/2 - loadingMessage.width/2;
    loadingMessage.y = appIcon.maxY + 15;
    //    spinner.frame = CGRectMake(10,25, boxWidth/2, 50);
    [curtain addSubview:appIcon];
//    [blackBox addSubview:loadingMessage];
    //    [blackBox addSubview:spinner];
//    [curtain addSubview:blackBox];
    //    [spinner startAnimating];
    
    blackBox.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.6,0.6);
    [blackBox.layer removeAllAnimations];
    
    
    [UIView animateWithDuration:0.5 delay:delay usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionBeginFromCurrentState animations:^{
        blackBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        curtain.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    loadingMessage.hidden = YES;
    if((0)){
    
    [UIView animateWithDuration:1.5
        delay:delay
      options:UIViewAnimationOptionCurveEaseInOut
   animations:^{
       loadingMessage.alpha = 0.2;
   } completion:^(BOOL finished) {
       [UIView animateWithDuration:1.5
                             delay:0.0
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            loadingMessage.alpha = 1;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:1.5
                                                  delay:0.0
                                                options:UIViewAnimationOptionCurveEaseInOut
                                             animations:^{
                                                 loadingMessage.alpha = 0.2;
                                             } completion:^(BOOL finished) {
                                                 [UIView animateWithDuration:1.5
                                                                       delay:0.0
                                                                     options:UIViewAnimationOptionCurveEaseInOut
                                                                  animations:^{
                                                                      loadingMessage.alpha = 1;
                                                                  } completion:^(BOOL finished) {
                                                                      
                                                                  }];
                                             }];
                        }];
   }];
    }

    
    
    
    
    //appIcon
//    
//    [UIView animateWithDuration:0.1
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         blackBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
//                     } completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.1
//                                               delay:0.0
//                                             options:UIViewAnimationOptionCurveEaseInOut
//                                          animations:^{
//                                              blackBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//                                          } completion:^(BOOL finished) {
//                                              
//                                          }];
//                     }];
    curtain.tag = 222;
    
    return curtain;
}

+(UIView *)buildLoaderViewWithMessage:(NSString *)message andColor:(UIColor *)color{
    uint boxWidth = 120;
    uint boxHeight = 100;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
        boxWidth = 200;
        boxHeight = 130;
    }
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UILabel *loadingMessage = [[UILabel alloc] initWithFrame:CGRectMake(30, 35, screenBounds.size.width - 20, 30)];
    loadingMessage.text = message;
    loadingMessage.textAlignment = NSTextAlignmentCenter;
    loadingMessage.textColor = [UIColor whiteColor];
    loadingMessage.backgroundColor = [UIColor clearColor];
    
    UIView *curtain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width, screenBounds.size.height)];
    curtain.backgroundColor = [color colorWithAlphaComponent:0.3];
    
    //    UIView *blackBox = [[UIView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - boxWidth/2, screenBounds.size.height/2 - boxWidth/2, boxWidth, boxHeight)];
    //    blackBox.layer.cornerRadius = 12.0;
    //    blackBox.backgroundColor = [color colorWithAlphaComponent:0.8];
    //    spinner.frame = CGRectMake(boxWidth/4,boxHeight/2.5, boxWidth/2, 50);
    
    UIView *blackBox = [[UIView alloc] initWithFrame:CGRectMake(0, screenBounds.size.height/2 - boxWidth/2, screenBounds.size.width, boxHeight)];
    blackBox.backgroundColor = [color colorWithAlphaComponent:0.8];
    spinner.frame = CGRectMake(10,25, boxWidth/2, 50);
    
    
    [blackBox addSubview:loadingMessage];
    [blackBox addSubview:spinner];
    [curtain addSubview:blackBox];
    [spinner startAnimating];
    
    return curtain;
}

+(UIView *)buildBlackLoaderViewWithMessage:(NSString *)message{
    uint boxWidth = 120;
    uint boxHeight = 100;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
        boxWidth = 200;
        boxHeight = 130;
    }
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UILabel *loadingMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, boxHeight/6, boxWidth, 30)];
    loadingMessage.text = message;
    loadingMessage.textAlignment = NSTextAlignmentCenter;
    //    loadingMessage.font = [UIFont fontWithName:FONT_ARCHER_BOLD size:16];
    loadingMessage.textColor = [UIColor whiteColor];
    loadingMessage.backgroundColor = [UIColor clearColor];
    
    
    
    UIView *curtain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width, screenBounds.size.height)];
    curtain.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    UIView *blackBox = [[UIView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - boxWidth/2, screenBounds.size.height/2 - boxWidth/2, boxWidth, boxHeight)];
    blackBox.layer.cornerRadius = 12.0;
    blackBox.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    spinner.frame = CGRectMake(boxWidth/4,boxHeight/2.5, boxWidth/2, 50);
    [blackBox addSubview:loadingMessage];
    [blackBox addSubview:spinner];
    [curtain addSubview:blackBox];
    [spinner startAnimating];
    
    return curtain;
}

+(UIView *)buildLoaderViewWithMessage:(NSString *)message{
    
    uint boxHeight = 100;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
        boxHeight = 130;
    }
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UILabel *loadingMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    loadingMessage.text = message;
    loadingMessage.textAlignment = NSTextAlignmentCenter;
    //    loadingMessage.font = [UIFont fontWithName:NUDISTA_SEMIBOLD size:16];
    loadingMessage.textColor = [UIColor whiteColor];
    loadingMessage.backgroundColor = [UIColor clearColor];
    [loadingMessage sizeToFit];
    
    int loadingMessageWidth = loadingMessage.width + 20;
    [loadingMessage setXY:CGPointMake(10.0,15.0)];
    
    UIView *curtain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width, screenBounds.size.height)];
    curtain.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    UIView *blackBox = [[UIView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - loadingMessageWidth/2, screenBounds.size.height/2 - loadingMessageWidth/2, loadingMessageWidth, boxHeight)];
    blackBox.layer.cornerRadius = 12.0;
    blackBox.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    [spinner setXY:CGPointMake(blackBox.width/2 - spinner.width/2, boxHeight/2 - 5)];
    [blackBox addSubview:loadingMessage];
    [blackBox addSubview:spinner];
    [curtain addSubview:blackBox];
    [spinner startAnimating];
    
    return curtain;
}


+(void)makeStarPathWithView:(UIView *)view withWidth:(float)width andColor:(UIColor *)color{
    float  w = width;
    double r = w / 2.0;
    float flip = -1.0;
    CGFloat xCenter = w/2;
    CGFloat yCenter = xCenter;
    CGMutablePathRef path = CGPathCreateMutable();
    double theta = 2.0 * M_PI * (2.0 / 5.0); // 144 degrees
    CGPathMoveToPoint(path,NULL,xCenter, r*flip+yCenter);
    for (NSUInteger k=1; k<5; k++){
        float x = r * sin(k * theta);
        float y = r * cos(k * theta);
        CGPathAddLineToPoint(path, NULL, x+xCenter, y*flip+yCenter);
    }
    CAShapeLayer *arrowShapeLayer = [CAShapeLayer layer];
    [arrowShapeLayer setPath:path];
    [arrowShapeLayer setFillColor:color.CGColor];
    [arrowShapeLayer setBounds:CGRectMake(0.0f, 0.0f, w, w)];
    [arrowShapeLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [view.layer addSublayer:arrowShapeLayer];
    CGPathRelease(path);
}




+(NSString *)commaFormatted:(int)val{
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    [fmt setMaximumFractionDigits:0];
    return  [fmt stringFromNumber:@(val)];
}

+(NSString *)getTimeInStringFormatWithSeconds:(int)seconds{
    
    int hours = seconds/3600;
    seconds -= (hours*3600);
    int mins = seconds/60;
    seconds -= (mins*60);
    
    if(mins < 0)
        mins = 0;
    if(seconds < 0)
        seconds = 0;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,mins,seconds];
}

+(NSString *)getTimeInStringFormatWithoutHours:(int)seconds{
    
    int hours = seconds/3600;
    seconds -= (hours*3600);
    int mins = seconds/60;
    seconds -= (mins*60);
    
    if(mins < 0)
        mins = 0;
    if(seconds < 0)
        seconds = 0;
    
    return [NSString stringWithFormat:@"%02d:%02d",mins,seconds];
}

+(UIImage *)blurWithImageEffects:(UIImage *)image{
    return [image applyBlurWithRadius:5 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.1] saturationDeltaFactor:0.5 maskImage:nil];
}



+(UIImage *)blur:(UIImage*)image{
    const CGFloat blurRadius = 5.0f; // 9.5f
    const CGFloat cropMargin = 10.0f;
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:blurRadius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImageRef = [context createCGImage:result fromRect:[inputImage extent]];
    image = [UIImage imageWithCGImage:cgImageRef];
    CGImageRelease(cgImageRef);
    
    // crop blured image from each side
    cgImageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(cropMargin, cropMargin, image.size.width - 2 * cropMargin, image.size.height - 2 * cropMargin));
    image = [UIImage imageWithCGImage:cgImageRef];
    CGImageRelease(cgImageRef);
    return image;
}

@end
