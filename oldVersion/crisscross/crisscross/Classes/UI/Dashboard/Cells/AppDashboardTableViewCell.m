//
//  AppDashboardTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 7/5/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppDashboardTableViewCell.h"

#define HIGHLIGHT_Y_CONTROL_POINT   25

#pragma mark - BRFlabbyTableViewCell

@implementation AppDashboardTableViewCell

- (void)enableFlabby{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:nil];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setNeedsDisplay];
}

- (void)setFlabby:(BOOL)isFlabby{
    _isFlabby = isFlabby;
    if (isFlabby){
        [self enableFlabby];
    }
}

- (void)setFlabbyColor:(UIColor *)flabbyColor{
    _flabbyColor = flabbyColor;
    [self enableFlabby];
}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (_flabbyHighlightState == BRFlabbyHighlightStateCellTouched || !_isFlabby || (fabs(_verticalVelocity) < 1.0 && _flabbyHighlightState == BRFlabbyHighlightStateNone)) {
        
        CGContextSetFillColorWithColor(ctx, [_flabbyColor CGColor]);
        CGContextFillRect(ctx, rect);
        
    }else{
        
        CGFloat x = rect.origin.x;
        CGFloat y = rect.origin.y;
        CGFloat w = rect.size.width;
        CGFloat h = rect.size.height;
        
        CGFloat controlYOffset = _verticalVelocity*2>(h/2)?(h/2):_verticalVelocity*2;
        CGContextSetFillColorWithColor(ctx, [_flabbyOverlapColor CGColor]);
        CGContextFillRect(ctx, rect);
        CGFloat controlPointX1, controlPointX2, controlPointX3, controlPointX4, controlPointY1, controlPointY2;
        switch (_flabbyHighlightState) {
            case BRFlabbyHighlightStateCellAboveTouched:
                controlPointX1 = _touchXLocationInCell + x;
                controlPointX2 = _touchXLocationInCell + x;
                controlPointX3 = x + (w/2 + x) + (w - (w/2 + x))/2;
                controlPointX4 = (x + (w/2 + x))/2;
                controlPointY1 = HIGHLIGHT_Y_CONTROL_POINT;
                controlPointY2 = y+h+controlYOffset;
                CGContextSetFillColorWithColor(ctx, [_flabbyColorAbove CGColor]);
                CGContextFillRect(ctx, CGRectMake(x, y, w, h/2));
                break;
            case BRFlabbyHighlightStateCellBelowTouched:
                controlPointX1 = (x + (w/2 + x))/2;
                controlPointX2 = x + (w/2 + x) + (w - (w/2 + x))/2;
                controlPointX3 = _touchXLocationInCell + x;
                controlPointX4 = _touchXLocationInCell + x;
                controlPointY1 = controlYOffset;
                controlPointY2 = y+h-HIGHLIGHT_Y_CONTROL_POINT;
                CGContextSetFillColorWithColor(ctx, [_flabbyColorBelow CGColor]);
                CGContextFillRect(ctx, CGRectMake(x, y+h/2, w, h/2));
                break;
            default:
                controlPointX1 = (x + (w/2 + x))/2;
                controlPointX2 = x + (w/2 + x) + (w - (w/2 + x))/2;
                controlPointX3 = controlPointX2;
                controlPointX4 = controlPointX1;
                controlPointY1 = y+controlYOffset;
                controlPointY2 = y+h+controlYOffset;
                break;
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, x, y);
        CGPathAddCurveToPoint(path, nil, controlPointX1, controlPointY1, controlPointX2, controlPointY1, x+w, y);
        CGPathAddLineToPoint(path, nil, x+w, y+h);
        CGPathAddCurveToPoint(path, nil, controlPointX3, controlPointY2, controlPointX4, controlPointY2, x, y+h);
        CGPathCloseSubpath(path);
        CGContextAddPath(ctx, path);
        CGContextSetFillColorWithColor(ctx, [_flabbyColor CGColor]);
        CGContextFillPath(ctx);
        CGPathRelease(path);
    }
}

@end
