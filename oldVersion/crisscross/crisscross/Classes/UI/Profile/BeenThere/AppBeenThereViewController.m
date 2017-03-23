//
//  AppBeenThereViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppBeenThereViewController.h"
#import "AppBeenThereTableViewCell.h"
#import "AppBeenThereDetailViewController.h"
#import "AppNotificationViewController.h"
#import "AppFindFriendViewController.h"

#import "MGSwipeButton.h"

#define kAppBeenThereTableViewCell @"AppBeenThereTableViewCell"
#define kAppStaticCellNameBeenThere @"kAppStaticCellNameBeenThere"


@interface AppBeenThereViewController ()

@end

@implementation AppBeenThereViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isFiltering = NO;
    _canShowSearchBar = YES;
    _tableContentSize = 0;
    _searchItems = [[NSMutableArray alloc] init];
    _filteredItems = [[NSArray alloc] init];
    _previousResults = [[NSMutableDictionary alloc] init];
    _noItems = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_noItems setTitle:@"No items" forState:UIControlStateNormal];
    _noItems.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:24];
    [_noItems setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    _noItems.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteBeenThereItem:) name:NOTIFICATION_DELETE_BEEN_THERE_CHILD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heardReloadRow:) name:NOTIFICATION_ADD_BEEN_THERE_ITEM_RELOAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heardAdjustRow:) name:NOTIFICATION_BEEN_THERE_ADJUST_LAYOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDoHideSearch) name:NOTIFICATION_BTDT_DO_HIDE_SEARCH_CAUSE_OF_SCROLL object:nil];
    
    
    
    self.canLeaveWithSwipe = YES;
    [_tableView registerNib:[UINib nibWithNibName:kAppBeenThereTableViewCell bundle:nil] forCellReuseIdentifier:kAppBeenThereTableViewCell];
    _isOwner = NO;
    if([_thisUser.userId isEqualToString:[AppController sharedInstance].currentUser.userId]){
        _isOwner = YES;
    }

    _items = _thisUser.beenThereItems;
    
    for(AppBeenThere *bt in _items){
        bt.showExpanded = NO;
        bt.disabledChecked = NO;
        [bt.disabledChilds removeAllObjects];
        [bt.disabledTops removeAllObjects];
    }

    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_reloadOnReEntry){
        [self fetchData];
    }
    _reloadOnReEntry = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBeenThereItem:) name:NOTIFICATION_ADD_BEEN_THERE_ITEM object:nil];
    [self doubleCheckTopGap];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self doubleCheckTopGap];
}

-(void)doubleCheckTopGap{
    
    if(_tableView.contentOffset.y < 0){
        [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ADD_BEEN_THERE_ITEM object:nil];
    [self doubleCheckTopGap];
}

-(void)layoutUI{
    
    if(!_didLayout){
        _didLayout = YES;
        _topnav.theTitle.text = @"Been There, Done That";
        _searchInput = [[UITextField alloc] init];
        if(_isOwner){
            [self.view addSubview:_btnEdit];
            [self.view addSubview:_btnClose];
        }else{
            [_btnEdit removeFromSuperview];
            [_btnClose removeFromSuperview];
        }
        _rowHeight = roundf((self.view.height/2.0)/5.0);
        
        _btnClose.hidden = YES;
        [_tableView reloadData];
        _tableContentSize = _tableView.contentSize.height;
        
        _hintView = [AppNotificationViewController buildHintViewWithText:@"Create a guide of your favorite places so your friends can enjoy them too!" andOffset:60];
        _hintView.hidden = YES;
        
        
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, _topnav.view.maxY, self.view.width,55)];
        _searchView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [self.view addSubview:_searchView];
        
        
        _searchInput.frame = CGRectMake(0, 20, _searchView.width - 40, roundf(_searchView.height * 0.55));
        _searchInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 0)];
        _searchInput.leftViewMode = UITextFieldViewModeAlways;
        _searchInput.delegate = self;

        NSString *placeholderText = @"Search Entries";
        if(_isOwner){
            placeholderText = @"Search your suggestions";
        }
        
        float fontSize = roundf(_searchInput.height * 0.55);
        _searchInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.3]}];
        
        UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 40, _searchInput.height)];
        icon.font = [UIFont fontWithName:FONT_ICONS size:fontSize];
        icon.text = @"v";
        icon.textColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1];
        icon.adjustsFontSizeToFitWidth = YES;
        
        _searchInput.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize];
        _searchInput.textColor = [UIColor whiteColor];
        _searchInput.y = (_searchView.height/2 - _searchInput.height/2) - 2;
        _searchInput.x = _searchView.width/2 - _searchInput.width/2;
        icon.y = _searchInput.y + _searchInput.height/2 - icon.height/2;
        _searchInput.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _searchInput.spellCheckingType = UITextSpellCheckingTypeNo;
        _searchInput.returnKeyType = UIReturnKeySearch;
        
        [_searchInput addBottomBorderWithHeight:1.0 andColor:[UIColor colorWithHexString:COLOR_CC_TEAL]];
        [_searchView addSubview:icon];
        [_searchView addSubview:_searchInput];
        _tableView.y = _searchView.maxY;
        _tableView.height = self.view.height - _tableView.y;

        
        
        if(_communityView){
            _searchInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Find Friend's Favorites" attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.3]}];
            
            _topnav.theTitle.text = @"Friends Been There, Done That";
            _btnEdit.hidden = YES;
            
            if(_searchActivity == nil){
                _canShowSearchBar = YES;
            }else{
                [_searchView removeFromSuperview];
                _canShowSearchBar = NO;
                _tableView.y = _topnav.view.maxY;
                _tableView.height = self.view.height - _tableView.y;
            }
            
            [self fetchData];
        }else{
            [self checkToShowHint];
        }
        
        
        
    }else{
        [_tableView reloadData];
        _tableContentSize = _tableView.contentSize.height;
    }


}

-(void)fetchData{
 
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    
    if(_searchActivity != nil){
        [dict setObject:_searchActivity.cityId forKey:@"justId"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetCommunalBTDT:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        _items = [[NSMutableArray alloc] init];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            for(NSDictionary *d in [responseObject objectForKey:@"beenthere"]){
                AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:d];
                [_items addObject:bt];
                if(_communityView && _searchActivity != nil){
                    bt.showExpanded = YES;
                }
            }
            _filteredItems = [[NSArray alloc] initWithArray:_items];
            [_tableView reloadData];
            _hasFinishedFetch = YES;
            [self checkToShowHint];
           
            
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];

}



-(void)saveData:(AppBeenThere *)item{
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    
    if([item.itemId isEqualToString:@"-1"]){
        [dict setObject:@"s" forKey:@"a"];
        [dict setObject:item.locationsId forKey:@"lid"];
        [dict setObject:item.title forKey:@"lt"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForSaveBeenThere:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
           //todo get image
            item.img = [NSString returnStringObjectForKey:@"img" withDictionary:responseObject];
            [_tableView reloadData];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

-(void)deleteData:(AppBeenThere *)bt{
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    
    [dict setObject:@"d" forKey:@"a"];
    [dict setObject:bt.locationsId forKey:@"lid"];

    
    if(bt.isAChild){
        [dict setObject:@"Y" forKey:@"child"];
        [dict setObject:bt.itemId forKey:@"cid"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForSaveBeenThere:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

-(void)checkToShowHint{
    
    
    if(!_isOwner || _communityView){
         _hintView.hidden = YES;
        _searchView.hidden = NO;
        return;
    }
    
    if([_items count] == 0){
        [self.view addSubview:_hintView];
        _hintView.hidden = NO;
        _searchView.hidden = YES;
    }else{
        _hintView.hidden = YES;
        _searchView.hidden = NO;
    }
    
}

- (IBAction)doAdd {
    [self showSearchView];
    
}

- (IBAction)doClose {
    [self hideSearchView];
    [self checkToShowHint];
}

-(void)addBeenThereItem:(NSNotification *)note{
    
    AppBeenThere *mainBT = (AppBeenThere *) [note.object objectForKey:@"top"];
    if([note.object objectForKey:@"child"] != nil){
        
        mainBT = (AppBeenThere *) [note.object objectForKey:@"child"];
    }
    
    
    AppBeenThereDetailViewController *vc = [[AppBeenThereDetailViewController alloc] initWithNibName:@"AppBeenThereDetailViewController" bundle:nil];
    BOOL isAStub = NO;
    if([note.object objectForKey:@"is_a_stub"] != nil){
        isAStub = YES;
    }
    
    if(_communityView && isAStub){
        
        vc.isFromSearch = YES;
        vc.isOwner = YES;
        AppActivity *act = [[AppActivity alloc] initWithDictionary:@{}];
        act.cityId = mainBT.locationsId;
        act.img = mainBT.img;
        vc.searchActivity = act;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        return;
    }
    vc.isOwner = _isOwner;
    vc.beenThere = mainBT;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)deleteBeenThereItem:(NSNotification *)note{
    AppBeenThere *bt = (AppBeenThere *) note.object;
    [self deleteData:bt];
}



#pragma mark filter

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == _searchInput){
        
        

        for(AppBeenThere *item in _filteredItems){
            item.showExpanded = !item.showExpanded;
            [item.searchableCategoryIds removeAllObjects];
            [_tableView reloadData];
        }
        
        for(AppBeenThere *item in _filteredItems){
            item.showExpanded = !item.showExpanded;
            [item.searchableCategoryIds removeAllObjects];
            [_tableView reloadData];
        }
        
        for(AppBeenThere *item in _items){
            item.showExpanded = !item.showExpanded;
            [item.searchableCategoryIds removeAllObjects];
            [_tableView reloadData];
        }
        
        for(AppBeenThere *item in _items){
            item.showExpanded = !item.showExpanded;
            [item.searchableCategoryIds removeAllObjects];
            [_tableView reloadData];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == _searchInput){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isFiltering = YES;
            NSString *term = textField.text;
            if([term length] == 0){
                _filteredItems = [[NSArray alloc] initWithArray:_items];
            }else{
                NSPredicate *p = [NSPredicate predicateWithFormat:@"( (title CONTAINS[cd] %@) OR (itemTitle BEGINSWITH[cd] %@) OR (ANY %K.%K BEGINSWITH[cd] %@) )",term,term,@"items",@"itemTitle",term];
                _filteredItems = [_items filteredArrayUsingPredicate:p];
            }
            [_tableView reloadData];
        });
    
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _searchInput){
        [_searchInput resignFirstResponder];
    }
    return YES;
}


#pragma mark search

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton: YES animated: YES];
    _searchShowing = YES;
    //
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton: NO animated: YES];
    _searchShowing = NO;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    _searchActive = YES;
    
    if([searchText isEmpty]){
        _searchActive = NO;
        [_tableViewSearch reloadData];
    }else{
        [self performStringGeocode:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [[AppController sharedInstance] hideKeyboard];
    _searchBar.text = @"";
    _searchActive = NO;
    [_tableViewSearch reloadData];
    [self hideSearchView];
}


-(void)showSearchView{
    self.canLeaveWithSwipe = NO;
    _btnEdit.hidden = YES;
    _btnClose.hidden = NO;
    _tableViewSearch.width = self.view.width;
    _tableViewSearch.y = _topnav.view.maxY;
    _tableViewSearch.height = self.view.height - _tableViewSearch.y;
    [self.view addSubview:_tableViewSearch];
    [_searchBar becomeFirstResponder];
    _hintView.hidden = YES;
}
-(void)hideSearchView{
    self.canLeaveWithSwipe = YES;
    _btnEdit.hidden = NO;
    _btnClose.hidden = YES;
    [_tableViewSearch removeFromSuperview];
    [[AppController sharedInstance] hideKeyboard];
    [self checkToShowHint];
}

-(void)processSearchResult:(NSDictionary *)dict overrideTicket:(BOOL)override{
    
    NSString *ticket = [NSString returnStringObjectForKey:@"ticket" withDictionary:dict];
    
    if(override || [ticket isEqualToString:[NSString stringWithFormat:@"%d",_lastTicket]]){
        [_searchItems removeAllObjects];
        _searchItems = [NSMutableArray arrayWithArray:[dict objectForKey:@"data"]];
        [_tableViewSearch reloadData];
    }
    
}

- (void)performStringGeocode:(NSString *)str{
    
    if(_searchManager){
        [_searchManager.operationQueue cancelAllOperations];
    }
    if([_previousResults objectForKey:str] != nil){
        [self processSearchResult:[_previousResults objectForKey:str] overrideTicket:YES];
    }else{
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setObject:str forKey:@"query"];
        [dict setObject:[NSString stringWithFormat:@"%d",++_lastTicket] forKey:@"ticket"];
        [dict setObject:@"btdt" forKey:@"type"];


        _searchManager = [AFHTTPRequestOperationManager manager];
        _searchManager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [_searchManager POST:[AppAPIBuilder APIForSearchCity:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){
                NSString *term = [NSString returnStringObjectForKey:@"term" withDictionary:responseObject];
                [_previousResults setObject:responseObject forKey:term];
                [self processSearchResult:responseObject overrideTicket:NO];
            }else{
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}


-(void)heardReloadRow:(NSNotification *)note{

    
    if(_communityView){
        [self fetchData];
    }else{
        [_tableView reloadData];
        _tableContentSize = _tableView.contentSize.height;
    }
}


-(void)heardAdjustRow:(NSNotification *)note{
    [_tableView reloadData];
    _tableContentSize = _tableView.contentSize.height;
}


#pragma mark TABLE


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _tableViewSearch){
        return [_searchItems count];
    }
    
    if(_isFiltering){
        return [_filteredItems count];
    }
    
    if(_canShowSearchBar){
        _searchView.hidden = NO;
    }
    
    if([_items count] == 0){
        _searchView.hidden = YES;
        if(!_isOwner || _communityView){
            _noItems.width = roundf(self.view.width * 0.80);
            
            if(_communityView){
                [_noItems setTitle:@"Add friends to\nsee their suggestions!" forState:UIControlStateNormal];
                [_noItems setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
                _noItems.titleLabel.numberOfLines = 2;
                _noItems.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:roundf(self.view.width * 0.055)];
                _noItems.titleLabel.textAlignment = NSTextAlignmentCenter;
                _noItems.layer.borderWidth = 1;
                _noItems.layer.borderColor = [UIColor colorWithHexString:COLOR_CC_TEAL].CGColor;
                _noItems.layer.cornerRadius = 12;
                [_noItems addTarget:self action:@selector(doFriendsView) forControlEvents:UIControlEventTouchUpInside];
                if(_canShowSearchBar){
                   _searchView.hidden = YES;
                }
            }
            _noItems.hidden = NO;
            [_noItems sizeToFit];
            _noItems.width = roundf(self.view.width * 0.80);
            _noItems.height += 40;
            
            _noItems.x = self.view.width/2 - _noItems.width/2;
            _noItems.y = self.view.height/2 - _noItems.height/2;
            [self.view addSubview:_noItems];
            
            if(!_hasFinishedFetch){
                _noItems.hidden = YES;
            }
            
        }
    }else{
        [_noItems removeFromSuperview];
    }
    return [_items count];
    
}

-(void)doFriendsView{
    _reloadOnReEntry = YES;
    AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
    vc.fromProfile = YES;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tableViewSearch){
        return _rowHeight;
    }
    
    if(_isFiltering){
        AppBeenThere *b = [_filteredItems objectAtIndex:indexPath.row];
        if(b.showExpanded){
            return self.view.height - _tableView.y;
        }else{
            return 120.0;
        }
    }else{
        AppBeenThere *b = [_items objectAtIndex:indexPath.row];
        if(b.showExpanded){
            return self.view.height - _tableView.y;
        }else{
            return 120.0;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(tableView == _tableView){
        AppBeenThereTableViewCell *cell = (AppBeenThereTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppBeenThereTableViewCell];
        if (cell == nil) {
            cell = [[AppBeenThereTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppBeenThereTableViewCell];
        }
        AppBeenThere *dict;
        if(_isFiltering){
            dict = [_filteredItems objectAtIndex:indexPath.row];
        }else{
            dict = [_items objectAtIndex:indexPath.row];
        }
        [dict setAsOwnerItem:_isOwner];
        cell.isOwner = _isOwner;
        [cell setupWithBeenThere:dict topOffset:(_canShowSearchBar) ? -_searchView.height : 0];
        
        if(!_communityView && _isOwner && !dict.showExpanded){
        
            cell.rightButtons = @[
                              [MGSwipeButton buttonWithTitle:@"" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:120.0]
                              ];
            cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
            cell.delegate = self;
        }else{
            cell.rightButtons = @[];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellNameBeenThere];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellNameBeenThere];
    }
    
    NSDictionary *dict = [_searchItems objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(_rowHeight * 0.23)];
    cell.textLabel.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableViewSearch){
        
        
        AppBeenThere *item = [[AppBeenThere alloc] initWithDictionary:[_searchItems objectAtIndex:indexPath.row]];

        item.locationsId = item.itemId;
        
        
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"locationsId == %@",item.locationsId];
        NSArray *pResults = [NSMutableArray arrayWithArray:[_items filteredArrayUsingPredicate:p]];
        
        
        if([pResults count] > 0){

            _searchBar.text = @"";
            [self hideSearchView];
            [_searchItems removeAllObjects];
            [_tableViewSearch reloadData];
            
            int itemLocation = (int)[_items indexOfObject:[pResults firstObject]];
            
            @try{
                AppBeenThere *bt = [_items objectAtIndex:itemLocation];
                bt.showExpanded = NO;
                [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:itemLocation inSection:0]];
            }@catch(NSException *e){
                
            }
            return;
        }else{
        
            item.itemId = @"-1";
            item.showExpanded = YES;
            item.animateIn = YES;
            _searchBar.text = @"";
            _searchInput.text = @"";
            [_searchInput resignFirstResponder];
            [_items insertObject:item atIndex:0];
            _filteredItems = [[NSArray alloc] initWithArray:_items];
            [_tableView reloadData];
            [self hideSearchView];
            [_searchItems removeAllObjects];
            [_tableViewSearch reloadData];
            [self saveData:item];
        }
        
    }else if(tableView == _tableView){
        
        
        
        
        if(_communityView){
            [_searchInput resignFirstResponder];
        }
        AppBeenThere *item;
        
        if(_isFiltering){
            item = [_filteredItems objectAtIndex:indexPath.row];
        }else{
            item = [_items objectAtIndex:indexPath.row];
        }

        item.showExpanded = !item.showExpanded;
        
        if(_communityView)
            item.communityItem = YES;
        
        float yPos = (120 * indexPath.row);
        
        if(item.showExpanded){
            tableView.scrollEnabled = NO;
            [tableView setContentSize:CGSizeMake(tableView.width, _tableView.contentSize.height + self.view.height)];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [UIView animateWithDuration:0.5 animations:^{
                [tableView setContentOffset:CGPointMake(0, yPos) animated:NO];
            }];
        }else{
            [item.searchableCategoryIds removeAllObjects];
            [tableView setContentSize:CGSizeMake(tableView.width, _tableContentSize)];
            tableView.scrollEnabled = YES;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self doubleCheckTopGap];
        
    }


}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{

    if(_communityView)
        return NO;
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        
        NSIndexPath * path = [_tableView indexPathForCell:cell];
        AppBeenThere *item = [_items objectAtIndex:path.row];
        [self deleteData:item];
        [_items removeObjectAtIndex:path.row];
        [_tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self checkToShowHint];
        return NO;
        
    }else{
        [[AppController sharedInstance] showAlphaMessage];
    }
    
    return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BTDT_DO_HIDE_SEARCH_CAUSE_OF_SCROLL object:nil];
}

-(void)noteDoHideSearch{
    [_searchInput resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification*)aNotification{
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float newHeight = self.view.height - kbSize.height - _tableViewSearch.y;
    float newHeight2 = self.view.height - kbSize.height - _tableView.y;
    
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _tableViewSearch.height = newHeight;
                         _tableView.height = newHeight2;
                     }
                     completion:^(BOOL finished){}];
}

- (void)keyboardWillHide:(NSNotification*)aNotification{

    float newHeight2 = self.view.height - _tableView.y;
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _tableView.height = newHeight2;
                     }
                     completion:^(BOOL finished){}];
}


@end
