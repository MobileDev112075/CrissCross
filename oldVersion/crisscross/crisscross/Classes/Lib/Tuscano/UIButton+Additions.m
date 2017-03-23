//
//  UIButton+Additions.m
//  
//
//  Created by Vincent Tuscano on 12/27/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)


- (void)tintStateButtonImageNormal:(UIColor *)normalColor andSelected:(UIColor *)selectedColor{
    
    UIImage *img = [self.imageView.image imageWithOverlayColor:normalColor];
	UIImage *selImg = [self.imageView.image imageWithOverlayColor:selectedColor];
    
	[self setImage:img forState:UIControlStateNormal];
	[self setImage:selImg forState:UIControlStateHighlighted];
	[self setImage:selImg forState:UIControlStateSelected];
	[self setImage:selImg forState:UIControlStateDisabled];

}

- (void)tintStateNormal:(UIColor *)normalColor andSelected:(UIColor *)selectedColor {
    
	UIImage *img = [self.imageView.image imageWithOverlayColor:normalColor];
	UIImage *selImg = [self.imageView.image imageWithOverlayColor:selectedColor];
    
	[self setImage:img forState:UIControlStateNormal];
	[self setImage:selImg forState:UIControlStateHighlighted];
	[self setImage:selImg forState:UIControlStateSelected];
	[self setImage:selImg forState:UIControlStateDisabled];
    
	[self setTitleColor:normalColor forState:UIControlStateNormal];
	[self setTitleColor:selectedColor forState:UIControlStateHighlighted];
	[self setTitleColor:selectedColor forState:UIControlStateSelected];
	[self setTitleColor:selectedColor forState:UIControlStateDisabled];
}

- (void)tintStateNormal:(UIColor *)normalColor {
	[self tintStateNormal:normalColor andSelected:normalColor];
}

@end
