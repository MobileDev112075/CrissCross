//
//  AppBeenThereDetailViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 6/10/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppBeenThereDetailViewController.h"
#import "AppUserFeedbackTableViewCell.h"

#define kAppUserFeedbackTableViewCell @"AppUserFeedbackTableViewCell"
#define kAppStaticCellSuggestion @"kAppStaticCellSuggestion"

@interface AppBeenThereDetailViewController ()

@end

@implementation AppBeenThereDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.canLeaveWithSwipe = NO;
    _sectionRatings = [[NSMutableArray alloc] init];
    _feedbackItems = [[NSMutableArray alloc] init];
    _itemSuggestions = [[NSMutableArray alloc] init];
    _itemSuggestionsFiltered = [[NSArray alloc] init];
    _tableSuggestions = [[UITableView alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _imageChanged = NO;
    _itemImage.clipsToBounds = YES;
    _options = [AppBeenThere returnCategories];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}


-(void)layoutUI{
    
    if(!_didLayout){
        _didLayout = YES;
    
        _topnav.theTitle.text = @"Been There, Done That";
        _imageLarge.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        _imageLarge.hidden = YES;
        
        float ratio = 320.0/125.0;
        _imageViewHolder.height = self.view.width/ratio;
        
        if(_isFromSearch){

            [_itemImage setImageWithURL:[NSURL URLWithString:_searchActivity.img] placeholderImage:nil];
        }else{
            
            NSString *cachedFileKey = [NSString stringWithFormat:@"btdt_%@",_beenThere.itemId];
            
            
            
            if([[AppController sharedInstance].storedUploadedImages objectForKey:cachedFileKey] != nil){
                
                _itemImage.image = [UIImage imageWithData:[[AppController sharedInstance].storedUploadedImages objectForKey:cachedFileKey]];
            }else{
                [_itemImage setImageWithURL:[NSURL URLWithString:_beenThere.img] placeholderImage:nil];
            }
        }
        
        _inputComments.text = @"";
        _bottomView.y = _imageViewHolder.maxY;
        _inputTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_inputTitle.placeholder attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE size:_inputTitle.font.pointSize - 4], NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:1]}];
        
        _commentPlaceholder.text = @"Comment on what to get, where it is, & why you like it! (Optional)";
        _commentPlaceholder.hidden = NO;
        _commentPlaceholder.width = _inputComments.width - _commentPlaceholder.y - 20;
        _commentPlaceholder.numberOfLines = 0;
        [_commentPlaceholder sizeToFit];
        
        
        _inputTitle.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
        _inputTitle.leftViewMode = UITextFieldViewModeAlways;

        int startingX = 20;
        int spacingX = (self.view.width - (startingX*2)) / 5;
        for(int i=0; i<5; i++){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, spacingX, _viewRatings.height)];
            b.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:25];
            [b setTitle:@"$" forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
            b.tag = i;
            [b addTarget:self action:@selector(ratingTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_sectionRatings addObject:b];
            [_viewRatings addSubview:b];
            b.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:21];
            startingX += spacingX;
        }
        
        _imageLarge.y = -_imageLarge.height;
        _imageLarge.alpha = 0;

        
        
        
        if(_beenThere.communityItem){
            _isOwner = NO;
            
        }
        
        if(_beenThere.isAChild){
            
            if(_beenThere.rating > 0 && _beenThere.rating <= 5){
                UIButton *b = [_sectionRatings objectAtIndex:_beenThere.rating-1];
                [self ratingTapped:b];
            }else{
                _rating = 0;
            }
            
            if(_beenThere.categoryId > 0){

            }
            _inputTitle.text = _beenThere.itemTitle;
            [_inputTitle sizeToFit];
            _inputTitle.x = self.view.width/2 - _inputTitle.width/2;
            _inputComments.text = _beenThere.comment;
            if([_inputComments.text length] > 0){
                _commentPlaceholder.hidden = YES;
            }
        }
        
        
        

        if(!_isOwner){
            
            _inputTitle.y = _imageViewHolder.height/2 - _inputTitle.height;
            _itemCategoryName.y = _imageViewHolder.height/2 + 5;
            _inputTitle.userInteractionEnabled = NO;
            _commentPlaceholder.hidden = YES;
            _btnSave.hidden = YES;
            _inputComments.editable = NO;
            
            _inputTitle.enabled = NO;
            for(UIButton *b in _sectionRatings){
                b.enabled = NO;
            }
            [_btnShowHidePhoto setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
            [self changeTitleToStateView:YES];
            
            _btnShowHidePhoto.hidden = YES;
            _btnChangePhoto.hidden = YES;
            self.canLeaveWithSwipe = YES;
            
            if(_beenThere.isUserUploadedImage){
                
                [_imageLarge setImageWithURL:[NSURL URLWithString:_beenThere.customImg] placeholderImage:nil];
                _btnShowHidePhoto.hidden = NO;
            }else{
                
                
                NSString *cachedFileKey = [NSString stringWithFormat:@"btdt_%@",_beenThere.itemId];
                if([[AppController sharedInstance].storedUploadedImages objectForKey:cachedFileKey] != nil){
                
                    _imageLarge.image = [UIImage imageWithData:[[AppController sharedInstance].storedUploadedImages objectForKey:cachedFileKey]];
                }else{
                    [_imageLarge setImageWithURL:[NSURL URLWithString:_beenThere.img] placeholderImage:nil];
                }
                
            }
            
            NSString *topLevelName = @"";
            NSString *childLevelName = @"";
            BOOL found = NO;
            if(_beenThere.categoryId > 0){
                
                for(NSDictionary *d in _options){
                    for(NSDictionary *d2 in [d objectForKey:@"children"]){
                        int cat = [[d2 objectForKey:@"id"] intValue];
                        
                        if(cat == _beenThere.categoryId){
                            found = YES;
                            topLevelName = [d objectForKey:@"title"];
                            childLevelName = [d2 objectForKey:@"title"];
                            break;
                        }
                    }
                    if(found)
                        break;
                }
            }
            _itemCategoryName.text = [NSString stringWithFormat:@"%@ | %@",topLevelName,childLevelName];
        }else{
            _btnShowHidePhoto.hidden = YES;
            _itemCategoryName.hidden = YES;
           
            [self fetchSuggestions];
            
            [_inputTitle becomeFirstResponder];
            _inputTitle.y = _imageViewHolder.height/2 - _inputTitle.height/2;
            int idxTop = 0;
            int idxChild = 0;
            BOOL found = NO;
            if(_beenThere.categoryId > 0){

                for(NSDictionary *d in _options){
                    idxChild = 0;
                    for(NSDictionary *d2 in [d objectForKey:@"children"]){
                        int cat = [[d2 objectForKey:@"id"] intValue];
                        if(cat == _beenThere.categoryId){
                            found = YES;
                            break;
                        }
                        idxChild++;
                    }
                    if(found)
                        break;
                    
                    idxTop++;
                }
            }
            
            _defaultTopPill = idxTop;
            _defaultBottomPill = idxChild;
            
            
            _topButtons = [[NSMutableArray alloc] init];
            _childButtons = [[NSMutableArray alloc] init];
            _topButtonsView = [[UIView alloc] init];
            _typeView = [[UIView alloc] init];
            _childButtonsScrollView = [[UIScrollView alloc] init];
            _childButtonsScrollView.showsHorizontalScrollIndicator = NO;
            _typeView.backgroundColor = _bottomView.backgroundColor;
            _typeView.width = _scrollView.width;
            
            _typeView.y = _imageViewHolder.maxY + 5;

            UILabel *labelType = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.width, 20)];
            labelType.text =  @"Type";
            labelType.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:13];
            labelType.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
            labelType.textAlignment = NSTextAlignmentCenter;
            
            [_scrollView addSubview:_typeView];
            [_typeView addSubview:labelType];
            
            int btnHeight = 42;
            float totalWidth = [AppController sharedInstance].screenBoundsSize.width;
            [_topButtons removeAllObjects];
            [_childButtons removeAllObjects];
            [_topButtonsView removeAllSubviews];
            [_childButtonsScrollView removeAllSubviews];
            
            
            _topButtonsView.width = totalWidth;
            _topButtonsView.height = btnHeight + 6;
            _topButtonsView.y = labelType.maxY + 10;
            _topButtonsView.x = 0;
            
            [_typeView addSubview:_topButtonsView];
            [_typeView addSubview:_childButtonsScrollView];
            int padding = 5;
            int pillWidth = (totalWidth/[_options count]) - ([_options count] * padding/2);
            startingX = 15;
            
            int count = 0;
            for(NSDictionary *dict in _options){
                UIButton *pill = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, pillWidth, btnHeight)];
                [pill setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
                pill.layer.borderWidth = 1;
                [pill setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateNormal];
                [pill setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateSelected];
                pill.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:16];
                pill.titleLabel.adjustsFontSizeToFitWidth = YES;
                pill.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.2].CGColor;
                pill.layer.cornerRadius = 8;
                pill.tag = count;
                pill.enabled = YES;
                [pill addTarget:self action:@selector(pillActuallyTapped:) forControlEvents:UIControlEventTouchUpInside];
                [_topButtonsView addSubview:pill];
                [_topButtons addObject:pill];
                startingX += pill.width + padding;
                if(count == _defaultTopPill){
                    [self pillActuallyTapped:pill];
                }
                count++;
            }
            _typeView.height = _topButtonsView.maxY + _topButtonsView.height;
            _bottomView.y = _typeView.maxY;
         
            _commentsView.height = self.view.height - _scrollView.y - _bottomView.y - _commentsView.y - _btnSave.height;
            _btnSave.y = _commentsView.maxY;
            _bottomView.height = _btnSave.maxY;
            [_scrollView setContentSize:CGSizeMake(_scrollView.width, _bottomView.maxY)];
            
            _inputTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_inputTitle.placeholder attributes:@{ NSFontAttributeName:_inputTitle.font, NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.7 ] }];
            
            
            [_inputTitle becomeFirstResponder];
            _tableSuggestions.frame = CGRectMake(0, _typeView.y, self.view.width, 150);
            _tableSuggestions.delegate = self;
            _tableSuggestions.dataSource = self;
            _tableSuggestions.separatorStyle = UITableViewCellSeparatorStyleNone;
            _tableSuggestions.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
            [_scrollView addSubview:_tableSuggestions];
            [_tableSuggestions reloadData];
            [self expandBottomView:NO];

        }
        
        
        
        if(_beenThere.communityItem){
            
            
            _bottomView.hidden = YES;
            float startingY = _scrollView.y + _bottomView.y;
            _usersFeedbackTable = [[UITableView alloc] initWithFrame:CGRectMake(0, startingY, self.view.width, self.view.height - startingY)];
            [_usersFeedbackTable registerNib:[UINib nibWithNibName:kAppUserFeedbackTableViewCell bundle:nil] forCellReuseIdentifier:kAppUserFeedbackTableViewCell];
            _usersFeedbackTable.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
            _usersFeedbackTable.delegate = self;
            _usersFeedbackTable.dataSource = self;
            _usersFeedbackTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.view addSubview:_usersFeedbackTable];
            [_usersFeedbackTable reloadData];
            
            int btnHeight = 42;
            int pillWidth = 100;
            int startingX = 0;
            _btnShowHidePhoto.hidden = YES;
            _itemCategoryName.hidden = YES;
            _pillHolder = [[UIView alloc] init];
            NSArray *categoryPills = [_itemCategoryName.text componentsSeparatedByString:@" | "];
            int count = 0;
            _pillHolder.height = btnHeight;
            _pillHolder.y = _imageViewHolder.height - _pillHolder.height - 10;

            for(NSString *pillVal in categoryPills){
                UIButton *pill = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, pillWidth, btnHeight)];
                [pill setTitle:pillVal forState:UIControlStateNormal];
                pill.layer.borderWidth = 1;
                [pill setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                pill.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:16];
                pill.titleLabel.adjustsFontSizeToFitWidth = YES;
                pill.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
                pill.layer.cornerRadius = 8;
                [pill sizeToFit];
                pill.width += 20;
                if(pill.width > self.view.width - startingX - 10)
                    pill.width = self.view.width - startingX - 10;
                pill.height = btnHeight;
                pill.enabled = NO;

                count++;
                startingX += pill.width + 5;
                [_pillHolder addSubview:pill];
                _pillHolder.width = pill.maxX;
            }
            [_imageViewHolder addSubview:_pillHolder];
            _pillHolder.x = _imageViewHolder.width/2 - _pillHolder.width/2;
            _inputTitle.y = _pillHolder.y/2 - _inputTitle.height/8;
            [self fetchFeedback];
        }
    }
    
}

-(void)fetchSuggestions{
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    
    if(_searchActivity != nil){
        [dict setObject:_searchActivity.cityId forKey:@"locations_id"];
    }else{
        [dict setObject:_beenThere.locationsId forKey:@"locations_id"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetBTDTSuggestions:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_itemSuggestions removeAllObjects];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            for(NSDictionary *d in [responseObject objectForKey:@"data"]){
                [_itemSuggestions addObject:d];
            }
            [_tableSuggestions reloadData];
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(void)expandBottomView:(BOOL)val{
    if(val){
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _tableSuggestions.height = ([_itemSuggestionsFiltered count] * 42) + 20;
            _tableSuggestions.alpha = 1;
            _typeView.y = _tableSuggestions.maxY;
            _bottomView.y = _typeView.maxY;
        } completion:^(BOOL finished) {
           [_scrollView setContentSize:CGSizeMake(_scrollView.width, _bottomView.maxY)];
        }];
    }else{
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _tableSuggestions.alpha = 0;
            _typeView.y = _imageViewHolder.maxY + 5;
            _bottomView.y = _typeView.maxY;
        } completion:^(BOOL finished) {
            [_scrollView setContentSize:CGSizeMake(_scrollView.width, _bottomView.maxY)];
        }];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_inputTitle resignFirstResponder];
}

-(void)fetchFeedback{
    
    if(_bottomLoader == nil){
        _bottomLoader = [[UIView alloc] initWithFrame:_usersFeedbackTable.frame];
        _bottomLoader.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        UILabel *loading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        loading.textColor = [UIColor grayColor];
        loading.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15];
        loading.text = @"Loading";
        [loading sizeToFit];
        loading.x = _bottomLoader.width/2 - loading.width/2;
        loading.y = _bottomLoader.height/2 - loading.height/2;
        [_bottomLoader addSubview:loading];
    }
    [self.view addSubview:_bottomLoader];
    
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_beenThere.allIds forKey:@"item_ids"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetCommunalBTDTFeedback:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        [_feedbackItems removeAllObjects];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            for(NSDictionary *d in [responseObject objectForKey:@"data"]){
                [_feedbackItems addObject:d];
            }
            [_usersFeedbackTable reloadData];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
        _bottomLoader.hidden = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
        _bottomLoader.hidden = YES;
    }];
}


-(void)pillActuallyTapped:(UIButton *)btn{
    [[AppController sharedInstance] hideKeyboard];
    if(btn.selected){
        return;
    }else{
        for(UIButton *b in _topButtons){
            b.selected = NO;
            b.backgroundColor = [UIColor clearColor];
            b.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.2].CGColor;
        }
        btn.selected = YES;
        btn.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        int idx = (int)btn.tag;
        NSArray *children = [[_options objectAtIndex:idx] objectForKey:@"children"];
        [self layoutChildOptions:children];
    }
}


-(void)childPillActuallyTapped:(UIButton *)btn{
    [[AppController sharedInstance] hideKeyboard];
    if(btn.selected){
        return;
    }else{
        int idx = (int)btn.tag;
        _categoryId = [NSString stringWithFormat:@"%d",idx];
        for(UIButton *b in _childButtons){
            b.selected = NO;
            b.backgroundColor = [UIColor clearColor];
            b.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.2].CGColor;
        }
        
        btn.selected = YES;
        btn.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    }
}


-(void)layoutChildOptions:(NSArray *)options{
    
    
    int btnHeight = 42;
    int idx = 0;
    [_childButtons removeAllObjects];
    _childButtonsScrollView.hidden = NO;
    [_childButtonsScrollView removeAllSubviews];
    _childButtonsScrollView.x = 0;
    _childButtonsScrollView.width = _topButtonsView.width;
    _childButtonsScrollView.height = _topButtonsView.height;
    _childButtonsScrollView.y = _topButtonsView.maxY;
    
    [_typeView addSubview:_childButtonsScrollView];
    
    int padding = 3;
    int pillWidth = (_childButtonsScrollView.width/[_options count]) - ([_options count] * padding/2);
    int startingX = 15;
    
    for(NSDictionary *dict in options){
        UIButton *pill = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, pillWidth, btnHeight)];
        [pill setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
        pill.layer.borderWidth = 1;
        [pill setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateNormal];
        [pill setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateSelected];
        pill.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:16];
        pill.titleLabel.textAlignment = NSTextAlignmentCenter;
        pill.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [pill sizeToFit];
        pill.height = btnHeight;
        pill.width += 25;
        if(pill.width < pillWidth)
            pill.width = pillWidth;

        pill.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.2].CGColor;
        pill.layer.cornerRadius = 8;
        pill.tag = [[NSString returnStringObjectForKey:@"id" withDictionary:dict] intValue];
        [pill addTarget:self action:@selector(childPillActuallyTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_childButtonsScrollView addSubview:pill];
        [_childButtons addObject:pill];
        startingX += pill.width + padding;
        int catId = [[NSString returnStringObjectForKey:@"id" withDictionary:dict] intValue];
        
        if(_beenThere.categoryId){
            if(catId == _beenThere.categoryId)
                [self childPillActuallyTapped:pill];
        }else if(idx == _defaultTopPill){
            [self childPillActuallyTapped:pill];
        }
        
    
        idx++;
    }
    
    [_childButtonsScrollView setContentSize:CGSizeMake(startingX + 10, _childButtonsScrollView.height)];
    [_childButtonsScrollView setContentOffset:CGPointMake(0, 0)];
    
}


-(void)changeTitleToStateView:(BOOL)val{
    if(val){
        NSString *str = @"View Photo V";
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:COLOR_CC_TEAL], NSForegroundColorAttributeName,nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_ICONS size:9.0],NSFontAttributeName,nil];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
        [attributedText setAttributes:subAttrs range: NSMakeRange([str length]-1,1)];
        [_btnShowHidePhoto setAttributedTitle:attributedText forState:UIControlStateNormal];
    }else{
        NSString *str = @"Hide Photo ^";
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:COLOR_CC_TEAL], NSForegroundColorAttributeName,nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_ICONS size:9.0],NSFontAttributeName,nil];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
        [attributedText setAttributes:subAttrs range: NSMakeRange([str length]-1,1)];
        [_btnShowHidePhoto setAttributedTitle:attributedText forState:UIControlStateNormal];

    }
}

-(void)ratingTapped:(UIButton *)btn{
    if(btn.selected){
        for(UIButton *b in _sectionRatings){
            b.selected = NO;
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:21];
        }
        return;
    }
    _rating = (int) btn.tag;
    for(UIButton *b in _sectionRatings){
        b.selected = NO;
        if(b.tag <= _rating){
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:25];
        }else{
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:21];
        }
    }
    btn.selected = YES;
}



- (IBAction)doSave {
    
    if([_inputTitle.text isEmpty]){
        [[AppController sharedInstance] showAlertWithTitle:@"City Missing" andMessage:@"Please enter a city"];
        return;
    }

    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Saving" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:@"sitem" forKey:@"a"];
    [dict setObject:_inputTitle.text forKey:@"title"];
    [dict setObject:_inputComments.text forKey:@"comment"];
    
    if(_isFromSearch){
        [dict setObject:_searchActivity.cityId forKey:@"lid"];
        [dict setObject:@"Y" forKey:@"fromSearch"];
    }else{
        [dict setObject:_beenThere.locationsId forKey:@"lid"];
    }
    
    [dict setObject:[NSNumber numberWithInt:_rating+1] forKey:@"rating"];
    if(_beenThere.isAChild){
        [dict setObject:_beenThere.itemId forKey:@"cid"];
    }
    
    [dict setObject:_categoryId forKey:@"subcat_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    NSData *data = UIImageJPEGRepresentation(_itemImage.image, 1.0f);
    
    __weak NSData *weakData = data;
    
    
    [manager POST:[AppAPIBuilder APIForSaveBeenThere:nil] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if(_imageChanged)
            [formData appendPartWithFileData:data name:@"file" fileName:@"banner.jpg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            if(_beenThere.isAChild){
                [dict setObject:_beenThere.itemId forKey:@"cid"];
                _beenThere.itemTitle = _inputTitle.text;
                if(weakData != nil){
                    
                    [[AppController sharedInstance].storedUploadedImages setObject:weakData forKey:[NSString stringWithFormat:@"btdt_%@",_beenThere.itemId]];
                }
                _beenThere.comment = _inputComments.text;
                _beenThere.rating = _rating+1;
                _beenThere.categoryId = [_categoryId intValue];
            }else{
                AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:[responseObject objectForKey:@"item"]];
                bt.isAChild = YES;
                if(weakData != nil){
                    
                    [[AppController sharedInstance].storedUploadedImages setObject:weakData forKey:[NSString stringWithFormat:@"btdt_%@",bt.itemId]];
                }
                [_beenThere.items insertObject:bt atIndex:1];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_BEEN_THERE_ITEM_RELOAD object:_beenThere];
            
            if(_isFromSearch){
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FOR_REFRESH_FIND object:nil];
            }
            
            [[AppController sharedInstance] goBack];
            [_loadingScreen removeFromSuperview];
            _imageChanged = NO;
            
        }else{
            [_loadingScreen removeFromSuperview];
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];

    
}

- (IBAction)doChangePhoto {
    if(!_imagePicker){
        _imagePicker = [[VTImagePicker alloc] init];
        _imagePicker.delegateViewController = self;
    }
    [_imagePicker presentPhotoPicker];
}

- (IBAction)doShowHidePhoto:(UIButton *)sender {
    

    if(sender.tag == 2){
        sender.tag = 1;
        [_imageLarge.layer removeAllAnimations];
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _imageLarge.y = -_imageLarge.height;
            _imageLarge.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];

        [self changeTitleToStateView:YES];
        
        
    }else{
        sender.tag = 2;
        _imageLarge.hidden = NO;
        _imageLarge.alpha = 0;
        [_imageLarge.layer removeAllAnimations];
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _imageLarge.y = 0;
            _imageLarge.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        [self changeTitleToStateView:NO];

    }
    
}



- (void)imagePickedForAvatarPreview:(UIImage *)image{

    if(_imageCropController != nil){
        _imageCropController = nil;
    }
    _imageCropController = [[ImageCropViewController alloc] initWithImage:image];
    _imageCropController.delegate = self;
    _imageCropController.blurredBackground = YES;
    [[self navigationController] pushViewController:_imageCropController animated:NO];
}


- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    UIImage *im = croppedImage;
    _itemImage.image = im;
    _imageChanged = YES;
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    [[self navigationController] popViewControllerAnimated:YES];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == _inputTitle){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            NSString *term = textField.text;
            if([term length] > 2){
                NSPredicate *p = [NSPredicate predicateWithFormat:@"( (title BEGINSWITH[cd] %@) )",term];
                _itemSuggestionsFiltered = [_itemSuggestions filteredArrayUsingPredicate:p];
                if([_itemSuggestionsFiltered count] == 0){
                    [self expandBottomView:NO];
                }else{
                    [self expandBottomView:YES];
                }
                [_tableSuggestions reloadData];
            }else{
                _itemSuggestionsFiltered = [[NSArray alloc] init];
                [self expandBottomView:NO];
                [_tableSuggestions reloadData];
            }
        });
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _inputTitle){
        [_inputTitle resignFirstResponder];
        return YES;
    }
    return NO;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    _commentPlaceholder.hidden = YES;
}

- (void)keyboardWillShow:(NSNotification*)aNotification{
    
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    _commentsView.height =  self.view.height *.10;
    _btnSave.y = _commentsView.maxY;
    _bottomView.height = _btnSave.maxY + kbSize.height;
    [_scrollView setContentSize:CGSizeMake(_scrollView.width, _bottomView.maxY)];
    
    if([_inputComments isFirstResponder]){
        float offset = _commentsView.y + _btnSave.height;
        
        [UIView animateWithDuration: 0.15
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_scrollView setContentOffset:CGPointMake(0,offset)];
                         }
                         completion:^(BOOL finished){}];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
}







#pragma mark TABLE


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _usersFeedbackTable){
        return [_feedbackItems count];
    }else if(tableView == _tableSuggestions){
        return [_itemSuggestionsFiltered count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == _tableSuggestions){
        return 20;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if(tableView == _tableSuggestions){
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 20)];
        v.backgroundColor = [[UIColor colorWithHexString:@"#140E46"] colorWithAlphaComponent:1];
        UILabel *l = [[UILabel alloc] initWithFrame:v.frame];
        l.x = 15;
        l.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:10];
        l.text = @"SUGGESTIONS";
        l.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        [v addSubview:l];
        return v;
        
    }
    return [[UIView alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if(tableView == _tableSuggestions){
        return 42;
    }
    NSDictionary *d = [_feedbackItems objectAtIndex:indexPath.row];
    return [AppUserFeedbackTableViewCell calculateHeight:d withWidth:self.view.width];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableSuggestions){
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellSuggestion];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellSuggestion];
        }
        NSDictionary *dict = [_itemSuggestionsFiltered objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:15];
        cell.textLabel.textColor = [UIColor whiteColor];
        [[cell viewWithTag:100] removeFromSuperview];
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        line.tag = 100;
        [cell addSubview:line];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    AppUserFeedbackTableViewCell *cell = (AppUserFeedbackTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppUserFeedbackTableViewCell];
    if (cell == nil) {
        cell = [[AppUserFeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppUserFeedbackTableViewCell];
    }
    
    NSDictionary *dict = [_feedbackItems objectAtIndex:indexPath.row];
    [cell setupWithDictionary:dict andWidth:tableView.width];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    if(tableView == _tableSuggestions){
        NSDictionary *dict = [_itemSuggestionsFiltered objectAtIndex:indexPath.row];
        _inputTitle.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        [self expandBottomView:NO];
    }
}



@end
