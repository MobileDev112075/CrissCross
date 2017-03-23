//
//  AppBeenThereDetailViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 6/10/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "VTImagePicker.h"
#import "ImageCropView.h"

@interface AppBeenThereDetailViewController : AppViewController<UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,ImageCropViewControllerDelegate>{
    NSMutableArray *_sectionRatings;
    NSArray *_options;
    NSMutableArray *_itemSuggestions;
    NSArray *_itemSuggestionsFiltered;
    NSMutableArray *_topButtons;
    NSMutableArray *_childButtons;
    NSMutableArray *_feedbackItems;
    UIView *_topButtonsView;
    UIView *_typeView;
    UIScrollView *_childButtonsScrollView;
    int _rating;
    int _defaultTopPill;
    int _defaultBottomPill;
    VTImagePicker *_imagePicker;
    ImageCropViewController *_imageCropController;
    BOOL _imageChanged;
    UITableView *_usersFeedbackTable;
    UITableView *_tableSuggestions;
    UIView *_pillHolder;
    UIView *_bottomLoader;
}


@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) AppBeenThere *beenThere;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *categoryDisplay;

@property (assign, nonatomic) BOOL isOwner;
@property (assign, nonatomic) BOOL isFromSearch;
@property (assign, nonatomic) BOOL isFromActivity;

@property (strong, nonatomic) AppActivity *searchActivity;
@property (strong, nonatomic) IBOutlet UIView *imageViewHolder;

@property (strong, nonatomic) IBOutlet UIView *commentsView;
@property (strong, nonatomic) IBOutlet UITextView *inputComments;
@property (strong, nonatomic) IBOutlet UIView *viewRatings;
@property (strong, nonatomic) IBOutlet UITextField *inputTitle;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *commentPlaceholder;
@property (strong, nonatomic) IBOutlet CCButton *btnChangePhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnShowHidePhoto;

@property (strong, nonatomic) IBOutlet UILabel *itemCategoryName;
@property (strong, nonatomic) IBOutlet UIImageView *imageLarge;

- (IBAction)doSave;
- (IBAction)doChangePhoto;
- (IBAction)doShowHidePhoto:(id)sender;

@end
