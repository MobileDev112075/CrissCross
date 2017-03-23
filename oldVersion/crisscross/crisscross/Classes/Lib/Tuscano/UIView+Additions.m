//
//  UIView+Additions.m
//  
//
//  Created by Vincent Tuscano on 5/4/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import "UIView+Additions.h"


@implementation UIView (Additions)

-(void)setWidth:(CGFloat)newWidth {
    CGRect newFrame = self.frame;
    newFrame.size.width = newWidth;
    self.frame = newFrame;
}
-(void)setHeight:(CGFloat)newHeight {
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}
-(void)setSize:(CGSize)newSize {
    CGRect newFrame = self.frame;
    newFrame.size.width = newSize.width;
    newFrame.size.height = newSize.height;
    self.frame = newFrame;
}

-(void)setX:(CGFloat)newX {
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}
-(void)setCenterX:(CGFloat)newX{
    CGPoint centerP = self.center;
    centerP.x = newX;
    self.center = centerP;
}

-(void)setY:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}
-(void)setYAnimated:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    [UIView animateWithDuration:MOVE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut//|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void)setCenterY:(CGFloat)newY{
    CGPoint centerP = self.center;
    centerP.y = newY;
    self.center = centerP;
}

-(void)setXY:(CGPoint)newPoint {
    CGRect newFrame = self.frame;
    newFrame.origin.x = newPoint.x;
    newFrame.origin.y = newPoint.y;
    self.frame = newFrame;
}

-(void)adjustWidth:(CGFloat)newWidth {
    CGRect newFrame = self.frame;
    newFrame.size.width += newWidth;
    self.frame = newFrame;
}
-(void)adjustHeight:(CGFloat)newHeight {
    CGRect newFrame = self.frame;
    newFrame.size.height += newHeight;
    self.frame = newFrame;
}
-(void)adjustX:(CGFloat)newX {
    CGRect newFrame = self.frame;
    newFrame.origin.x += newX;
    self.frame = newFrame;
}
-(void)adjustY:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y += newY;
    self.frame = newFrame;
}
-(void)adjustYAnimated:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y += newY;
    [UIView animateWithDuration: MOVE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut//|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void)positionBelowView:(UIView *)anotherView withMargin:(CGFloat)margin {
    if (anotherView.frame.size.height > 0) {
        [self setY:anotherView.frame.origin.y + anotherView.frame.size.height + margin];
    } else {
        [self setY:anotherView.frame.origin.y];
    }
}

//new
-(CGFloat)maxX {
    return self.frame.origin.x + self.frame.size.width;
}
-(CGFloat)maxY {
    return self.frame.origin.y + self.frame.size.height;
}
-(CGFloat)height {
    return self.frame.size.height;
}
-(CGFloat)width {
    return self.frame.size.width;
}
-(CGFloat)x {
    return self.frame.origin.x;
}
-(CGFloat)y {
    return self.frame.origin.y;
}
//end new


//-(UIImage *)screenshot {
//	CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
//	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//	CGContextRef ctx = CGBitmapContextCreate(nil, screenSize.width, screenSize.height, 8, 4*(int)screenSize.width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
//	CGContextTranslateCTM(ctx, 0.0, screenSize.height);
//	CGContextScaleCTM(ctx, 1.0, -1.0);
//
//	[(CALayer *)self.layer renderInContext:ctx];
//
//	CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
//	UIImage *image = [UIImage imageWithCGImage:cgImage];
//	//CGImageRelease(cgImage);
//	//CGContextRelease(ctx);
//	//[UIImageJPEGRepresentation(image, 1.0) writeToFile:@"screen.jpg" atomically:NO];
//	return image;
//}
//
//-(UIImage *)snapshot {
//	CGSize screenSize = self.frame.size;
//	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//	CGContextRef ctx = CGBitmapContextCreate(nil, screenSize.width, screenSize.height, 8, 4*(int)screenSize.width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
//	CGContextTranslateCTM(ctx, 0.0, screenSize.height);
//	CGContextScaleCTM(ctx, 1.0, -1.0);
//
//	[(CALayer *)self.layer renderInContext:ctx];
//
//	CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
//	UIImage *image = [UIImage imageWithCGImage:cgImage];
//	//CGImageRelease(cgImage);
//	//CGContextRelease(ctx);
//	//[UIImageJPEGRepresentation(image, 1.0) writeToFile:@"screen.jpg" atomically:NO];
//	return image;
//}

- (void)fadeIn {
    [self setAlpha:0.0];
    [self setHidden:NO];
    [UIView animateWithDuration: FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut//|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                     }];
    
}
- (void)fadeInWithCompletion:(UIVIewFadeCompleted)completion {
    [self setAlpha:0.0];
    [self setHidden:NO];
    [UIView animateWithDuration: FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut//|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         completion();
                     }];
}
- (void)fadeInFastNotUsingBloksWithDelegate:(id)aDelegate selector:(SEL)selector {
    //[self setAlpha:0.0];
    if (self.hidden) {
        self.hidden = NO;
    }
    [self.layer removeAllAnimations];
    [UIView beginAnimations:@"UIView+Additions_fadeInFastNotUsingBloksWithDelegate" context:nil];
    [UIView setAnimationDuration:FAST_FADE_ANIMATION_DURATION];
    //    [UIView setAnimationCurve:UIViewAnimationOptionCurveLinear];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:aDelegate];
    [UIView setAnimationDidStopSelector:selector];
    [self setAlpha:1.0];
    [UIView commitAnimations];
}
- (void)fadeInFast {
    [self setAlpha:0.0];
    [self setHidden:NO];
    [UIView animateWithDuration: FAST_FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void)fadeInWithDuration:(float)duration {
    [self setAlpha:0.0];
    [self setHidden:NO];
    [UIView animateWithDuration: duration
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void)fadeOutNotUsingBloksWithDelegate:(id)aDelegate selector:(SEL)selector {
    [UIView beginAnimations:@"UIView+Additions_fadeOutNotUsingBloksWithDelegate" context:nil];
    [UIView setAnimationDuration:FADE_ANIMATION_DURATION];
    //    [UIView setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:aDelegate];
    [UIView setAnimationDidStopSelector:selector];
    [self setAlpha:0];
    [UIView commitAnimations];
}
- (void)fadeOut {
    [UIView animateWithDuration: FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self setHidden:YES];
                     }];
}

- (void)fadeOutFast {
    [UIView animateWithDuration: FAST_FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self setHidden:YES];
                     }];
}

- (void)fadeOutWithCompletion:(UIVIewFadeCompleted)completion {
    [UIView animateWithDuration: FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self setHidden:YES];
                         completion();
                     }];
}
- (void)fadeOutNotHide {
    [UIView animateWithDuration: FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
- (void)fadeOutAndRemove {
    [UIView animateWithDuration: FADE_ANIMATION_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseInOut//|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}
- (void)removeAllSubviews {
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
}
- (void)removeAllSubviewsWithTag:(int)tag {
    for (UIView *subview in [self subviews]) {
        if (subview.tag == tag) {
            [subview removeFromSuperview];
        }
    }
}
- (void)removeAllSubviewsButViewsWithTag:(int)tag {
    for (UIView *subview in [self subviews]) {
        if (subview.tag != tag) {
            [subview removeFromSuperview];
        }
    }
}


+(id)viewFactory {
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",[self class]] owner:self options:nil];
    return [nib objectAtIndex:0];
}
+(id)viewWithNib:(NSString *)nibName {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    return [nib objectAtIndex:0];
}





//////////
// Top
//////////

-(CALayer*)createTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    return [self getOneSidedBorderWithFrame:CGRectMake(0, 0, self.frame.size.width, height) andColor:color];
}

-(UIView*)createViewBackedTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(0, 0, self.frame.size.width, height) andColor:color];
}

-(void)addTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    [self addOneSidedBorderWithFrame:CGRectMake(0, 0, self.frame.size.width, height) andColor:color];
}

-(void)addViewBackedTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(0, 0, self.frame.size.width, height) andColor:color];
}


//////////
// Top + Offset
//////////

-(CALayer*)createTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset {
    // Subtract the bottomOffset from the height and the thickness to get our final y position.
    // Add a left offset to our x to get our x position.
    // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
    return [self getOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}

-(UIView*)createViewBackedTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset {
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}

-(void)addTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset {
    // Add leftOffset to our X to get start X position.
    // Add topOffset to Y to get start Y position
    // Subtract left offset from width to negate shifting from leftOffset.
    // Subtract rightoffset from width to set end X and Width.
    [self addOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}

-(void)addViewBackedTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset {
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}


//////////
// Right
//////////

-(CALayer*)createRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    return [self getOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width, 0, width, self.frame.size.height) andColor:color];
}

-(UIView*)createViewBackedRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width, 0, width, self.frame.size.height) andColor:color];
}

-(void)addRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    [self addOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width, 0, width, self.frame.size.height) andColor:color];
}

-(void)addViewBackedRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width, 0, width, self.frame.size.height) andColor:color];
}



//////////
// Right + Offset
//////////

-(CALayer*)createRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset{
    
    // Subtract bottomOffset from the height to get our end.
    return [self getOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width-rightOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}

-(UIView*)createViewBackedRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width-rightOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}

-(void)addRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset{
    
    // Subtract the rightOffset from our width + thickness to get our final x position.
    // Add topOffset to our y to get our start y position.
    // Subtract topOffset from our height, so our border doesn't extend past teh view.
    // Subtract bottomOffset from the height to get our end.
    [self addOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width-rightOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}

-(void)addViewBackedRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(self.frame.size.width-width-rightOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}


//////////
// Bottom
//////////

-(CALayer*)createBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    return [self getOneSidedBorderWithFrame:CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height) andColor:color];
}

-(UIView*)createViewBackedBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height) andColor:color];
}

-(void)addBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    [self addOneSidedBorderWithFrame:CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height) andColor:color];
}

//-(void)addBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
//    UILabel *line = [[UILabel alloc] initWithFrame:self.frame];
//    line.height = height;
//    line.backgroundColor = color;
//    line.x = 0;
//    line.y = self.height - height;
//    [self addSubview:line];
//}


-(void)addViewBackedBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height) andColor:color];
}


//////////
// Bottom + Offset
//////////

-(CALayer*)createBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset {
    // Subtract the bottomOffset from the height and the thickness to get our final y position.
    // Add a left offset to our x to get our x position.
    // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
    return [self getOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, self.frame.size.height-height-bottomOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}

-(UIView*)createViewBackedBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, self.frame.size.height-height-bottomOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}

-(void)addBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset {
    // Subtract the bottomOffset from the height and the thickness to get our final y position.
    // Add a left offset to our x to get our x position.
    // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
    [self addOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, self.frame.size.height-height-bottomOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}

-(void)addViewBackedBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, self.frame.size.height-height-bottomOffset, self.frame.size.width - leftOffset - rightOffset, height) andColor:color];
}



//////////
// Left
//////////

-(CALayer*)createLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    return [self getOneSidedBorderWithFrame:CGRectMake(0, 0, width, self.frame.size.height) andColor:color];
}



-(UIView*)createViewBackedLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(0, 0, width, self.frame.size.height) andColor:color];
}

-(void)addLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    [self addOneSidedBorderWithFrame:CGRectMake(0, 0, width, self.frame.size.height) andColor:color];
}



-(void)addViewBackedLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(0, 0, width, self.frame.size.height) andColor:color];
}



//////////
// Left + Offset
//////////

-(CALayer*)createLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset {
    return [self getOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}



-(UIView*)createViewBackedLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset{
    return [self getViewBackedOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}


-(void)addLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset {
    [self addOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}



-(void)addViewBackedLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset{
    [self addViewBackedOneSidedBorderWithFrame:CGRectMake(0 + leftOffset, 0 + topOffset, width, self.frame.size.height - topOffset - bottomOffset) andColor:color];
}



//////////
// Private: Our methods call these to add their borders.
//////////

-(void)addOneSidedBorderWithFrame:(CGRect)frame andColor:(UIColor*)color
{
    CALayer *border = [CALayer layer];
    border.frame = frame;
    [border setBackgroundColor:color.CGColor];
    [self.layer addSublayer:border];
}

-(CALayer*)getOneSidedBorderWithFrame:(CGRect)frame andColor:(UIColor*)color
{
    CALayer *border = [CALayer layer];
    border.frame = frame;
    [border setBackgroundColor:color.CGColor];
    return border;
}


-(void)addViewBackedOneSidedBorderWithFrame:(CGRect)frame andColor:(UIColor*)color
{
    UIView *border = [[UIView alloc]initWithFrame:frame];
    [border setBackgroundColor:color];
    [self addSubview:border];
}

-(UIView*)getViewBackedOneSidedBorderWithFrame:(CGRect)frame andColor:(UIColor*)color
{
    UIView *border = [[UIView alloc]initWithFrame:frame];
    [border setBackgroundColor:color];
    return border;
}

@end
