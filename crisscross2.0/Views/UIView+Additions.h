//
//  UIView+Additions.h
//  
//
//  Created by Vincent Tuscano on 5/4/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define FADE_ANIMATION_DURATION 2.0
#define MOVE_ANIMATION_DURATION 1.0
#define FAST_FADE_ANIMATION_DURATION 0.5

typedef void(^UIVIewFadeCompleted)();

@interface UIView (Additions)

//-(UIImage *)snapshot;
//-(UIImage *)screenshot;
-(void)setWidth:(CGFloat)newWidth;
-(void)setHeight:(CGFloat)newHeight;
-(void)setSize:(CGSize)newSize;
-(void)setX:(CGFloat)newX;
-(void)setCenterX:(CGFloat)newX;
-(void)setY:(CGFloat)newY;
-(void)setYAnimated:(CGFloat)newY;
-(void)setCenterY:(CGFloat)newY;
-(void)setXY:(CGPoint)newPoint;
-(void)adjustWidth:(CGFloat)newWidth;
-(void)adjustHeight:(CGFloat)newHeight;
-(void)adjustX:(CGFloat)newX;
-(void)adjustY:(CGFloat)newY;
-(void)adjustYAnimated:(CGFloat)newY;
-(void)positionBelowView:(UIView *)anotherView withMargin:(CGFloat)margin;

//new
-(CGFloat)maxX;
-(CGFloat)maxY;
-(CGFloat)height;
-(CGFloat)width;
-(CGFloat)x;
-(CGFloat)y;
//end new

- (void)fadeIn;
- (void)fadeInWithCompletion:(UIVIewFadeCompleted)completion;
- (void)fadeInFast;
- (void)fadeInWithDuration:(float)duration;
- (void)fadeOut;
- (void)fadeOutWithCompletion:(UIVIewFadeCompleted)completion;
- (void)fadeOutNotHide;
- (void)fadeOutAndRemove;
- (void)removeAllSubviews;
- (void)removeAllSubviewsWithTag:(int)tag;
- (void)removeAllSubviewsButViewsWithTag:(int)tag;

- (void)fadeInFastNotUsingBloksWithDelegate:(id)aDelegate selector:(SEL)selector;
- (void)fadeOutNotUsingBloksWithDelegate:(id)aDelegate selector:(SEL)selector;
- (void)fadeOutFast;

+(id)viewFactory;
+(id)viewWithNib:(NSString *)nibName;



///------------
/// Top Border
///------------
-(CALayer*)createTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(UIView*)createViewBackedTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(void)addTopBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;
-(void)addViewBackedTopBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;


///------------
/// Top Border + Offsets
///------------

-(CALayer*)createTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;
-(UIView*)createViewBackedTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;
-(void)addTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;
-(void)addViewBackedTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;

///------------
/// Right Border
///------------

-(CALayer*)createRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(UIView*)createViewBackedRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addViewBackedRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;

///------------
/// Right Border + Offsets
///------------

-(CALayer*)createRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(UIView*)createViewBackedRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addViewBackedRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;

///------------
/// Bottom Border
///------------

-(CALayer*)createBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(UIView*)createViewBackedBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(void)addBottomBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;
-(void)addViewBackedBottomBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;

///------------
/// Bottom Border + Offsets
///------------

-(CALayer*)createBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
-(UIView*)createViewBackedBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addViewBackedBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;

///------------
/// Left Border
///------------

-(CALayer*)createLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(UIView*)createViewBackedLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addViewBackedLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;

///------------
/// Left Border + Offsets
///------------

-(CALayer*)createLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(UIView*)createViewBackedLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addViewBackedLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;



@end
