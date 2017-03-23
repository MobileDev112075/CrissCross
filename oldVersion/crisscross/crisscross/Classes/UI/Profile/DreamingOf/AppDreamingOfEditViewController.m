//
//  AppDreamingOfEditViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppDreamingOfEditViewController.h"
#import "MGSwipeButton.h"


#define kAppStaticCellName2 @"kAppStaticCellName2"
#define kAppStaticCellName3 @"kAppStaticCellName3"

@interface AppDreamingOfEditViewController ()

@end

@implementation AppDreamingOfEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    _itemsStored = [AppController sharedInstance].currentUser.dreamingOfLocations;
    _items = [[NSMutableArray alloc] init];
    _previousResults = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_DREAMING_OF object:nil];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        _topnav.theTitle.text = @"Dreaming Of";
        _rowHeight = roundf((self.view.height/2.0)/5.0);
        
        _bottomView.y = _topView.maxY;
        _bottomView.height = self.view.height - _bottomView.y;
        
        
        _topView.layer.shadowColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
        _topView.layer.shadowOffset = CGSizeMake(0,0);
        _topView.layer.shadowOpacity = 1;
        _topView.layer.shadowRadius = 12;
        _viewSearch.hidden = YES;
    }
}



- (void)keyboardWillShow:(NSNotification*)aNotification{
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float newHeight = self.view.height - kbSize.height - _cityView.y;
    
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _cityView.height = newHeight;
                         _tableViewCity.height = newHeight;
                     }
                     completion:^(BOOL finished){}];
    
    
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
    
}




-(IBAction)doAddCity{
    [self showCityView];
}


-(void)showCityView{
    [_items removeAllObjects];
    [_tableViewCity reloadData];
    _viewSearch.hidden = NO;
    _cityView.width = _bottomView.width;
    _cityView.y = _bottomView.y;
    _cityView.height = _bottomView.height - _cityView.y;
    [self.view insertSubview:_cityView belowSubview:_topView];
    [_inputWhere becomeFirstResponder];
}
-(void)hideCityView{
    _viewSearch.hidden = YES;
    [_cityView removeFromSuperview];
    _inputWhere.text = @"";
    [[AppController sharedInstance] hideKeyboard];
}

-(void)processSearchResult:(NSDictionary *)dict overrideTicket:(BOOL)override{
    
    NSString *ticket = [NSString returnStringObjectForKey:@"ticket" withDictionary:dict];
    if(override || [ticket isEqualToString:[NSString stringWithFormat:@"%d",_lastTicket]]){
        [_items removeAllObjects];
        _items = [NSMutableArray arrayWithArray:[dict objectForKey:@"data"]];
        [_tableViewCity reloadData];
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
        [dict setObject:@"dreaming" forKey:@"type"];
        
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


-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.01);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self performStringGeocode:textField.text];
    });
    return YES;
}





#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _tableViewCity)
        return [_items count];
    
    return [_itemsStored count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _rowHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(tableView == _tableViewCity){
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellName3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellName3];
        }
        
        NSDictionary *dict = [_items objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(_rowHeight * 0.23)];
        cell.textLabel.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellName2];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellName2];
    }
    

    NSDictionary *dict = [_itemsStored objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(_rowHeight * 0.23)];
    cell.textLabel.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.delegate = self;
    cell.textLabel.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:_rowHeight]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableViewCity){
        NSDictionary *place = [_items objectAtIndex:indexPath.row];
        [_itemsStored insertObject:place atIndex:0];
        [_tableView reloadData];
        
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setObject:place forKey:@"place"];
        [dict setObject:@"N" forKey:@"remove"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [manager POST:[AppAPIBuilder APIForDreamingOfEdit:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
     
        [[AppController sharedInstance] hideKeyboard];
        [self hideCityView];
    }
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    NSIndexPath *pathInQuestion = [_tableView indexPathForCell:cell];
    NSDictionary *place = [_itemsStored objectAtIndex:pathInQuestion.row];
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:place forKey:@"place"];
    [dict setObject:@"Y" forKey:@"remove"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForDreamingOfEdit:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    
    [_itemsStored removeObjectAtIndex:pathInQuestion.row];
    [_tableView deleteRowsAtIndexPaths:@[pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];
    return YES;
}





@end
