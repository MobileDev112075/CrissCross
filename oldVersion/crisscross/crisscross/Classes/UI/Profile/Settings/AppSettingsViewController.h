//
//  AppSettingsViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "VTImagePicker.h"
#import "ImageCropView.h"


@interface AppSettingsViewController : AppViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate,ImageCropViewControllerDelegate>{
    VTImagePicker *_imagePicker;
    ImageCropViewController *_imageCropController;
    
    BOOL _changedPhoto;
    
    NSMutableArray *_items;
    NSMutableArray *_searchItems;
    AFHTTPRequestOperationManager *_searchManager;
    int _lastTicket;
    NSMutableDictionary *_previousResults;
    BOOL _searchActive;
    BOOL _searchShowing;
    NSDictionary *_selectedHomeTown;
    
    NSArray *_sectionObjects;
    UISegmentedControl *_segmentNotifications;
    UISegmentedControl *_segmentVisibility;
    UISegmentedControl *_segmentDegrees;
    UIView *_viewGradient;
    UIView *_viewGradient2;
    UIView *_viewCurtain;
    UIView *_viewCurtainAbove;
    UIScrollView *_groupsScrollView;
    UITextField *_inputPhone;
    
    UITextField *_inputSearch;
    UIView *_locationSelectionView;
    UITableView *_tableViewSearch;

    
}

@property (strong, nonatomic) IBOutlet UITextField *inputUsername;
@property (strong, nonatomic) IBOutlet UITextField *inputFirstName;
@property (strong, nonatomic) IBOutlet UITextField *inputLastName;
@property (strong, nonatomic) IBOutlet UITextField *inputHomeTown;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIButton *btnHitArea;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnLogout;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;

- (IBAction)doGoBack;
- (IBAction)changePhoto;
- (IBAction)doLogout;
- (IBAction)doSave;

@end
