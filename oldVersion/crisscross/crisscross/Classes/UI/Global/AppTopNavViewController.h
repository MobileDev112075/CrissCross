//
//  AppTopNavViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"

@interface AppTopNavViewController : UIViewController{

}

@property (strong, nonatomic) IBOutlet CCButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *theTitle;
@property (strong, nonatomic) IBOutlet CCButton *btnLogo;


- (IBAction)doGoBack;
- (IBAction)doLogoPressed;
- (void)clearBackView;
- (void)logoView;


@end
