//
//  UIImage+Additions.h
//  
//
//  Created by Vincent Tuscano on 12/27/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)


- (UIImage *)imageWithOverlayColor:(UIColor *)color;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


@end
