//
//  AppProfileDetailsViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppProfileDetailsViewController.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)



@interface AppProfileDetailsViewController ()

@end

@implementation AppProfileDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
    _stampsToRemove = [[NSMutableArray alloc] init];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSMutableArray *finalStamps = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in _thisUser.stamps){
        if([_stampsToRemove containsObject:dict]){
        }else{
            [finalStamps addObject:dict];
        }
    }
    _thisUser.stamps = finalStamps;
    
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)userInfoUpdated{
    if(_thisUser.imgData != nil){
        _userImage.image = [[UIImage alloc] initWithData:_thisUser.imgData];
    }else{
        [_userImage setImageWithURL:[NSURL URLWithString:_thisUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
    }
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        self.view.clipsToBounds = YES;
        float ratio = 320/150;
        
        _userImage.width = [AppController sharedInstance].screenBoundsSize.width;
        _userImage.height = _userImage.width/ratio;
        _scrollView.width = [AppController sharedInstance].screenBoundsSize.width;
        
        _btnEdit.y = _userImage.maxY;
        _scrollView.y = _userImage.height;
        _scrollView.height = [AppController sharedInstance].screenBoundsSize.height - _userImage.width/ratio;
        _theBg.frame = _scrollView.frame;
        [_topnav.view removeFromSuperview];
        _userImage.clipsToBounds = YES;
        
        if(_thisUser.imgData != nil){
            _userImage.image = [[UIImage alloc] initWithData:_thisUser.imgData];
        }else{
            [_userImage setImageWithURL:[NSURL URLWithString:_thisUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
        }
        
        
        _viewGradient = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _userImage.width, _userImage.height)];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _viewGradient.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5] CGColor],
                           (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.25] CGColor],
                           (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0] CGColor],
                           nil];
        [_viewGradient.layer insertSublayer:gradient atIndex:0];
        
        [self.view insertSubview:_viewGradient belowSubview:_btnClose];
        
        if([_thisUser.userId isEqualToString:[AppController sharedInstance].currentUser.userId]){
            _btnEdit.hidden = NO;
            _btnEdit.width = self.view.width;
            _btnEdit.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
            _btnEdit.y = self.view.height - _btnEdit.height;
            [_btnEdit setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE] forState:UIControlStateNormal];
        }else
            _btnEdit.hidden = YES;
        
        
        
        [self buildStamps];
    }
}


-(void)buildStamps{
    [_scrollView removeAllSubviews];
    
    
    int startingX = 0;
    int startingY = 35;
    NSArray *stampNames = @[@"stamp1.png",@"stamp2.png"];
    
    NSArray *stampColors = @[
                                [UIColor colorWithHexString:COLOR_CC_TEAL],
                                [UIColor colorWithHexString:COLOR_CC_GREEN],
                                [UIColor colorWithHexString:COLOR_CC_BLUE],
                                ];
    
    int stampColorIdx =  arc4random() % [stampColors count];
    
    int itemsInRow = 2;
    int itemsCountForRow = 0;
    float ratio = 432/248;
    int tag = 0;
    
    if([_thisUser.stamps count] == 1)
        _btnEdit.hidden = YES;
    
    for(NSDictionary *dict in _thisUser.stamps){
    
        int stampIdx =  arc4random() % [stampNames count];
        int stampRotation =  arc4random() % 35;
        int stampRotationDirection =  arc4random() % 2;
        if(stampRotationDirection == 1){
            stampRotation *= -1;
        }


        int sWidth = _scrollView.width/itemsInRow - 20;
        int sHeight = sWidth/ratio;
        int yVariant =  arc4random() % 35;
        int posNeg =  arc4random() % 2;
        
        if(posNeg == 1){
            yVariant *= -1;
        }
        int yPlacement = startingY + yVariant;
        if(yPlacement <= 20)
            yPlacement = 20;
        
        int xVariant =  arc4random() % 35;
        posNeg =  arc4random() % 2;
        
        if(posNeg == 1){
            xVariant *= -1;
        }
        int xPlacement = startingX + xVariant;
        if(xPlacement <= 10)
            xPlacement = 10;
        else if(xPlacement > _scrollView.width - 30)
            xPlacement = _scrollView.width - 30;
        
        UIImageView *stamp = [[UIImageView alloc] initWithFrame:CGRectMake(xPlacement, yPlacement, sWidth, sHeight)];
        stamp.contentMode = UIViewContentModeScaleAspectFit;
        stamp.image = [UIImage imageNamed:stampNames[stampIdx]];
        stamp.image = [stamp.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        stamp.tintColor = stampColors[stampColorIdx];
        stamp.tag = tag;
        stamp.userInteractionEnabled = YES;
        
        UILabel *city = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, stamp.width - stamp.width/4, 15)];
        city.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        city.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:10];
        city.textAlignment = NSTextAlignmentCenter;
        city.adjustsFontSizeToFitWidth = YES;
        city.alpha = 0.9;
        if(stampIdx == 0){
            city.x = stamp.width/2 - city.width/2;
            city.y = stamp.height/3;
        }else{
            city.x = stamp.width/2 - city.width/2;
            city.y = stamp.height/2;
        }
        city.textColor = stampColors[stampColorIdx];
        [stamp addSubview:city];
        
        UILabel *theDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, stamp.width, 20)];
        theDate.text = [NSString returnStringObjectForKey:@"date" withDictionary:dict];
        theDate.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:8];
        [theDate sizeToFit];
        theDate.alpha = 0.9;
        if(stampIdx == 1){
            theDate.x = stamp.width/2 - theDate.width/2;
            theDate.y = stamp.height/2 + theDate.height + 5;
        }else{
            theDate.x = stamp.width/2 - theDate.width/2;
            theDate.y = stamp.height/2 + theDate.height;
        }
        theDate.textColor = stampColors[stampColorIdx];
        [stamp addSubview:theDate];

        NSString *idval = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
        
        
        
        UIButton *btnX = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        btnX.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        btnX.layer.cornerRadius = btnX.width/2;
        [btnX setTitleEdgeInsets:UIEdgeInsetsMake(-2, 0, 0, 0)];
        [btnX setTitle:@"X" forState:UIControlStateNormal];
        [btnX addTarget:self action:@selector(removeStamp:) forControlEvents:UIControlEventTouchDown];
        btnX.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:14];
        btnX.userInteractionEnabled = YES;
        btnX.hidden = YES;
        btnX.tag = tag++;
        
        btnX.x = stamp.width/2 - btnX.width/2;
        btnX.y = 20;
        if([idval length] > 0){
            [stamp addSubview:btnX];
        }
        
        
        
        
        stamp.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(stampRotation));
        [_scrollView addSubview:stamp];
        
        if(++itemsCountForRow >= itemsInRow){

            itemsInRow = 2;
            itemsCountForRow = 0;
            startingY += sHeight - 30;
            startingX = 0;
        }else{
            startingX += sWidth + 10;
        }
       
        if(++stampColorIdx >= [stampColors count]){
            stampColorIdx = 0;
        }
        
    }
    [_scrollView addSubview:_btnEdit];
    _btnEdit.y = startingY + 150;
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.width, _btnEdit.maxY + 30)];
    _scrollView.height = [AppController sharedInstance].screenBoundsSize.height - _scrollView.y;
}

- (IBAction)doClose {
    [[AppController sharedInstance] goBack];
}

- (IBAction)doEdit {
    
    if(_btnEdit.tag == 2){
        _btnEdit.tag = 1;
        [_btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
        
        for(UIView *v in _scrollView.subviews){
            if([v isKindOfClass:[UIImageView class]]){
                UIImageView *iv = (UIImageView *) v;
                for(UIView *sv in iv.subviews){
                    if([sv isKindOfClass:[UIButton class]]){
                        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.60 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                            sv.alpha = 0;
                            sv.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
                        } completion:^(BOOL finished) {
                            sv.hidden = YES;
                        }];
                        
                    }
                }
            }
        }
        
    }else{
        _btnEdit.tag = 2;
        [_btnEdit setTitle:@"Save" forState:UIControlStateNormal];
        for(UIView *v in _scrollView.subviews){
            if([v isKindOfClass:[UIImageView class]]){
                UIImageView *iv = (UIImageView *) v;
                for(UIView *sv in iv.subviews){
                    if([sv isKindOfClass:[UIButton class]]){
                        sv.hidden = NO;
                        sv.alpha = 0;
                        sv.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
                        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.60 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                            sv.alpha = 1;
                            sv.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished) {
                            
                        }];
                        
                    }
                }
            }
        }
    }
}


-(void)removeStamp:(UIButton *)btn{
    
    _idxInQuestion = (int) btn.tag;
    NSDictionary *dict = [_thisUser.stamps objectAtIndex:_idxInQuestion];
    NSString *city = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove this stamp?" message:[NSString stringWithFormat:@"%@",city] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
    [av show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        NSDictionary *dict = [_thisUser.stamps objectAtIndex:_idxInQuestion];

        [self removeStampFromServer:dict];
        
        for(UIView *v in _scrollView.subviews){
            if([v isKindOfClass:[UIImageView class]]){
                UIImageView *iv = (UIImageView *) v;
                if(iv.tag == _idxInQuestion){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        iv.hidden = YES;
                    });
                    
                    break;
                }
            }
        }
        
    }
}


-(void)removeStampFromServer:(NSDictionary *)data{
    
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:[NSString returnStringObjectForKey:@"id" withDictionary:data] forKey:@"id"];
    
    [_stampsToRemove addObject:data];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForRemoveStamp:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}



@end
