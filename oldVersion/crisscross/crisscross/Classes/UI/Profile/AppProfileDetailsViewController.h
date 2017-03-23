//
//  AppProfileDetailsViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppProfileDetailsViewController : AppViewController<UIAlertViewDelegate>{
    UIView *_stampsHolder;
    int _idxInQuestion;
    UIView *_viewGradient;
    NSMutableArray *_stampsToRemove;
}
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet CCButton *btnClose;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSString *mainContactId;
@property (strong, nonatomic) AppUser *thisUser;

@property (strong, nonatomic) IBOutlet UIImageView *theBg;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;

- (IBAction)doClose;
- (IBAction)doEdit;



@end
