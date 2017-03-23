/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "MGSwipeButton.h"
#import "UIView+Additions.h"
#import "AppConstants.h"


@class MGSwipeTableCell;

@implementation MGSwipeButton

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color padding:(NSInteger) padding
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding)];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:insets];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color padding:(NSInteger) padding callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:nil backgroundColor:color insets:insets callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color padding:(NSInteger) padding
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:insets callback:nil];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color padding:10 callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color padding:(NSInteger) padding callback:(MGSwipeButtonCallback) callback
{
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) callback:callback];
}

+(instancetype) buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *) color insets:(UIEdgeInsets) insets callback:(MGSwipeButtonCallback) callback
{
    MGSwipeButton * button = [self buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:button.titleLabel.font.pointSize];
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateNormal];
    button.callback = callback;
    [button setEdgeInsets:insets];
    return button;
}

+(instancetype) buttonWithTitle:(NSString *)title andIcon:(NSString*) icon backgroundColor:(UIColor *) color withHeight:(int)height{

    int bWidth = height;
    int bHeight = height;
    
    if(bWidth > 80)
        bWidth = 80;
    
    MGSwipeButton * button = [self buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    button.width = bWidth;
    button.height = bHeight;
    
    UILabel *theIcon = [[UILabel alloc] initWithFrame:button.frame];
    theIcon.width = roundf(bWidth * 0.65);
    theIcon.height = roundf(bHeight * 0.45);
    
    theIcon.font = [UIFont fontWithName:FONT_ICONS size:round(theIcon.height * 0.90)];
    if(theIcon.font.pointSize > 35)
         theIcon.font = [UIFont fontWithName:FONT_ICONS size:35];
    
    theIcon.adjustsFontSizeToFitWidth = YES;
    theIcon.text = icon;
    theIcon.textColor = [UIColor whiteColor];
    theIcon.textAlignment = NSTextAlignmentCenter;
    theIcon.width = roundf(bWidth * 0.70);
    theIcon.height = roundf(bHeight * 0.50);
    [button addSubview:theIcon];
    theIcon.x = roundf(bWidth/2 - theIcon.width/2);
    theIcon.y = roundf(bHeight/2 - theIcon.height/2);
    
    if([title length] > 1){
        UILabel *theTitle = [[UILabel alloc] initWithFrame:button.frame];
        theTitle.height = roundf(bHeight * 0.25);
        theTitle.width = roundf(bWidth * 0.90);
//        theTitle.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:round([AppController sharedInstance].screenBoundsSize.width * 0.023)];
        theTitle.numberOfLines = 0;
        theTitle.adjustsFontSizeToFitWidth = YES;
        theTitle.text = title;
        theTitle.textColor = [UIColor whiteColor];
        theTitle.textAlignment = NSTextAlignmentCenter;
        theTitle.x = roundf(bWidth/2 - theTitle.width/2);
        theTitle.y = roundf(bHeight - theTitle.height - 6);
        [button addSubview:theTitle];
        theIcon.y = roundf(theTitle.y - theIcon.height);
    }
    return button;
}

-(BOOL) callMGSwipeConvenienceCallback: (MGSwipeTableCell *) sender
{
    if (_callback) {
        return _callback(sender);
    }
    return NO;
}

-(void) centerIconOverText {
	const CGFloat spacing = 3.0;
	CGSize size = self.imageView.image.size;
	self.titleEdgeInsets = UIEdgeInsetsMake(0.0,
											-size.width,
											-(size.height + spacing),
											0.0);
	size = [self.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.titleLabel.font }];
	self.imageEdgeInsets = UIEdgeInsetsMake(-(size.height + spacing),
											0.0,
											0.0,
											-size.width);
}

-(void) setPadding:(CGFloat) padding
{
    self.contentEdgeInsets = UIEdgeInsetsMake(0, padding, 0, padding);
    [self sizeToFit];
}

- (void)setButtonWidth:(CGFloat)buttonWidth
{
    _buttonWidth = buttonWidth;
    if (_buttonWidth > 0)
    {
        CGRect frame = self.frame;
        frame.size.width = _buttonWidth;
        self.frame = frame;
    }
    else
    {
        [self sizeToFit];
    }
}

-(void) setEdgeInsets:(UIEdgeInsets)insets
{
    self.contentEdgeInsets = insets;
    [self sizeToFit];
}

@end
