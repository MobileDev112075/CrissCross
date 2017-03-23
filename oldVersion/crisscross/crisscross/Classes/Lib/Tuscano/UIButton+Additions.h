//
//  UIButton+Additions.h
//  
//
//  Created by Vincent Tuscano on 12/27/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

- (void)tintStateNormal:(UIColor *)normalColor andSelected:(UIColor *)selectedColor;
- (void)tintStateButtonImageNormal:(UIColor *)normalColor andSelected:(UIColor *)selectedColor;
- (void)tintStateNormal:(UIColor *)normalColor;

@end
