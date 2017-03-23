//
//  AppPlanPlanViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppPlanPlanViewController.h"
#import "AppPlansViewController.h"
#import "AppMyPlansViewController.h"

@interface AppPlanPlanViewController ()

@end

@implementation AppPlanPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSections) name:NOTIFICATION_PLANS_UPDATED object:nil];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
    
        _topnav.view.backgroundColor = [UIColor clearColor];
        _topnav.theTitle.text = @"";
        _sectionsHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        [self.view addSubview:_sectionsHolder];
        [self reloadSections];
        [self.view addSubview:_topnav.view];
    }else{
        [self reloadSections];
    }
}


-(void)reloadSections{

    
    _sections = [[NSMutableArray alloc] init];
    
    AppPlan *upcomingPlan = [[AppController sharedInstance].currentUser getFirstUpcomingPlanType:AppPlanTypeSure];
    
    if(upcomingPlan){
        [_sections addObject:@{@"img":upcomingPlan.img,@"title":@"Sure Plans", @"byline": upcomingPlan.title,@"icon":@"b"}];
    }else{
        [_sections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/santa-monica.jpg",IMAGE_PATH],@"title":@"Sure Plans", @"byline": @"No Upcoming Plans Yet",@"icon":@"b"}];
    }
    
    upcomingPlan = [[AppController sharedInstance].currentUser getFirstUpcomingPlanType:AppPlanTypeIf];
    
    if(upcomingPlan){
        [_sections addObject:@{@"img":upcomingPlan.img,@"title":@"If Plans", @"byline": upcomingPlan.title,@"icon":@","}];
    }else{
        [_sections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/boston.jpg",IMAGE_PATH],@"title":@"If Plans", @"byline": @"No Upcoming Plans Yet",@"icon":@","}];
    }
    
    [_sections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/ticket.jpg",IMAGE_PATH],@"title": @"Update Plans",@"icon":@"n"}];
    
    
    [_sectionsHolder removeAllSubviews];
    
    int startingY = 0;
    int rowHeight = self.view.height/[_sections count];
    int count = 0;
    
    BOOL showIcon = NO;
    
    int fontSizeTitle = round(rowHeight*.12);
    int fontSizeByline = round(rowHeight*.08);

    
    for(NSDictionary *dict in _sections){
        UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _sectionsHolder.width, rowHeight)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:row.frame];
        [iv setImageWithURL:[NSURL URLWithString:[NSString returnStringObjectForKey:@"img" withDictionary:dict]] placeholderImage:nil];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.alpha = kImageAlpha;
        iv.clipsToBounds = YES;
        [row addSubview:iv];
        
        [row addTarget:self action:@selector(doGoToSection:) forControlEvents:UIControlEventTouchUpInside];
        [row addTarget:self action:@selector(doHighlighRow:) forControlEvents:UIControlEventTouchDown ];
        [row addTarget:self action:@selector(doUnHighlighRow:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit | UIControlEventTouchDragOutside];
        row.tag = count++;
        
        UILabel *label = [[UILabel alloc] initWithFrame:row.frame];
        label.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeTitle];
        label.textColor = [UIColor whiteColor];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label.width = row.width;
        
        label.y = row.height/2 - label.height/2 + 10;
        [row addSubview:label];
        
        THLabel *icon = [[THLabel alloc] initWithFrame:row.frame];
        icon.text = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
        icon.font = [UIFont fontWithName:FONT_ICONS size:22];
        icon.textColor = [UIColor whiteColor];
        icon.adjustsFontSizeToFitWidth = YES;
        [icon sizeToFit];
        
        icon.y = label.y - icon.height - 8;
        icon.x = row.width/2 - icon.width/2;
        if(showIcon)
            [row addSubview:icon];
        
        UILabel *byline = [[UILabel alloc] initWithFrame:row.frame];
        byline.text = [NSString returnStringObjectForKey:@"byline" withDictionary:dict];
        byline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeByline];
        byline.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
        byline.adjustsFontSizeToFitWidth = YES;
        byline.textAlignment = NSTextAlignmentCenter;
        [byline sizeToFit];
        byline.width = row.width;
        
        if([byline.text length] < 1){
            label.y = row.height/2 - label.height/2;
            
        }else{
            label.y = row.height/2 - label.height;
            byline.y = row.height/2 + 2;
        }
        
        UIView *highlightOnTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, row.width,row.height)];
        highlightOnTapView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1];
        highlightOnTapView.userInteractionEnabled = NO;
        [row insertSubview:highlightOnTapView aboveSubview:iv];
        highlightOnTapView.alpha = 0;
        highlightOnTapView.tag = 999;

        
        [row addSubview:byline];
        
        [_sectionsHolder addSubview:row];
        row.y = startingY;
        startingY += row.height;
    }
    if(_doAnimateIn)
        [self animateTilesIn];
}

-(void)animateTilesIn{
    _doAnimateIn = NO;
    float delay = 0.2;
    for(UIView *v in _sectionsHolder.subviews){
        v.alpha = 0;
        v.x += 150;
        [UIView animateWithDuration:0.6 delay:delay usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
            v.alpha = 1;
            v.x = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        delay += 0.1;
    }
    
}


-(void)doHighlighRow:(UIButton *)btn{
    
    UIView *highlightView = [btn viewWithTag:999];
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
        highlightView.alpha = 0.2;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doUnHighlighRow:btn];
        });
    }];
}

-(void)doUnHighlighRow:(UIButton *)btn{
    
    UIView *highlightView = [btn viewWithTag:999];
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
        highlightView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}




-(void)doGoToSection:(UIButton *)btn{
    int idx = (int)btn.tag;
    
    switch (idx) {
        case 0:{
            AppPlansViewController *vc = [[AppPlansViewController alloc] initWithNibName:@"AppPlansViewController" bundle:nil];
            vc.planType = AppPlanTypeSure;
            vc.mainContactId = [AppController sharedInstance].currentUser.userId;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
        
        case 1:{
            AppPlansViewController *vc = [[AppPlansViewController alloc] initWithNibName:@"AppPlansViewController" bundle:nil];
            vc.planType = AppPlanTypeIf;
            vc.mainContactId = [AppController sharedInstance].currentUser.userId;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
            
        case 2:{
            AppMyPlansViewController *vc = [[AppMyPlansViewController alloc] initWithNibName:@"AppMyPlansViewController" bundle:nil];
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
            

        default:
            break;
    }
}


@end
