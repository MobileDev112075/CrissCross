//
//  AppDreamingOfViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppDreamingOfViewController.h"
#import "AppDreamingOfEditViewController.h"

@interface AppDreamingOfViewController ()

@end

@implementation AppDreamingOfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tagsOnScreen = [[NSMutableArray alloc] init];
    _isOwner = [_mainContactId isEqualToString:[AppController sharedInstance].currentUser.userId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRefreshTagCloud) name:NOTIFICATION_REFRESH_DREAMING_OF object:nil];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_reloadOnView){
        _reloadOnView = NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _reloadOnView = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkToShowHint];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        _tagCloudView.clipsToBounds = NO;
        _topnav.theTitle.text = @"Dreaming Of";
        _topnav.view.backgroundColor = [UIColor clearColor];
        _tagCloudView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
        
        if(_isOwner)
            [self.view addSubview:_btnEdit];
        else
            _btnEdit.hidden = YES;
        
        _hintView = [AppNotificationViewController buildHintViewWithText:@"Add places you're dreaming of to be notified when a friend plans a trip there!" andOffset:60];
        _hintView.hidden = YES;
        _hintView.backgroundColor = [UIColor clearColor];
        [self fetchGroups];
    }
    
}


-(void)checkToShowHint{
    if(!_isOwner){
        _hintView.hidden = YES;
        return;
    }
    if([_tagsOnScreen count] == 0){
        if(_isFullyLoaded){
            [self.view addSubview:_hintView];
            _hintView.hidden = NO;
        }
    }else{
        _hintView.hidden = YES;
    }
    
}

- (IBAction)doEdit {
    AppDreamingOfEditViewController *vc = [[AppDreamingOfEditViewController alloc] initWithNibName:@"AppDreamingOfEditViewController" bundle:nil];
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

- (IBAction)re:(id)sender {
    for(UIView *v in _tagsOnScreen){
        [UIView animateWithDuration:0.2 animations:^{
            v.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
            v.y += 40;
        } completion:^(BOOL finished) {
            
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buildTagCloud:0];
    });
}


-(void)fetchGroups{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:@"Y" forKey:@"fetch"];
    [dict setObject:_mainContactId forKey:@"user_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForDreamingOfEdit:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){

            [AppController sharedInstance].currentUser.dreamingOfLocations = [NSMutableArray arrayWithArray:[responseObject objectForKey:@"data"]];
            [self buildTagCloud:0];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
}

-(void)doRefreshTagCloud{
    [self buildTagCloud:0];
}

-(void)buildTagCloud:(int)step{

    _yMin = 0.0;
    _yMax = 0.0;
    _colorIdx = 0;
    [_tagCloudView removeAllSubviews];
    [_tagsOnScreen removeAllObjects];
    int count = 0;
    int minVal = 16-step;
    if(minVal < 14)
        minVal = 14;
    int maxVal = 50-step;
    

    
    NSArray *colors = @[COLOR_CC_TEAL,COLOR_CC_GREEN,@"FFFFFF"];
    
    float delay = 0.2;
    NSArray *items = [[NSMutableArray alloc] initWithArray:[AppController sharedInstance].currentUser.dreamingOfLocations];
    _isFullyLoaded = YES;
    [self checkToShowHint];
    
    if([[AppController sharedInstance].currentUser.dreamingOfLocations count] == 0){
        items = @[@{@"title":@"No Locations Added"}];
        if(_isOwner){
            return;
        }
    }
    
    for(NSDictionary *dict in items){

        int rndValue = minVal + arc4random() % (maxVal - minVal);

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        NSString *title = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        NSArray *titleParts = [title componentsSeparatedByString:@","];
        label.text = [NSString stringWithFormat:@"%@",[titleParts firstObject]];
        label.textColor = [UIColor colorWithHexString:[colors objectAtIndex:_colorIdx]];
        
        
        if(++_colorIdx > [colors count]-1)
            _colorIdx = 0;
        label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:rndValue];
        label.adjustsFontSizeToFitWidth = YES;
        [label sizeToFit];
        if(label.width > self.view.width){
            label.width = self.view.width - maxVal;
        }
        if(count == 0){
            label.x = _tagCloudView.width/2 - label.width/2;
            label.y = _tagCloudView.height/2 - label.height/2;
        }
        
        
        if(count > 0){
            UILabel *l;
            if(count == 1){
                l = [_tagsOnScreen lastObject];
            }else{
                l = [_tagsOnScreen objectAtIndex:[_tagsOnScreen count] - 2];
            }
            if(count % 2 == 0){
                label.y = l.maxY - 5;
            }else{
                label.y = l.y - label.height + 5;
            }
            
            label.x = _tagCloudView.width/2 - label.width/2;
            int playArea = (self.view.width - label.width)/4;
            int rndX = 0;
            if(playArea > 0){
                rndX = arc4random() % playArea;
            }
            
            int positiveNegative =  arc4random() % 2;
            if(positiveNegative == 1)
                label.x += rndX;
            else
                label.x -= rndX;
        }
        [_tagsOnScreen addObject:label];
        [_tagCloudView addSubview:label];
        count++;
        label.alpha = 0;
        
        if(label.y < _yMin){
            _yMin = label.y;
        }
        
        if(label.maxY > _yMax){
            _yMax = label.maxY;
        }
        
        
        label.y += 40;
        label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.3, 0.3);
        [UIView animateWithDuration:0.9 delay:delay usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            label.alpha = 1;
            label.y -= 40;
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
        delay += 0.1;
    }
    if(step < 35 && (_yMin < 0 || _yMax > _tagCloudView.height)){
        [self buildTagCloud:++step];
        
    }else{

    }
    
    [self checkToShowHint];
    
}


@end
