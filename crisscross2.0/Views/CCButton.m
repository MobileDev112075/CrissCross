//
//  CCButton.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/18/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "CCButton.h"
#import "UIView+Additions.h"

@implementation CCButton



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setDefaults];
    }
    return self;
}

-(void)resetDefaults{
    [self setDefaults];
}

- (void)setDefaults{
    [self removeAllSubviews];
    _theLabel = [[THLabel alloc] initWithFrame:self.frame];
    _theLabel.text = self.titleLabel.text;
    [self setTitle:@"" forState:UIControlStateNormal];
    [self addSubview:_theLabel];
    _theLabel.x = _theLabel.y = 0;
    _theLabel.textAlignment = NSTextAlignmentCenter;
    _theLabel.font = self.titleLabel.font;
    [_theLabel sizeToFit];
    _theLabel.height += 3;
    _theLabel.width += 3;
    _theLabel.x = self.width/2 - _theLabel.width/2;
    _theLabel.y = self.height/2 - _theLabel.height/2;
    
     _theLabel.gradientColors = @[[UIColor colorWithHexString:COLOR_CC_BLUE],[UIColor colorWithHexString:COLOR_CC_TEAL],[UIColor colorWithHexString:COLOR_CC_GREEN]];

}

@end
