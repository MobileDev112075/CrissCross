//
//  AppJoinViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "VTImagePicker.h"
#import "ImageCropView.h"

@interface AppJoinViewController : AppViewController<UITextFieldDelegate,UIActionSheetDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,ImageCropViewControllerDelegate,UIAlertViewDelegate>{

    
    UITextField *_inputEmail;
    UITextField *_inputPass;
    UITextField *_inputPass2;
    UIButton *_btnContinue;
    UIImageView *_topImage;
    UITextField *_inputUsername;
    UITextField *_inputFirstName;
    UITextField *_inputLastName;
    UITextField *_inputHomeCity;
    UITextField *_inputPhone;
    UIScrollView *_scrollView;
    UIButton *_btnCam;
    UILabel *_btnCamLabel;
    UITextField *_inputSearch;
    
    UIView *_viewFirstStep;
    UIView *_viewSecondStep;
    
    UIView *_locationSelectionView;
    UITableView *_tableViewSearch;

    VTImagePicker *_imagePicker;
    ImageCropViewController *_imageCropController;
    BOOL _avatarChanged;
    
    NSMutableArray *_searchItems;
    AFHTTPRequestOperationManager *_searchManager;
    int _lastTicket;
    NSMutableDictionary *_previousResults;
    BOOL _searchActive;
    BOOL _searchShowing;
    BOOL _didPhonePrompt;
    NSDictionary *_selectedHomeTown;
}

@property(nonatomic,assign) BOOL isResuming;






@end

