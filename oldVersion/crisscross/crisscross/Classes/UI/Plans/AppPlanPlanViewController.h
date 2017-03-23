//
//  AppPlanPlanViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppPlanPlanViewController : AppViewController{
    NSMutableArray *_sections;
    UIView *_sectionsHolder;
}

@property(nonatomic,assign) BOOL doAnimateIn;

@end
