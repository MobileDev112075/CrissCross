//
//  AppTopNavViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppTopNavViewController.h"

@interface AppTopNavViewController ()

@end

@implementation AppTopNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnLogo.hidden = YES;
    _theTitle.adjustsFontSizeToFitWidth = YES;
    _btnBack.theLabel.x = 15;
}

- (void)logoView{
    _btnBack.hidden = YES;
    _theTitle.hidden = YES;
    _btnLogo.hidden = NO;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)clearBackView{
    _theTitle.hidden = YES;
    _btnLogo.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (IBAction)doGoBack {
    [[AppController sharedInstance] goBack];
}

- (IBAction)doLogoPressed {
    [[AppController sharedInstance] goBack];
}


@end
