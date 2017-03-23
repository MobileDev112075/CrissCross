//
//  UIImage+Additions.m
//  
//
//  Created by Vincent Tuscano on 12/27/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import "UIImage+Additions.h"


@implementation UIImage (Additions)


- (UIImage *)imageWithOverlayColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
	
    if (&UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = self.scale;
        UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    }
    else {
//        UIGraphicsBeginImageContext(self.size);
    }
	
    [self drawInRect:rect];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
