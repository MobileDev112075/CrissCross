//
//  CCButton.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/18/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"

@interface CCButton : UIButton

@property (nonatomic, strong) THLabel *theLabel;



-(void)setDefaults;
-(void)resetDefaults;

@end
