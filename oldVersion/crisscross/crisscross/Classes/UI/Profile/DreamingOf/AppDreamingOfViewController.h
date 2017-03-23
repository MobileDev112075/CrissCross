//
//  AppDreamingOfViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppDreamingOfViewController : AppViewController{
    NSMutableArray *_tagsOnScreen;
    BOOL _isOwner;
    float _yMin;
    float _yMax;
    int _colorIdx;
    BOOL _reloadOnView;
    UIView *_hintView;
    BOOL _isFullyLoaded;
}



@property (strong, nonatomic) IBOutlet CCButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIView *tagCloudView;
@property (strong, nonatomic) NSString *mainContactId;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)doEdit;
- (IBAction)re:(id)sender;

@end
