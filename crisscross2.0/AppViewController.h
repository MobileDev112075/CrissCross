//
//  AppViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppViewController : UIViewController<UIGestureRecognizerDelegate>{
    BOOL _didLayout;
    UIView *_loadingScreen;
    float firstX;
    float firstY;
}

@property(nonatomic,assign) BOOL canLeaveWithSwipe;

@end
